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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    
    func testImport() {
        var u = UChen()
        let s = u.translate("sang gye")
        XCTAssertEqual("སང་གྱེ", s, "Not producing expected output")
    }
    
}
