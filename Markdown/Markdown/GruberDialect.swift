//
//  GruberDialect.swift
//  Markdown
//
//  Created by Leanne Northrop on 16/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation
import Markdown

class GruberDialect : Dialect {
    // Key values determine block handler orders
    static let ATX_HEADER_HANDLER_KEY = "0_atxHeader"
    static let EXT_HEADER_HANDLER_KEY = "1_extHeader"
    static let HORZ_RULE_HANDLER_KEY = "3_horizRule"
    static let CODE_HANDLER_KEY = "4_code"
    static let BLOCK_QUOTE_HANDLER_KEY = "5_block_quote"
    static let DEF_LIST_HANDLER_KEY = "6_def_list"
    static let LIST_HANDLER_KEY = "7_list"
    static let PARA_HANDLER_KEY = "9_para"
    static let __escape__ = "^\\\\[\\\\\\`\\*_{}<>\\[\\]()#\\+.!\\-]"
    
    override init() {
        super.init()
        
        self.__inline_call__ = {
            (str : String, pattern : String?) -> [AnyObject] in
            var out : [AnyObject] = []
            
            if pattern != nil {
                var text : String = str
                var res : [AnyObject] = []
                while ( count(text) > 0 ) {
                    res = super.oneElement(text, patterns: pattern!)
                    var strCount = res.removeAtIndex(0) as! Int
                    text = strCount >= count(text) ? "" : text.substr(strCount)
                    for element in res {
                        if out.isEmpty {
                            out.append(element)
                        } else {
                            if element as? String != nil && out.last as? String != nil {
                                var s : String = out.removeLast() as! String
                                s += element as! String
                                out.append(s)
                            } else {
                                out.append(element)
                            }
                        }
                    }
                }
            }
            
            return out
        }

        self.block[GruberDialect.ATX_HEADER_HANDLER_KEY] = {
            (block : Line, inout next : Lines) -> [AnyObject]? in
            var regEx = "^(#{1,6})\\s*(.*?)\\s*#*\\s*(?:\n|$)"
            
            if !block._text.isMatch(regEx) {
                return nil
            } else {
                var matches = block._text.matches(regEx)
                
                var level : Int = count(matches[1])
                var header : [AnyObject] = ["header", ["level": String(level)]]
                var processedHeader = self.processInline(matches[2], patterns: nil)
                if (processedHeader.count == 1 && processedHeader[0] as? String != nil) {
                    header.append(processedHeader[0] as! String)
                } else {
                    header.append(processedHeader)
                }
                
                if (count(matches[0]) < count(block._text)) {
                    var l = Line(text: block._text.substr(count(matches[0])), lineNumber: block._lineNumber + 2, trailing:block._trailing)
                    next.unshift(l)
                }
                
                return [header]
            }
        }
        self.block[GruberDialect.EXT_HEADER_HANDLER_KEY] = {
            (block : Line, inout next : Lines) -> [AnyObject]? in
            var regEx = "^(.*)\n([-=])\\2\\2+(?:\n|$)"

            if !block._text.isMatch(regEx) {
                return nil
            }

            var matches = block._text.matches(regEx)
            var level = (matches[2] == "=") ? 1 : 2
            var header : [AnyObject] = ["header", ["level" : String(level)]]
            var processedHeader = self.processInline(matches[1], patterns: nil)
            if (processedHeader.count == 1 && processedHeader[0] as? String != nil) {
                header.append(processedHeader[0] as! String)
            } else {
                header.append(processedHeader)
            }
            
            var length : Int = count(matches[0])
            if length < count(block._text) {
                next.unshift(Line(text: block._text.substr(length), lineNumber: block._lineNumber + 2, trailing: block._trailing))
            }
            
            return [header]
        }
        
        self.block[GruberDialect.HORZ_RULE_HANDLER_KEY] = {
            (block : Line, inout next : Lines) -> [AnyObject]? in
            
            let regEx = "^(?:([\\s\\S]*?)\n)?[ \t]*([-_*])(?:[ \t]*\\2){2,}[ \t]*(?:\n([\\s\\S]*))?$"
            
            if !block._text.isMatch(regEx) {
                return nil
            }
            
            // this needs to find any hr in the block to handle abutting blocks
            var matches = block._text.matches(regEx)
            var jsonml : [AnyObject] = [["hr"]]
            
            // if there's a leading abutting block, process it
            if matches.count >= 2 {
                var contained = matches[1]
                if count(contained) > 0 {
                    var nodes = super.toTree(contained, root: [] )
                    jsonml = [nodes,["hr"]]
                }
            }
            
            // if there's a trailing abutting block, stick it into next
            if matches.count >= 4 {
                if count(matches[3]) > 0 {
                    next.unshift(Line(text: matches[3], lineNumber: block._lineNumber + 1, trailing: block._trailing))
                }
            }
            
            return jsonml
        }

        self.block[GruberDialect.CODE_HANDLER_KEY] = {
            (block : Line, inout next : Lines) -> [AnyObject]? in
            // |    Foo
            // |bar
            // should be a code block followed by a paragraph. Fun
            //
            // There might also be adjacent code block to merge.
            var text = block._text
            var ret : [String] = []
            let regEx = "^(?: {0,3}\t| {4})(.*)\n?"
            
            // 4 spaces + content
            if !text.isMatch(regEx) {
                return ret
            }
            
            do {
                // Now pull out the rest of the lines
                var b = super.loop_re_over_block(regEx, block: text, cb: {
                    (m : [String]) -> () in
                    ret.append(m[1])
                })
                
                if count(b) > 0 {
                    // Case alluded to in first comment. push it back on as a new block
                    next.unshift(Line(text: b, lineNumber: block._lineNumber, trailing: block._trailing))
                    break
                }
                else if !next.isEmpty() {
                    // Check the next block - it might be code too
                    if !next.line(0)._text.isMatch(regEx) {
                        break
                    }
                    
                    // Pull how how many blanks lines follow - minus two to account for .join
                    ret.append(block._trailing.replaceByRegEx("[^\\n]", replacement: "").substr(2))
                    
                    let line = next.shift()
                    if line != nil {
                        text = line!._text
                    }
                }
                else {
                    break
                }
            } while true
            

            return [["code_block", "\n".join(ret)]]
        }
        
        self.block[GruberDialect.PARA_HANDLER_KEY] = {
            (block : Line, inout next : Lines) -> [AnyObject]? in
            var arr : [AnyObject] = ["para"]
            arr += self.processInline(block._text, patterns: nil)
            return [arr]
        }

        /*self.block[GruberDialect.LIST_HANDLER_KEY] = {
            [unowned self]
            (var block : Line, inout next : Lines) -> [AnyObject]? in
            
            var any_list = "[*+-]|\\d+\\."
            var bullet_list = "[*+-]"
            // Capture leading indent as it matters for determining nested lists.
            var is_list_re = "^( {0,3})(" + any_list + ")[ \t]+"
            var indent_re = "(?: {0,3}\\t| {4})"
            
            // TODO: Cache this regexp for certain depths.
            // Create a regexp suitable for matching an li for a given stack depth
            func regex_for_depth(depth : Int) -> String {
                // m[1] = indent, m[2] = list_type m[3] = cont
                return "(?:^(\(indent_re){0,\(depth)} {0,3})(\(any_list))\\s+)|(^\(indent_re){0,\(depth-1)}[ ]{0,4})"
            }
            
            func expand_tab(input : String) -> String {
                return input.replaceByRegEx(" {0,3}\t", replacement: "    " )
            }
            
            // Add inline content `inline` to `li`. inline comes from processInline
            // so is an array of content
            func add(inout li:[AnyObject], loose : Bool, inout inline : [AnyObject], nl : String?) {
                if loose {
                    var nextLi : [AnyObject] = ["para"]
                    nextLi.extend(inline)
                    li.append(nextLi)
                    return
                }
                
                if li.count < 0 { return }
                
                // Hmmm, should this be any block level element or just paras?
                var lastItem : AnyObject = li[li.count-1]
                var add_to : [AnyObject]
                if (lastItem is [AnyObject]) && (lastItem[0] === "para") {
                    add_to = lastItem as! [AnyObject]
                } else {
                    add_to = li
                }
                
                // If there is already some content in this list, add the new line in
                if nl != nil && (li.count > 1) {
                    inline.insert(nl!, atIndex: 0)
                }
                
                for var i = 0; i < inline.count; i++ {
                    var what: AnyObject = inline[i]
                    var is_str = what is String
                    var endItem: AnyObject = add_to[add_to.count-1]
                    if ( is_str && add_to.count > 1 && endItem is String) {
                        add_to[add_to.count-1] = (endItem as! String)  + (what as! String)
                    }
                    else {
                        add_to.append(what)
                    }
                }
            }
            
            // contained means have an indent greater than the current one. On
            // *every* line in the block
            func get_contained_blocks(depth : Int, inout blocks : Lines) -> Lines {
                var re = "^(\(indent_re){\(depth)}.*?\\n?)*$"
                var replace = "^\(indent_re){\(depth)}"
                var ret = Lines()
                
                while !blocks.isEmpty() {
                    if blocks.line(0)._text.isMatch(re) {
                        var b : Line = blocks.shift()!
                        // Now remove that indent
                        var x = b._text.replaceByRegEx(replace, replacement: "")
                        
                        ret.unshift(Line(text: x, lineNumber: b._lineNumber, trailing: b._trailing))
                    }
                    else {
                        break
                    }
                }
                return ret
            }
            
            // passed to stack.forEach to turn list items up the stack into paras
            func paragraphify(inout s : [String:AnyObject], i : Int, stack : [AnyObject]) {
                /*var list = s["list"] as! [AnyObject]
                var last_li = list[list.count-1]
                var item : [AnyObject]? = last_li[1] as? [AnyObject]
                if (item != nil) {
                    var s = item[0] as? String
                    if (s === "para") {
                        return
                    }
                }
                
                todo if ( i + 1 === stack.count ) {
                    // Last stack frame
                    // Keep the same array, but replace the contents
                    last_li.push( ["para"].concat( last_li.splice(1, last_li.length - 1) ) );
                }
                else {
                    var sublist = last_li.pop();
                    last_li.push( ["para"].concat( last_li.splice(1, last_li.length - 1) ), sublist );
                }*/
            }
            
