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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInline() {
        var w : WylieDialect = WylieDialect()
        var result = w.inline["~"]!("~rdorje~")
        XCTAssertEqual("14", result[0] as! String, "Expecting length of text to be replaced")
        
        var jsonML : [AnyObject] = result[1] as! [AnyObject]
        XCTAssertEqual("uchen", jsonML[0] as! String, "Expecting uchen JsonML block")
        XCTAssertEqual("རྡོརྗེ", jsonML[2] as! String, "Not translated correctly")
        
        var attr : [String:String] = jsonML[1] as! [String:String]
        XCTAssertNotNil(attr["style"], "Style attribute missing?")
        XCTAssertEqual("font-size:72pt;font-family:Uchen_05", attr["style"]!, "Style attribute missing?")
    }

}
