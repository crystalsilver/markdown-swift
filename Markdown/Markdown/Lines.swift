//
//  Lines.swift
//  Markdown
//
//  Created by Leanne Northrop on 14/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation

struct Lines {
    var _lines : [Line] = []
    
    init() {}
    
    init(var source:String) {
        // Normalize linebreaks to \n.
        source = source.replace("\r\n", replacement: "\n");
        
        var line_no = 1
        
        // skip (but count) leading blank lines
        var hasLeadingBlankLinesRegEx = "^(\\s*\n)"
        if source.isMatch(hasLeadingBlankLinesRegEx) {
            var matches : [String] = source.matches(hasLeadingBlankLinesRegEx)
            var lines : [String] = matches[0].split("\n")
            line_no += lines.count - 1
            
            let startIndex = advance(source.startIndex, count(matches[0]))
            source = source.substringFromIndex(startIndex)
        }
        
        // simplified from js lib to not split on regular expression groups until find use case
        var storedLines : [Line] = []
        source.enumerateLines({
            (line: String, inout stop: Bool) -> () in
            if line.isEmpty || line.isBlank() {
                line_no++
                if !storedLines.isEmpty {
                    var previousLine : Line = storedLines.removeLast()
                    storedLines.append(Line(text: previousLine._text,
                                            lineNumber: previousLine._lineNumber,
                                            trailing: previousLine._trailing + line + "\n"))
                }
            } else {
                storedLines.append(Line(text: line,
                                        lineNumber: line_no++,
                                        trailing: "\n"))
            }
        })
        self._lines = storedLines
    }
    
    func line(index : Int) -> Line {
        return self._lines[index]
    }
    
    func lines() -> [Line] {
        return self._lines
    }
    
    func isEmpty() -> Bool {
        return self._lines.isEmpty
    }
    
    mutating func shift() -> Line? {
        if (!self._lines.isEmpty) {
            return self._lines.removeAtIndex(0)
        }
        else {
            return nil
        }
    }
    
    mutating func unshift (elements: (Line)...) -> Int {
        self._lines = elements + self._lines
        return self._lines.count
    }
}