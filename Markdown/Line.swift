//
//  Line.swift
//  Markdown
//
//  Created by Leanne Northrop on 14/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation

struct Line : Printable {
    var _lineNumber:Int = -1
    var _text:String = ""
    var _trailing:String = "\n\n"
    var description:String {
        get {
            return self._lineNumber.description + " " + self._text + self._trailing
        }
    }
    
    init(text:String, lineNumber:Int = -1, trailing:String = "\n\n"){
        self._lineNumber = lineNumber
        self._trailing = trailing
        self._text = text
    }
}