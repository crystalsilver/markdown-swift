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
    
    func testInitBlocks() {
        var text : String = "# Getting Started\n\n\n- a\n- b\n- c\n\ndearejhjh"
        
        var linesStruct : Lines = Lines(source: text)
        var lines : [Line] = linesStruct._lines
        println(linesStruct.description)
        
        var firstLine = lines[0]
        XCTAssertEqual("# Getting Started", firstLine._text)
        XCTAssertEqual("\n\n\n", firstLine._trailing)
        XCTAssertEqual(1, firstLine._lineNumber)
        
        var secondLine = lines[1]
        XCTAssertEqual("- a\n- b\n- c", secondLine._text)
        XCTAssertEqual("\n\n", secondLine._trailing)
        XCTAssertEqual(4, secondLine._lineNumber)
        
        var thirdLine = lines[2]
        XCTAssertEqual("dearejhjh", thirdLine._text)
        XCTAssertEqual("\n", thirdLine._trailing)
        XCTAssertEqual(8, thirdLine._lineNumber)
    }
}
