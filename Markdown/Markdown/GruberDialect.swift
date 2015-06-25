//
//  GruberDialect.swift
//  Markdown
//
//  Created by Leanne Northrop on 16/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation

class GruberDialect : Dialect {
    // Key values determine block handler orders
    static let ATX_HEADER_HANDLER_KEY : String = "0_atxHeader"
    static let EXT_HEADER_HANDLER_KEY : String = "1_extHeader"
    static let HORZ_RULE_HANDLER_KEY : String = "3_horizRule"
    static let CODE_HANDLER_KEY : String = "4_code"
    static let PARA_HANDLER_KEY : String = "9_para"
    
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
            (block : Line, var next : Lines) -> [AnyObject]? in
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
                    var l = Line(text: block._text.substr(0,length: count(matches[0])), lineNumber: block._lineNumber + 2, trailing:block._trailing)
                    next.unshift(l)
                }
                
                return [header]
            }
        }
        self.block[GruberDialect.EXT_HEADER_HANDLER_KEY] = {
            (block : Line, var next : Lines) -> [AnyObject]? in
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
            (block : Line, var next : Lines) -> [AnyObject]? in
            
            let regEx = "^(?:([\\s\\S]*?)\n)?[ \t]*([-_*])(?:[ \t]*\\2){2,}[ \t]*(?:\n([\\s\\S]*))?$"
            
            if !block._text.isMatch(regEx) {
                return nil
            }
            
            // this needs to find any hr in the block to handle abutting blocks
            var matches = block._text.matches(regEx)
            var jsonml : [AnyObject] = [["hr"]]
            
            // if there's a leading abutting block, process it
            if matches.count >= 2 {
                var contained = Line(text: matches[1], lineNumber: block._lineNumber, trailing: "")
                //TODO jsonml.insert(self.toTree( contained, [] ) , atIndex: 0)
            }
            
            // if there's a trailing abutting block, stick it into next
            if matches.count >= 4 {
                next.unshift(Line(text: matches[3], lineNumber: block._lineNumber + 1, trailing: block._trailing))
            }
            
            return jsonml
        }

        self.block[GruberDialect.CODE_HANDLER_KEY] = {
            (block : Line, var next : Lines) -> [AnyObject]? in
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
            (block : Line, var next : Lines) -> [AnyObject]? in
            var arr : [AnyObject] = ["para"]
            arr += self.processInline(block._text, patterns: nil)
            return [arr]
        }
        
        self.inline["!["] = {
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
}