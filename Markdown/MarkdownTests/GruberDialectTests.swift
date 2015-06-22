//
//  GruberDialectTests.swift
//  Markdown
//
//  Created by Leanne Northrop on 16/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import XCTest

class GruberDialectTests: XCTestCase {
    var gruberDialect : GruberDialect! = nil
    
    override func setUp() {
        super.setUp()
        self.gruberDialect = GruberDialect()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSimpleLevel1HeaderBlock() {
        var line = Line(text: "# This is a level 1 heading", lineNumber: 0, trailing: "\n\n")
        
        var result = self.gruberDialect.block["atxHeader"]!(line, Lines())
        
        XCTAssertNotNil(result)
        var r : [AnyObject] = result![0] as! [AnyObject]
        XCTAssertTrue(r.count > 0)
        XCTAssertEqual("header", r[0] as! String)
        XCTAssertEqual("This is a level 1 heading", r[2] as! String)
        XCTAssertNotNil(r[1])
        XCTAssertNotNil(r[1]["level"])
        XCTAssertEqual(1, r[1]["level"] as! Int)
    }
    
    func testSimpleExtLevel1HeaderBlock() {
        var line = Line(text: "This is a level 1 heading\n======================", lineNumber: 0, trailing: "\n\n")
        
        var result = self.gruberDialect.block["extHeader"]!(line, Lines())
        
        XCTAssertNotNil(result)
        var r : [AnyObject] = result![0] as! [AnyObject]
        XCTAssertTrue(r.count > 0)
        XCTAssertEqual("header", r[0] as! String)
        XCTAssertEqual("This is a level 1 heading", r[2] as! String)
        XCTAssertNotNil(r[1])
        XCTAssertNotNil(r[1]["level"])
        XCTAssertEqual(1, r[1]["level"] as! Int)
    }
    
    func testSimpleExtLevel2HeaderBlock() {
        var line = Line(text: "This is a level 2 heading\n--------------------", lineNumber: 0, trailing: "\n\n")
        
        var result = self.gruberDialect.block["extHeader"]!(line, Lines())
        
        XCTAssertNotNil(result)
        var r : [AnyObject] = result![0] as! [AnyObject]
        XCTAssertTrue(r.count > 0)
        XCTAssertEqual("header", r[0] as! String)
        XCTAssertEqual("This is a level 2 heading", r[2] as! String)
        XCTAssertNotNil(r[1])
        XCTAssertNotNil(r[1]["level"])
        XCTAssertEqual(2, r[1]["level"] as! Int)
    }
    
    func testSimpleParagraphContainingEmphasizedText() {
        var line = Line(text: "This is *emphasised text* with some following text.", lineNumber: 0, trailing: "\n\n")
        
        var result = self.gruberDialect.block["para"]!(line, Lines())
        
        XCTAssertNotNil(result)
        var r = result!
        XCTAssertTrue(r.count > 0)
        XCTAssertEqual("para", r[0] as! String)
        XCTAssertEqual("This is ", r[1] as! String)
        XCTAssertNotNil(r[2])
        var e = r[2] as! [AnyObject]
        XCTAssertEqual("em", e[0] as! String)
        XCTAssertEqual("emphasised text", e[1] as! String)
        XCTAssertEqual(" with some following text.", r[3] as! String)
    }
    
    func testSimpleParagraphContainingInlineCode() {
        var line = Line(text: "This is `var v = 3; inline code` with some following text.", lineNumber: 0, trailing: "\n\n")
        
        var result = self.gruberDialect.block["para"]!(line, Lines())
        println(result!)
        XCTAssertNotNil(result)
        var r = result!
        XCTAssertTrue(r.count > 0)
        XCTAssertEqual("para", r[0] as! String)
        XCTAssertEqual("This is ", r[1] as! String)
        XCTAssertNotNil(r[2])
        var e = r[2] as! [AnyObject]
        XCTAssertEqual("inlinecode", e[0] as! String)
        XCTAssertEqual("var v = 3; inline code", e[1] as! String)
        XCTAssertEqual(" with some following text.", r[3] as! String)
    }
    
    /*func testSimpleParagraphContainingLineBreak() {
        var line = Line(text: "This is some text.\nWith a line break", lineNumber: 0, trailing: "\n\n")
        
        var result = self.gruberDialect.block["para"]!(line, Lines())
        
        XCTAssertNotNil(result)
        var r = result!
        XCTAssertTrue(r.count > 0)
        XCTAssertEqual("para", r[0] as! String)
        XCTAssertEqual("This is some text.  ", r[1] as! String)
        XCTAssertNotNil(r[2])
        var e = r[2] as! [AnyObject]
        XCTAssertEqual("linebreak", e[1] as! String)
        XCTAssertEqual("With a line break", r[3] as! String)
    }*/

}
