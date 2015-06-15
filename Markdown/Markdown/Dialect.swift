//
//  Dialect.swift
//  Markdown
//
//  Created by Leanne Northrop on 14/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation

class Dialect {
    var inline : Dictionary<String, (String) -> [AnyObject]> = [:]
    var block : Dictionary<String, (Line,Lines) -> [AnyObject]?> = [:]
    var blockKeys : [String] = []
    var __patterns__ : String
    var __call__ : (String,String?)->[String]
    
    init() {
        self.__patterns__ = ""
        self.__call__ = {
            (text:String, pattern:String?) -> [String] in
            return []
        }
    }
    
    func buildBlockOrder() {
        self.blockKeys = [];
        for key in block.keys {
            if key == "__order__" || key == "__call__" {
                continue
            }
            blockKeys.append(key)
        }
    }
    
    func buildInlinePatterns() {
        var patterns : [String] = []
    
        for key in inline.keys {
            // __foo__ is reserved and not a pattern
            if key.isMatch("^__.*__$") {
                continue;
            }
            
            // Prep regular expressions - dislike this but replace with reg ex groups not working at present
            var l = key.replace("\n", replacement: "\\n")
            var escapeThese : [String] = ["\\", ".", "*", "+", "?", "^", "$", "|", "(", ")", "[", "]", "{", "}"]
            for str in escapeThese {
                l = l.replace(str, replacement: "\\" + str)
            }
            
            patterns.append(count(key) == 1 ? l : "(?:" + l + ")" )
        }

        self.__patterns__  = "|".join(patterns)
        var __patterns__ = self.__patterns__
        var fn = self.__call__
        self.__call__ = {
            (text:String, pattern:String?) -> [String] in
            if pattern != nil {
                return fn(text, pattern)
            }
            else {
                return fn(text, __patterns__)
            }
        }
    }
}