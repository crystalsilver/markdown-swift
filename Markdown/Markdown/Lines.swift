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
        
        // Match until the end of the string, a newline followed by #, or two or more newlines.
        /* original javascript var re = "([\\s\\S]+?)($|\\n#|\\n(?:\\s*\\n|$)+)"
        var lines = source.matches(re)
        for var i = 0; i < lines.count; i = i + 3 {
            if (lines[i] == "\n#") {
                _lines.append(Line(text: lines[i+1],
                                   lineNumber: line_no,
                                   trailing: "\n"))
                lines[i+3] = "#" + lines[i+3]
            } else {
                _lines.append(Line(text: lines[i+1],
                                   lineNumber: line_no,
                                   trailing: lines[i+2]))
            }
            line_no += lines[i].split("\n").count - 1
        }*/
        
        // simplify to not split on regular expression groups until find use case
        var storedLines : [Line] = []
        source.enumerateLines({
            (line: String, inout stop: Bool) -> () in
            if line.isEmpty || line.isBlank() {
                line_no++
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