            func make_list(matches : [String], inout s : [AnyObject]) -> [AnyObject] {
                var list = matches[2].isMatch(bullet_list) ? ["bulletlist"] : ["numberlist"]
                
                s.append(["list" : list, "indent": matches[1]])
                
                return list
            }
            
            if !block._text.isMatch(is_list_re) {
                return []
            }
            
            var matches = block._text.matches(is_list_re)
            var stack : [AnyObject] = [] // Stack of lists for nesting.
            var list = make_list(matches, &stack)
            var last_li : [AnyObject] = []
            var loose = false
            var ret : [AnyObject] = [list]
            var i:Int
            
            // Loop to search over block looking for inner block elements and loose lists
            loose_search:
                while true {
                    // Split into lines preserving new lines at end of line
                    var listlines = block._text.split("\n")
                    listlines.map({$0 + "\n"})
                    
                    // We have to grab all lines for a li and call processInline on them
                    // once as there are some inline things that can span lines.
                    var li_accumulate = ""
                    var nl = ""
                    
                    // Loop over the lines in this block looking for tight lists.
                    tight_search:
                        for var line_no = 0; line_no < listlines.count; line_no++ {
                            nl = ""
                            var l = listlines[line_no]
                            if l.isMatch("^\n") {
                                nl = "\n"
                                l = ""
                            }
                            
                            // TODO: really should cache this
                            var line_re = regex_for_depth(stack.count)
                            
                            matches = l.matches(line_re)
                            //print( "line:", uneval(l), "\nline match:", uneval(m) );
                            
                            // We have a list item
                            if matches[1] != ""  {
                                // Process the previous list item, if any
                                if count(li_accumulate) > 0 {
                                    //todo add( last_li, loose, this.processInline( li_accumulate ), nl ); **************************************
                                    // Loose mode will have been dealt with. Reset it
                                    loose = false
                                    li_accumulate = ""
                                }
                                
                                matches[1] = expand_tab(matches[1])
                                var d = Double(count(matches[1])/4)
                                var wanted_depth = Int(floor(d))+1
                                println("want:\(wanted_depth) stack:\(stack.count)")
                                if wanted_depth > stack.count {
                                    // Deep enough for a nested list outright
                                    //print ( "new nested list" );
                                    list = make_list(matches, &stack)
                                    last_li.append(list)
                                    //last_li = list[1] = [ "listitem" ];***************************************************************
                                }
                                else {
                                    // We aren't deep enough to be strictly a new level. This is
                                    // where Md.pl goes nuts. If the indent matches a level in the
                                    // stack, put it there, else put it one deeper then the
                                    // wanted_depth deserves.
                                    var found = false
                                    for ( i = 0; i < stack.count; i++ ) {
                                        //if ( stack[ i ]["indent"] != matches[1] ) {
                                        //    continue
                                        //}
                                        
                                        //list = stack[i]["list"]
                                        //stack.splice( i+1, stack.length - (i+1) );****************************************************
                                        found = true
                                        break
                                    }
                                    
                                    if (!found) {
                                        //print("not found. l:", uneval(l));
                                        wanted_depth++;
                                        if wanted_depth <= stack.count {
                                            //stack.splice(wanted_depth, stack.count - wanted_depth)
                                            //print("Desired depth now", wanted_depth, "stack:", stack.length);
                                            //list = stack[wanted_depth-1]["list"]
                                            //print("list:", uneval(list) );
                                        }
                                        else {
                                            //print ("made new stack for messy indent");
                                            list = make_list(matches, &stack)
                                            last_li.append(list)
                                        }
                                    }
                                    
                                    //print( uneval(list), "last", list === stack[stack.length-1].list );
                                    last_li = [ "listitem" ]
                                    list.append(last_li)
                                } // end depth of shenegains
                                nl = "";
                            }
                            
                            // Add content
                            if count(l) > count(matches[0]) {
                                li_accumulate += nl + l.substr(count(matches[0]))
                            }
                    } // tight_search
                    
                    if count(li_accumulate) > 0{
                        var emptyLines = Lines()
                        var contents = self.processBlock(Line(text:li_accumulate, lineNumber:0, trailing:""), next: &emptyLines)
                        
                        if contents != nil {
                            //firstBlock = contents![0]
                            //firstBlock.removeAtIndex(0)
                            var arr : [AnyObject] = [0,1]
                            //arr.extend(firstBlock)
                            //contents.splice.apply(contents, [0, 1].concat(firstBlock));*****************************************
                            //add( last_li, loose, contents, nl );
                            
                            // Let's not creating a trailing \n after content in the li
                            //if last_li[last_li.count-1] === "\n" {
                            //    last_li.removeLast()
                            //}
                            
                            // Loose mode will have been dealt with. Reset it
                            loose = false
                            li_accumulate = ""
                        }
                    }
                    
                    // Look at the next block - we might have a loose list. Or an extra
                    // paragraph for the current li
                    var contained = get_contained_blocks(stack.count, &next)
                    
                    // Deal with code blocks or properly nested lists
                    if !contained.isEmpty() {
                        // Make sure all listitems up the stack are paragraphs
                        var j : Int = 0
                        for item in stack {
                            var s : [String:AnyObject] = item as! [String:AnyObject]
                            paragraphify(&s, j++, stack)
                        }
                        
                        last_li.append(self.toTree(contained.text(), root:[]))
                    }
                    
                    var next_block = ""
                    if !next.isEmpty() {
                        next_block = next.line(0)._text
                    }
                    if next_block.isMatch(is_list_re) || next_block.isMatch("^ ") {
                        block = next.shift()!
                        
                        // Check for an HR following a list: features/lists/hr_abutting
                        /*var hr = this.dialect.block.horizRule.call( this, block, next );***************************************
                        
                        if ( hr ) {
                            ret.push.apply(ret, hr);
                            break;
                        }
                        
                        // Add paragraphs if the indentation level stays the same
                        if (stack[stack.length-1].indent === block.match("^\s*")[0]) {
                            forEach( stack, paragraphify, this);
                        }*/
                        
                        loose = true;
                        continue loose_search;
                    }
                    
                    break
                } // loose_search
            
