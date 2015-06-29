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
    var __inline_call__ : (String,String?)->[AnyObject]
    var __block_call__ : (Line,Lines)->[AnyObject]?
    var __order__ : [String]
    var __states : [String:[AnyObject]] = [:]
    // A robust regexp for matching URLs. Thanks: https://gist.github.com/dperini/729294
    let URL_REG_EX : String = "(?:(?:https?|ftp):\\/\\/)(?:\\S+(?::\\S*)?@)?(?:(?!(?:10|127)(?:\\.\\d{1,3}){3})(?!(?:169\\.254|192\\.168)(?:\\.\\d{1,3}){2})(?!172\\.(?:1[6-9]|2\\d|3[0-1])(?:\\.\\d{1,3}){2})(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}(?:\\.(?:[1-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))|(?:(?:[a-z\u{00a1}-\u{ffff0}-9]-*)*[a-z\u{00a1}-\u{ffff0}-9]+)(?:\\.(?:[a-z\u{00a1}-\\u{ffff0}-9]+-?)*[a-z\u{00a1}-\u{ffff0}-9]+)*(?:\\.(?:[a-z\u{00a1}-\u{ffff}]{2,})))(?::\\d{2,5})?(?:\\/[^\\s]*)?"

    init() {
        self.__patterns__ = ""
        self.__order__ = []
        self.__inline_call__ = {
            (text : String, pattern : String?) -> [AnyObject] in
            return []
        }
        self.__block_call__ = {
            (line : Line,var next : Lines)->[AnyObject]? in
            return nil
        }
        self.__states["em_state"] = []
        self.__states["strong_state"] = []
    }
    
    func buildBlockOrder() {
        var blockKeys : [String] = []
        let sortedKeys = Array(self.block.keys).sorted(<)
        for key in sortedKeys {
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
        let me = self
        let fn : (String,String?)->[AnyObject]
        fn = __inline_call__
        self.__inline_call__ = {
            (text:String, pattern:String?) -> [AnyObject] in
            if pattern != nil {
                return fn(text, pattern!)
            }
            else {
                return fn(text, me.__patterns__)
            }
        }
    }
    
    func oneElement(text : String, var patterns : String) -> [AnyObject] {
        var res : [AnyObject] = []
        var regEx = "([\\s\\S]*?)(" + patterns + ")"
        
        var matches = text.matches(regEx)
        
        if (!text.isMatch(regEx)) {
            // Just boring text
            return [count(text), text]
        }
        else if matches.count >= 2 && !matches[1].isBlank() {
            return [count(matches[1]), matches[1]]
        }
        
        if matches.count >= 3 {
            var handlerRegEx = matches[2]
            if self.inline[handlerRegEx] != nil {
                res = self.inline[handlerRegEx]!(text)
            }
        }
        // Default for now to make dev easier. just slurp special and output it.
        res = !res.isEmpty ? res : [count(matches[2]), matches[2]]

        return res
    }
    
    func processInline(line : String, patterns: String?)->[AnyObject] {
        return self.__inline_call__(line, patterns)
    }
    
    // Meta Helper/generator method for em and strong handling
    func strong_em(tag : String, md : String) -> (String) -> [AnyObject] {
        var state_slot = tag + "_state"
        var other_slot = tag == "strong" ? "em_state" : "strong_state";
        
        class CloseTag {
            var len_after:Int
            var name:String
            
            init(len:Int,name:String) {
                self.len_after = len
                self.name = "close_" + name
            }
        }
        
        var me = self
        func anon(text : String) -> [AnyObject] {
            if !me.__states[state_slot]!.isEmpty &&
                me.__states[state_slot]![0] as? String != nil &&
                me.__states[state_slot]![0] as! String == md {
                // Most recent em is of this type
                me.__states[state_slot]?.removeAtIndex(0)
                
                // "Consume" everything to go back to the recursion in the else-block below
                var length : Int = count(text)
                var closeTagLength : Int = length - count(md)
                return [length, CloseTag(len:closeTagLength, name: md)]
            } else {
                // Store a clone of the em/strong states
                var other : [AnyObject] = me.__states[other_slot]!
                var state : [AnyObject] = me.__states[state_slot]!
                
                me.__states[state_slot]?.insert(md, atIndex: 0)
                
                // Recurse
                var res = me.processInline(text.substr(count(md)), patterns: nil)
                var last : AnyObject? = !res.isEmpty ? res.last : nil
                
                var check : AnyObject? =  !me.__states[state_slot]!.isEmpty ? me.__states[state_slot]?.removeAtIndex(0) : nil
                if ( last is CloseTag ) {
                    res.removeLast()
                    var consumed = count(text) - (last as! CloseTag).len_after
                    var arr : [AnyObject] = [tag]
                    arr += res
                    return [consumed, arr]
                }
                else {
                    // Restore the state of the other kind. We might have mistakenly closed it.
                    me.__states[other_slot] = other
                    me.__states[state_slot] = state
                    
                    // We can't reuse the processed result as it could have wrong parsing contexts in it.
                    return [count(md), md]
                }
            }
        }
        
        return anon
    }
    
    func loop_re_over_block(regEx : String, var block : String, cb : ([String]) -> ()) -> String {
        // Dont use /g regexps with this
        while (count(block) > 0) && block.isMatch(regEx) {
            var m = block.matches(regEx)
            block = block.substr(count(m[0]))            
            cb(m)
        }
        
        return block
    }
    
    func inline_until_char(text : String, want : Character) -> [AnyObject] {
        var consumed = 0
        var nodes : [AnyObject] = []
    
        while true {
            let c : Character = text[consumed]
            if c == want {
                // Found the character we were looking for
                consumed++
                return [consumed, nodes]
            }
    
            if consumed >= count(text) {
                // No closing char found. Abort.
                return [consumed, [], nodes]
            }
    
            var res = oneElement(text.substr(consumed), patterns: __patterns__)
            consumed += res[0] as! Int
            // Add any returned nodes.
            nodes.extend(res[1...res.count-1])
        }
    }
}