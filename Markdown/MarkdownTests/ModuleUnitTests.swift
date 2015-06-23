//
//  ModuleUnitTests.swift
//  Markdown
//
//  Created by Leanne Northrop on 18/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import XCTest
import Markdown

class ModuleUnitTests: XCTestCase {
    let bundle = NSBundle(forClass: ModuleUnitTests.self)
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testHeaders() {
        runTests("headers")
    }
    
    func testWylie() {
        runTests("wylie")
    }

    func runTests(subDir:String) -> () {
        let tests : [String:String] = getFilenames(subDir)
        for (test,file) in tests {
            let testName = test
            let mdInputFile = file
            let mdOutputFile = file.replace(".text", replacement: ".xml")
            let markdown = readFile(mdInputFile, type: "text")
            if !markdown.isBlank() {
                let expected = readFile(mdOutputFile, type: "xml")
                let md : Markdown = Markdown()
                let result : [AnyObject] = md.parse(markdown)
                if !expected.isBlank() {
                    let xml = XmlRenderer().toXML(result, includeRoot: true)
                    XCTAssertEqual(expected, xml, testName + " test failed")
                }
                let expectedHTML = readFile(file.replace(".text", replacement: ".html"), type: "html")
                if !expectedHTML.isBlank() {
                    let html = HtmlRenderer().toHTML(result)
                    XCTAssertEqual(expectedHTML, html, testName + " HTML test failed")
                }
            }
        }
    }
    
    func getFilenames(subDir:String) -> [String:String] {
        let resourcePath : String = bundle.resourcePath!
        let bundlePath = resourcePath + "/assets/" + subDir
        let fm = NSFileManager.defaultManager()
        let contents : [AnyObject]? = fm.contentsOfDirectoryAtPath(bundlePath, error: nil)
        if contents != nil {
            var files : [String:String] = [:]
            for var i = 0; i < contents!.count; i++ {
                var filename : String = contents![i] as! String
                if filename.isMatch("text$") {
                    let path : String = resourcePath + "/assets/" + subDir + "/" + filename
                    files[filename.replace(".text", replacement:"")] = path
                }
            }
            return files
        }
        return [:]
    }
    
    func readFile(path:String, type:String) -> String {
        let content = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
        return content
    }
}