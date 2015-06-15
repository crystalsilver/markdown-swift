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
    
    init(var input:String) {
        
        // Normalize linebreaks to \n.
        input = input.replace("\r\n", replacement: "\n");
        
        var line_no = 1;
        var contents : [String] = input.componentsSeparatedByString("\n")
        for var i = 0; i < contents.count; i++ {
            self._lines.append(Line(text: contents[i], lineNumber: line_no))
        }
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