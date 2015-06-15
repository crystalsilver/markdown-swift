//
//  Line.swift
//  Markdown
//
//  Created by Leanne Northrop on 14/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation

struct Line {
    private var _lineNumber:Int = -1
    private var _text:String = ""
    private var _trailing:String = "\n\n"
    
    init(text:String, lineNumber:Int = -1, trailing:String = "\n\n"){
        self._lineNumber = lineNumber
        self._trailing = trailing
        self._text = text
    }
    
    func lineNumber() -> Int { return self._lineNumber }
    func trailing() -> String { return self._trailing }
    func text() -> String { return self._text }
}