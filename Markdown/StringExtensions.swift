//
//  StringExtensions.swift
//  Markdown
//
//  Created by Leanne Northrop on 14/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation

extension String {
    public func isMatch(pattern : String)->Bool{
        let searchString:String = self
        let match = searchString.rangeOfString(pattern, options: .RegularExpressionSearch)
        return match != nil
    }
    
    public func matches(pattern : String)->[String]!{
        let searchString:String = self
        var ierror:NSError?
        let regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.allZeros, error: &ierror)
        
        if (ierror == nil){
            let matches = regex!.matchesInString(searchString, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(searchString)))
            var matchedStrings:[String] = []
            for match in matches {
                var result : NSTextCheckingResult = match as! NSTextCheckingResult
                for var i = 0; i < result.numberOfRanges; i++ {
                    let matchedTextRange = result.rangeAtIndex(i)
                    var s = searchString.substringWithRange(matchedTextRange)
                    matchedStrings += [s]
                }
            }
            return matchedStrings
        }
        return nil
    }
    
    public func substringWithRange(range : NSRange) -> String {
        if range.length == 0 {
            return ""
        } else {
            let ix1 = advance(self.startIndex, range.location)
            let ix2 = advance(ix1,range.length-1)
            let r = ix1...ix2
            return self[r]
        }
    }
    
    public func substr(startIndex : Int, length : Int) -> String {
        if length > 0 {
            let ix1 = advance(self.startIndex, startIndex)
            let ix2 = advance(ix1,length)
            if ix2 < self.endIndex {
                let r = ix1...ix2
                return self[r]
            } else {
                return ""
            }
        } else {
            return self
        }
    }
    
    public func substr(startIndex : Int) -> String {
        if startIndex > 0 {
            let ix1 = advance(self.startIndex, startIndex)
            return self.substringFromIndex(ix1)
        } else {
            return self
        }
    }
    
    public func replaceByRegEx(pattern : String, replacement : String)->String!{
        let searchString:String = self
        var error:NSError?
        let regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.allZeros, error: &error)
        if (error == nil){
            let replacedString = regex!.stringByReplacingMatchesInString(searchString, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(searchString)), withTemplate: replacement)
            return replacedString
        }
        return nil
    }
    
    public func replace(find : String, replacement : String)->String!{
        let searchString:String = self
        return searchString.stringByReplacingOccurrencesOfString(find, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    public func split(separator: String) -> [String] {
        return self.componentsSeparatedByString(separator)
    }
    
    public func isBlank() -> Bool {
        var str = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return count(str) == 0
    }
    
    public subscript (i: Int) -> Character {
        var idx : String.Index = advance(self.startIndex, i)
        if idx < self.endIndex {
            return self[idx]
        } else {
            return Character(" ")
        }
    }
    
    public subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    public subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}