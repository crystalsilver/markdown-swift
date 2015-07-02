//
//  UChenTests.swift
//  UChenTests
//
//  Created by Leanne Northrop on 13/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import XCTest
import Markdown

class UChenTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUchenIsDefined() {
        var uchen : UChen = UChen()
    }
    
    func testTranslate() {
        var uchen = UChen()
        XCTAssertEqual("སང་གྱེ", uchen.translate("sang gye"), "Not producing expected output")
        XCTAssertEqual("དུསུམ", uchen.translate("dusum"), "Wrong uchen translation for 'dusum'")
        XCTAssertEqual("དུསུམ་ཁེཡནཔ", uchen.translate("dusum kheynpa"), "Wrong uchen translation for sang gye sang gye rdorje")
        XCTAssertEqual("࿅", uchen.translate("~dorje"), "Wrong uchen translation for '~dorje'")
        XCTAssertEqual("࿅", uchen.translate("~dorje"), "Wrong uchen translation for '~dorje'")
    }
    
}
