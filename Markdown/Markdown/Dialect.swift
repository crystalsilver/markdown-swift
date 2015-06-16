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
    var __patterns__ : String
    var __inline_call__ : (Line,String?)->[AnyObject]
    var __block_call__ : (Line,Lines)->[AnyObject]?
    var __order__ : [String]
    
    init() {
        self.__patterns__ = ""
        self.__order__ = []
        self.__inline_call__ = {
            (Line,String) -> [AnyObject] in
            return []
        }
        self.__block_call__ = {
            (Line,Lines)->[AnyObject]? in
            return nil
        }
    }
    
    func buildBlockOrder() {
        var blockKeys : [String] = []
        for key in block.keys {
            if key == "__order__" || key == "__call__" {
                self.__block_call__ = self.block["__call__"]!
                continue
            }
            blockKeys.append(key)
        }
        self.__order__ = blockKeys
    }
    
    func buildInlinePatterns() {
        var patterns : [String] = []
    
        for key in inline.keys {
            // __foo__ is reserved and not a pattern
            if key.isMatch("^__.*__$") {
                if key.isMatch("^__call__$") {
                    let me = self
                    let fn : (Line,String?)->[AnyObject]
                    fn = __inline_call__
                    self.__inline_call__ = {
                        (text:Line, pattern:String?) -> [AnyObject] in
                        if pattern != nil {
                            return fn(text, pattern!)
                        }
                        else {
                            return fn(text, me.__patterns__)
                        }
                    }
                }
                continue
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
    }
}