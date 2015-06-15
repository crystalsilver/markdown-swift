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
                    let matchedTextRange:NSRange = result.rangeAtIndex(i)
                    var s = searchString.substr(matchedTextRange.location,length:matchedTextRange.length-1)
                    matchedStrings += [s]
                }
            }
            return matchedStrings
        }
        return nil
    }
    
    public subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    public func substr(startIndex : Int, length : Int) -> String {
        if length > 0 {
            return self[startIndex...(startIndex+length)]
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
}