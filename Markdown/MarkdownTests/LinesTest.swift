//
//  LinesTest.swift
//  Markdown
//
//  Created by Leanne Northrop on 15/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import XCTest

class LinesTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testInitLeadingBlankLines() {
        var text : String = "\n\n\n# Getting Started!\n  \nJason"
        
        var linesStruct : Lines = Lines(source: text)
        var lines : [Line] = linesStruct._lines
        println(lines)
        
        var firstLine = lines[0]
        XCTAssertEqual("# Getting Started!", firstLine._text)
        XCTAssertEqual("\n  \n", firstLine._trailing)
        XCTAssertEqual(4, firstLine._lineNumber)
        
        var secondLine = lines[1]
        XCTAssertEqual("Jason", secondLine._text)
        XCTAssertEqual("\n", secondLine._trailing)
        XCTAssertEqual(6, secondLine._lineNumber)
    }
}
