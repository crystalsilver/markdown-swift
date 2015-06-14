//
//  WylieDialect.swift
//  Markdown
//
//  Created by Leanne Northrop on 14/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//
import Foundation
import UChen

extension String {
    public subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    public func substr(startIndex:Int, length:Int) -> String {
        return self[startIndex...(startIndex+length)]
    }
}

func inlineWylie( text : String ) -> [AnyObject] {
    func isMatch(searchString : String, pattern : String)->Bool{
        let match = searchString.rangeOfString(pattern, options: .RegularExpressionSearch)
        return match != nil
    }
    
    func matches(searchString : String, pattern : String)->[String]{
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
        return []
    }
    
    // Inline wylie block.
    let pattern : String = "(~+)(([\\s\\S\\W\\w]*?)\\1)"
    if isMatch(text, pattern) {
        var matches : [String] = matches(text, pattern)
        var wylie = matches[3]
        var uchenUnicodeStr = UChen().translate(wylie)
        var length : Int = count(matches[0]) + count(wylie)
        return [length.description, [ "uchen", [ "style": "font-size:72pt;font-family:Uchen_05"], uchenUnicodeStr ] ];
    }
    else {
        // TODO: No matching end code found - warn!
        return [ 1, "~" ];
    }
}

struct WylieDialect {
    let inline : Dictionary<String, (String) -> [AnyObject]> = ["~":inlineWylie]
}