            return ret
        }*/
        
        self.block[GruberDialect.DEF_LIST_HANDLER_KEY] = {
            [unowned self]
            (var block : Line, inout next : Lines) -> [AnyObject]? in
            
            var regEx = "^\\s*\\[([^\\[\\]]+)\\]:\\s*(\\S+)(?:\\s+(?:(['\"])(.*)\\3|\\((.*?)\\)))?\n?"
            
            // interesting matches are [ , ref_id, url, , title, title ]
            if !block._text.isMatch(regEx) {
                return []
            }
            
            var b = self.loop_re_over_block(regEx, block: block._text) {
                
                (matches: [String]) -> () in
                self.create_reference(matches)
            }
            
            if count(b) > 0 {
                next.unshift(Line(text:b,lineNumber:0,trailing:block._trailing))
            }
            
            return []
        }
        
        self.block[GruberDialect.BLOCK_QUOTE_HANDLER_KEY] = {
            (var block : Line, inout next : Lines) -> [AnyObject]? in

            // Handle quotes that have spaces before them
            var text = block._text
            var m = text.matches("(^|\n) +(\\>[\\s\\S]*)")
            
            if !m.isEmpty && (m.count >= 3) && (count(m[2]) > 0) {
                var blockContents = text.replaceByRegEx("(^|\n) +\\>", replacement: ">");
                next.unshift(Line(text: blockContents, lineNumber: block._lineNumber, trailing: block._trailing))
                return []
            }
            
            if !text.isMatch("^>") {
                return []
            }
            
            var jsonml : [AnyObject] = []
            // separate out the leading abutting block, if any. I.e. in this case:
            //
            //  a
            //  > b
            //
            if !text.isMatch("^>")  {
                var newLines = text.split("\n")
                var prev : [Line] = []
                var line_no = block._lineNumber;
                
                // keep shifting lines until you find a crotchet
                while !newLines.isEmpty && !newLines[0].isMatch("^>") {
                    prev.append(Line(text: newLines.removeAtIndex(0), lineNumber: 0, trailing: "\n"))
                    line_no++
                }
                
                var abutting = Line(text: prev.reduce("", combine: {$0 + "\n" + $1._text}), lineNumber: block._lineNumber, trailing: "\n")
                var emptyNextLines = Lines()
                jsonml.append(self.processBlock(abutting, next: &emptyNextLines)!)
                
                // reassemble new block of just block quotes!
                block = Line(text: "\n".join(newLines), lineNumber: line_no, trailing: block._trailing)
                text = block._text
            }
            
            // if the next block is also a blockquote merge it in
            while !next.isEmpty() && next.line(0)._text.isMatch("$>") {
                var b = next.shift()!
                block = Line(text: text + block._trailing + b._text, lineNumber: block._lineNumber, trailing: b._trailing)
                text = block._text
            }
            
            // Strip off the leading "> " and re-process as a block.
            var input = text.replaceByRegEx("^> ?", replacement: "").replace("\n>", replacement: "\n")
            var old_tree = self.tree
            var processedBlock = self.toTree(input, root: ["blockquote"])
            /*var attr = self.extract_attr( processedBlock )
            // If any link references were found get rid of them
            if ( attr && attr.references ) {
                delete attr.references;
                // And then remove the attribute object if it's empty
                if ( isEmpty( attr ) )
                processedBlock.splice( 1, 1 );
            }*/
            
            jsonml.append(processedBlock)
            
            return jsonml
        }
        
        // These characters are interesting elsewhere, so have rules for them so that
        // chunks of plain text blocks don't include them
        self.inline["]"] = {
            (text : String) -> [AnyObject] in
            return []
        }
        
        self.inline["}"] = {
            (text : String) -> [AnyObject] in
            return []
        }
        
        self.inline["\\"] = {
            (var text : String) -> [AnyObject] in
            // [ length of input processed, node/children to add... ]
            // Only esacape: \ ` * _ { } [ ] ( ) # * + - . !
            if text.isMatch(GruberDialect.__escape__) {
                let idx1 = advance(text.startIndex, 1)
                var str : String = String(text.removeAtIndex(idx1))
                return [2, str]
            }
            else {
                // Not an esacpe
                return [1, "\\"]
            }
        }
        
        
        self.inline["!["] = {
            [unowned self]
            (text : String) -> [AnyObject] in
            
            // Unlike images, alt text is plain text only. no other elements are
            // allowed in there
            
            // ![Alt text](/path/to/img.jpg "Optional title")
            //      1          2            3       4         <--- captures
            //
            // First attempt to use a strong URL regexp to catch things like parentheses. If it misses, use the
            // old one.
            let newRegExPattern = "^!\\[(.*?)][ \\t]*\\((" + self.URL_REG_EX + ")\\)([ \\t])*([\"'].*[\"'])?"
            let oldRegExPattern = "^!\\[(.*?)\\][ \\t]*\\([ \\t]*([^\")]*?)(?:[ \\t]+([\"'])(.*?)\\3)?[ \\t]*\\)"
            let matchesNewRegEx = text.isMatch(newRegExPattern)
            let matchesOldRegEx = text.isMatch(oldRegExPattern)
            
            if matchesNewRegEx || matchesOldRegEx {
                var m : [String] = matchesNewRegEx ? text.matches(newRegExPattern) : text.matches(oldRegExPattern)
                if m.count > 2 && !m[2].isBlank() {
                    var m2 = m[2]
                    if m2.isMatch("^<") && m2.isMatch(">$") {
                        m[2] = m2.substr(1, length: count(m2)-1)
                    }
                }
                
                var processedText = self.processInline(m[2], patterns: "\\")
                m[2] = processedText.count == 0 ? "" : processedText[0] as! String

                var attrs : [String:String] = ["alt" : m[1], "href" : m[2]]
                if m.count > 5 && !m[4].isBlank() {
                    attrs["title"] = m[4]
                }
                
                return [count(m[0]), ["img", attrs]]
            }
            
            // ![Alt text][id]
            if text.isMatch("^!\\[(.*?)\\][ \\t]*\\[(.*?)\\]"){
                var m = text.matches("^!\\[(.*?)\\][ \\t]*\\[(.*?)\\]")
                // We can't check if the reference is known here as it likely wont be
                // found till after. Check it in md tree->hmtl tree conversion
                return [count(m[0]), ["img_ref", ["alt" : m[1], "ref" : m[2].lowercaseString, "original" : m[0]]]]
            }
            
            // Just consume the '!['
            return [2, "!["]
        }

        self.inline["["] = {
            [unowned self]
            (var text : String) -> [AnyObject] in
            
            var open = 1;
            for c in text {
                if (c == "[") { open++; }
                if (c == "]") { open--; }
                if (open > 3) { return [1, "["] }
            }
            
            var orig = String(text);
            // Inline content is possible inside `link text`
            var linkText:String = text.substr(1)
            var res = self.inline_until_char(linkText, want: "]")
            
            // No closing ']' found. Just consume the [
            var index = res[0] as! Int
            if index > count(linkText) {
                var result : [AnyObject] = [index + 1, "["]
                result += res[2] as! [AnyObject]
                return result
            }
            
            // empty link
            if index == 1 { return [ 2, "[]" ] }
            
            var consumed = 1 + index
            var children = res[1] as! [AnyObject]
            var link : [AnyObject] = []
            var attrs : [String:String] = [:]
            
            // At this point the first [...] has been parsed. See what follows to find
            // out which kind of link we are (reference or direct url)
            text = text.substr(consumed)
            
            // [link text](/path/to/img.jpg "Optional title")
            //                 1            2       3         <--- captures
            // This will capture up to the last paren in the block. We then pull
            // back based on if there a matching ones in the url
            //    ([here](/url/(test))
            // The parens have to be balanced
            let regEx = "^\\s*\\([ \\t]*([^\"']*)(?:[ \\t]+([\"'])(.*?)\\2)?[ \\t]*\\)"
            if text.isMatch(regEx) {
                var m = text.matches(regEx)
                var url = m[1].replaceByRegEx("\\s+$", replacement: "")
                consumed += count(m[0])
                
                var urlCount = count(url)
                if (urlCount > 0) {
                   if url.isMatch("^<") && url.isMatch(">$") {
                        url = url.substr(1, length: urlCount - 1)
                    }
                }
                
                // If there is a title we don't have to worry about parens in the url
                if m.count < 3 {
                    var open_parens = 1 // One open that isn't in the capture
                    for var len : Int = 0; len < urlCount; len++ {
                        var firstChar : String = url![len]
                        switch firstChar {
                        case "(":
                            open_parens++
                        case ")":
                            if --open_parens == 0 {
                                consumed -= urlCount - len
                                url = url.substr(0, length: len)
                            }
                        default:
                            println(firstChar)
                        }
                    }
                }
                
                // Process escapes only
                url = self.__inline_call__(url, "\\")[0] as! String
                
                attrs = ["href": url]
                if m.count >= 3 {
                    attrs["title"] = m[3] as String
                }
                
                link = ["link", attrs]
                link.extend(children)
                return [consumed, link]
            }
            
            // [Alt text][id]
            // [Alt text] [id]
            if text.isMatch("^\\s*\\[(.*?)\\]"){
                var m = text.matches("^\\s*\\[(.*?)\\]")
                
                consumed += count(m[0])
                
                // [links][] uses links as its reference
                var ref = children.reduce("", combine: {$0 + $1.description})
                if m.count >= 2 {
                    ref = m[1]
                }
                attrs = ["ref" : ref.lowercaseString,  "original" : orig.substr(0, length: consumed)]
                
                if children.count > 0 {
                    link = ["link_ref", attrs]
                    link.extend(children)
                    
                    // We can't check if the reference is known here as it likely wont be
                    // found till after. Check it in md tree->hmtl tree conversion.
                    // Store the original so that conversion can revert if the ref isn't found.
                    return [consumed, link]
                }
            }
            
            // Another check for references
            var regExp = "^\\s*\\[(.*?)\\]:\\s*(\\S+)(?:\\s+(?:(['\"])(.*?)\\3|\\((.*?)\\)))?\\n?"
            if orig.isMatch(regExp) {
                var m : [String] = orig.matches(regExp)
                self.create_reference(m)
                return [count(m[0])]
            }
            
            
            // [id]
            // Only if id is plain (no formatting.)
            if ( children.count == 1 && children[0] is String) {
                var id = children[0] as! String
                var normalized = id.lowercaseString.replaceByRegEx("\\s+", replacement: " ")
                attrs = ["ref" : normalized, "original" : orig.substr(0, length: consumed)]
                link = ["link_ref", attrs, id]
                return [consumed, link]
            }
            
            // Just consume the "["
            return [1, "["]
        }
        
        self.inline["<"] = {
            (text : String) -> [AnyObject] in
                
            if text.isMatch("^<(?:((https?|ftp|mailto):[^>]+)|(.*?@.*?\\.[a-zA-Z]+))>") {
                let m = text.matches("^<(?:((https?|ftp|mailto):[^>]+)|(.*?@.*?\\.[a-zA-Z]+))>")
                if m.count == 4 && !m[3].isBlank() {
                    return [count(m[0]), [ "link", ["href": "mailto:" + m[3]], m[3]]]
                }
                else if m.count > 3 && m[2] == "mailto" {
                    return [count(m[0]), [ "link", ["href": m[1]], m[1].substr(count("mailto:"))]]
                }
                else {
                    return [count(m[0]), [ "link", ["href": m[1]], m[1]]]
                }
            }
            
            return [1, "<"]
        }
        
        self.inline["`"]    = {
            (text : String) -> [AnyObject] in
            // Inline code block. as many backticks as you like to start it
            // Always skip over the opening ticks.
            var regEx = "(`+)(([\\s\\S]*?)\\1)"
            
            if text.isMatch(regEx) {
                var m = text.matches(regEx)
                var length = count(m[1]) + count(m[2])
                return [length, [ "inlinecode", m[3]]]
            }
            else {
                // TODO: No matching end code found - warn!
                return [1, "`"]
            }
        }

        self.inline["\n"] = {
            (text : String) -> [AnyObject] in
            return [3, ["linebreak"]]
        }

        self.inline["**"]   = super.strong_em("strong", md: "**")
        self.inline["__"]   = super.strong_em("strong", md: "__")
        self.inline["*"]    = super.strong_em("em", md: "*")
        self.inline["_"]    = super.strong_em("em", md: "_")
        
        buildBlockOrder()
        buildInlinePatterns()
    }

    // Create references for attributes
    func create_reference(details: [String]) {
        var href = details[2]
        if details.count >= 3 &&
           details[2].isMatch("^<") &&
           details[2].isMatch(">$") {
            href = details[2].substr(1, length: count(details[2]) - 1)
        }
        
        var title = ""
        if details.count == 5 && count(details[4]) > 0 {
            title = details[4]
        } else if details.count == 6 && count(details[5]) > 0  {
            title = details[5]
        }
        
        var ref = Ref(rid: details[1].lowercaseString, title: title, href: href)
        addRef(ref)
    }
}