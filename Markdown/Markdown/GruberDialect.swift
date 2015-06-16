//
//  GruberDialect.swift
//  Markdown
//
//  Created by Leanne Northrop on 16/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation

func gruberInlineCode(text : String) -> [AnyObject] {
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

func gruberLineBreak(text : String) -> [AnyObject] {
    return [3, ["linebreak"]]
}

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
                    text = strCount >= count(str) ? "" : text.substr(0, length: strCount)
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
                
                return [ header ];
            }
        }
        
        self.inline["`"] = gruberInlineCode
        self.inline["  \n"] = gruberLineBreak
        
        buildBlockOrder()
        buildInlinePatterns()
    }
}