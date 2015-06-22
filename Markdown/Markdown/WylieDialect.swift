//
//  WylieDialect.swift
//  Markdown
//
//  Created by Leanne Northrop on 14/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//
import Foundation
import UChen

class WylieDialect : GruberDialect {
    override init() {
        super.init()
        
        self.inline["~"] =  {
            ( text : String ) -> [AnyObject] in
            // Inline wylie block.
            let pattern : String = "(~+)(([\\s\\S\\W\\w]*?)\\1)"
            if text.isMatch(pattern) {
                var matches : [String] = text.matches(pattern)
                var wylie = matches[3]
                var uchenUnicodeStr = UChen().translate(wylie)
                var length : Int = count(matches[0])
                return [length, [ "uchen", [ "class": "tibetan_uchen", "wylie" : wylie], uchenUnicodeStr ]]
            }
            else {
                // TODO: No matching end code found - warn!
                return [ 1, "~" ];
            }
        }
        
        self.block["wylie"] = {
            (line : Line, var next : Lines) -> [AnyObject]? in
            var ret = []
            var re = "^(:::\n*)([\\s\\S\\W\\w\n\r]*?)(\\1)"
            var reStartBlock = "^:::\n*"
            var reEndBlock = "([\\s\\S\\W\\w\n\r]*?)(\n*:::)(.*)"
            
            var block = line._text
            if !block.isMatch(reStartBlock) {
                return nil
            }
            
            var wylie : String? = "";
            var groups = block.matches(re)
            if groups != nil && !groups.isEmpty {
                wylie = groups[2]
            } else {
                // wylie is over several lines
                var seen = false
                var b = block.replace(":::", replacement: "");
                while !seen {
                    if b.isMatch(reEndBlock) {
                        var m = b.matches(reEndBlock)
                        var str : String = m[1]
                        wylie = wylie! + str
                        seen = true
                    } else {
                        wylie = wylie! + b
                        if !next.isEmpty() {
                            b = next.shift()!._text
                        } else {
                            b = ""
                            seen = true
                            // user supplied invalid syntax of no more text lines
                            // and forgot to end block with :::
                        }
                    }
                }
            }
            
            if wylie != nil && count(wylie!) > 0 {
                var uchenUnicodeStr = UChen().translate(wylie!)
                println(uchenUnicodeStr)
                return  [["uchen_block", ["class": "uchen", "wylie": wylie!], uchenUnicodeStr]]
            } else {
                return []
            }
        }
            
        buildBlockOrder()
        buildInlinePatterns()
    }
}