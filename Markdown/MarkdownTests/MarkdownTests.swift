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
    
}
