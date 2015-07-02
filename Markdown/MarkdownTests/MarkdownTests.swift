//
//  MarkdownTests.swift
//  MarkdownTests
//
//  Created by Leanne Northrop on 14/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import UIKit
import XCTest
import UChen

class MarkdownTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMarkdown() {
        XCTAssertNotNil(Markdown(dialectName: "wylie"))
    }
    
    func testProcessBlockCallsWylieDialectBlockHandler() {
        var md = Markdown(dialectName: "wylie")
        var text : String = ":::rdorje sangaye jinpa losal rinpoche ddddddderdorje sangaye:::"
        var lines : Lines = Lines()
        var result = md.processBlock(Line(text: text, lineNumber: 0, trailing: "\n"),
                                     next: &lines)
        
        XCTAssertNotNil(result, "Expected a wylie block")
        XCTAssertFalse(result!.isEmpty, "Expected a wylie block node")
        var jsonML = result![0] as! [AnyObject]
        XCTAssertEqual("uchen_block", jsonML[0] as! String, "Expecting uchen JsonML block")
        XCTAssertEqual("རྡོརྗེ་སངཡེ་ཇིནཔ་ལོསལ་རིནཔོཆེ་དདདདདདདེརྡོརྗེ་སངཡེ", jsonML[2] as! String, "Not translated correctly")
        
        var attr : [String:String] = jsonML[1] as! [String:String]
        XCTAssertNotNil(attr["class"], "Class attribute missing?")
        XCTAssertEqual("uchen", attr["class"]!, "Class attribute missing?")
        XCTAssertNotNil(attr["wylie"], "Wylie attribute missing?")
        XCTAssertEqual("rdorje sangaye jinpa losal rinpoche ddddddderdorje sangaye", attr["wylie"]!, "Wylie attribute missing?")
    }
    
    func testSimpleWylieBlockParse() {
        var md = Markdown(dialectName: "wylie")
        var text : String = ":::rdorje sangaye jinpa losal rinpoche ddddddderdorje sangaye:::"
        
        var result = md.parse(text)
        
        XCTAssertFalse(result.isEmpty)
        XCTAssertEqual("markdown", result[0] as! String)
        XCTAssertEqual(3, result.count)
        var node = result[2] as! [AnyObject]
        var jsonML = node[0] as! [AnyObject]
        XCTAssertEqual("uchen_block", jsonML[0] as! String, "Expecting uchen JsonML block")
        XCTAssertEqual("རྡོརྗེ་སངཡེ་ཇིནཔ་ལོསལ་རིནཔོཆེ་དདདདདདདེརྡོརྗེ་སངཡེ", jsonML[2] as! String, "Not translated correctly")
        
        var attr : [String:String] = jsonML[1] as! [String:String]
        XCTAssertNotNil(attr["class"], "Class attribute missing?")
        XCTAssertEqual("uchen", attr["class"]!, "Class attribute missing?")
        XCTAssertNotNil(attr["wylie"], "Wylie attribute missing?")
        XCTAssertEqual("rdorje sangaye jinpa losal rinpoche ddddddderdorje sangaye", attr["wylie"]!, "Wylie attribute missing?")
    }
}
