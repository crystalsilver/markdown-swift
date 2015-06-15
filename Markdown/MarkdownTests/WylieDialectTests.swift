//
//  WylieDialectTests.swift
//  Markdown
//
//  Created by Leanne Northrop on 14/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Markdown
import XCTest

class WylieDialectTests: XCTestCase {
    var wylieDialect: WylieDialect! = nil
    
    override func setUp() {
        super.setUp()
        self.wylieDialect = WylieDialect()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInline() {
        var result = self.wylieDialect.inline["~"]!("~rdorje~")
        XCTAssertEqual("14", result[0] as! String, "Expecting length of text to be replaced")
        
        var jsonML : [AnyObject] = result[1] as! [AnyObject]
        XCTAssertEqual("uchen", jsonML[0] as! String, "Expecting uchen JsonML")
        XCTAssertEqual("རྡོརྗེ", jsonML[2] as! String, "Not translated correctly")
        
        var attr : [String:String] = jsonML[1] as! [String:String]
        XCTAssertNotNil(attr["style"], "Style attribute missing?")
        XCTAssertEqual("font-size:72pt;font-family:Uchen_05", attr["style"]!, "Style attribute missing?")
    }
    
    func testBlockReturnsNilWhenNoMatch() {
        var f : (Line,Lines) -> [AnyObject]? = self.wylieDialect.block["wylie"]!
        
        var result = f(Line(text: "this shouldn't match at all",lineNumber:0),Lines())
        
        XCTAssertNil(result, "Should return nil when line text does not match")
    }

    func testBlock() {
        var text : String = ":::rdorje sangaye jinpa losal rinpoche ddddddderdorje sangaye:::"
        var f : (Line,Lines) -> [AnyObject]? = self.wylieDialect.block["wylie"]!
        
        var result : [AnyObject]? = f(Line(text: text,lineNumber:0),Lines())
        
        var jsonML : [AnyObject] = result![0] as! [AnyObject]
        XCTAssertEqual("uchen_block", jsonML[0] as! String, "Expecting uchen JsonML block")
        XCTAssertEqual("རྡོརྗེ་སངཡེ་ཇིནཔ་ལོསལ་རིནཔོཆེ་དདདདདདདེརྡོརྗེ་སངཡེ", jsonML[2] as! String, "Not translated correctly")
        
        var attr : [String:String] = jsonML[1] as! [String:String]
        XCTAssertNotNil(attr["class"], "Class attribute missing?")
        XCTAssertEqual("uchen", attr["class"]!, "Class attribute missing?")
        XCTAssertNotNil(attr["wylie"], "Wylie attribute missing?")
        XCTAssertEqual("rdorje sangaye jinpa losal rinpoche ddddddderdorje sangaye", attr["wylie"]!, "Wylie attribute missing?")
    }
    
    func testTrailingBlock() {
        var f : (Line,Lines) -> [AnyObject]? = self.wylieDialect.block["wylie"]!
        var firstBlockLine = Line(text: ":::rdorje", lineNumber:1)
        var nextBlockLines = Lines()
        nextBlockLines._lines.append(Line(text: "sanggye",   lineNumber:2))
        nextBlockLines._lines.append(Line(text: "rdorje\n:::",lineNumber:3))
        
        var result : [AnyObject]? = f(firstBlockLine, nextBlockLines)
        
        var jsonML : [AnyObject] = result![0] as! [AnyObject]
        XCTAssertEqual("uchen_block", jsonML[0] as! String, "Expecting uchen JsonML block")
        XCTAssertEqual("རྡོརྗེསངགྱེརྡོརྗེ", jsonML[2] as! String, "Not translated correctly")
        
        var attr : [String:String] = jsonML[1] as! [String:String]
        XCTAssertNotNil(attr["class"], "Class attribute missing?")
        XCTAssertEqual("uchen", attr["class"]!, "Class attribute missing?")
        XCTAssertNotNil(attr["wylie"], "Wylie attribute missing?")
        XCTAssertEqual("rdorjesanggyerdorje", attr["wylie"]!, "Wylie attribute missing?")
    }
}
