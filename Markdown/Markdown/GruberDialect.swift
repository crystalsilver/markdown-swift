//
//  GruberDialect.swift
//  Markdown
//
//  Created by Leanne Northrop on 16/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation

class GruberDialect : Dialect {
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

        self.block["atxHeader"] = {
            (block : Line, var next : Lines) -> [AnyObject]? in
            var regEx = "^(#{1,6})\\s*(.*?)\\s*#*\\s*(?:\n|$)"
            
            if !block._text.isMatch(regEx) {
                return nil
            } else {
                var matches = block._text.matches(regEx)
                
                var level : Int = count(matches[1])
                var header : [AnyObject] = ["header", ["level": level]]
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
        self.block["extHeader"] = {
            (block : Line, var next : Lines) -> [AnyObject]? in
            var regEx = "^(.*)\n([-=])\\2\\2+(?:\n|$)"

            if !block._text.isMatch(regEx) {
                return nil
            }

            var matches = block._text.matches(regEx)
            var level = (matches[2] == "=") ? 1 : 2
            var header : [AnyObject] = ["header", ["level" : level]]
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
        self.block["horizRule"] = {
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
        self.block["para"] = {
            (block : Line, var next : Lines) -> [AnyObject]? in
            var arr : [AnyObject] = ["para"]
            arr += self.processInline(block._text, patterns: nil)
            return arr
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