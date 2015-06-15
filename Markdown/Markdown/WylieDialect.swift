//
//  WylieDialect.swift
//  Markdown
//
//  Created by Leanne Northrop on 14/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//
import Foundation
import UChen

func inlineWylie( text : String ) -> [AnyObject] {    
    // Inline wylie block.
    let pattern : String = "(~+)(([\\s\\S\\W\\w]*?)\\1)"
    if text.isMatch(pattern) {
        var matches : [String] = text.matches(pattern)
        var wylie = matches[3]
        var uchenUnicodeStr = UChen().translate(wylie)
        var length : Int = count(matches[0]) + count(wylie)
        return [length.description, [ "uchen", [ "style": "font-size:72pt;font-family:Uchen_05"], uchenUnicodeStr ]]
    }
    else {
        // TODO: No matching end code found - warn!
        return [ 1, "~" ];
    }
}

func blockWylie(line : Line, var next : Lines) -> [AnyObject]? {
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

class WylieDialect : Dialect {
    override init() {
        super.init()
        self.inline["~"] = inlineWylie
        self.block["wylie"] = blockWylie
        //buildBlockOrder()
        //buildInlinePatterns()
    }
}