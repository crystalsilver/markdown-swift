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
    
    let PARA_BLOCK_HANDLER_KEY : String = GruberDialect.PARA_HANDLER_KEY
    let ATX_HEADER_HANDLER_KEY : String = GruberDialect.ATX_HEADER_HANDLER_KEY
    let EXT_HEADER_HANDLER_KEY : String = GruberDialect.EXT_HEADER_HANDLER_KEY
    let HORZ_RULE_HANDLER_KEY : String = GruberDialect.HORZ_RULE_HANDLER_KEY
    let CODE_HANDLER_KEY : String = GruberDialect.CODE_HANDLER_KEY
    
    override func setUp() {
        super.setUp()
        self.gruberDialect = GruberDialect()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSimpleLevel1HeaderBlock() {
        var line = Line(text: "# This is a level 1 heading", lineNumber: 0, trailing: "\n\n")
        
        var result = runBlockHandler(ATX_HEADER_HANDLER_KEY, line: line)
        
        XCTAssertNotNil(result)
        var r : [AnyObject] = result![0] as! [AnyObject]
        XCTAssertTrue(r.count > 0)
        XCTAssertEqual("header", r[0] as! String)
        XCTAssertEqual("This is a level 1 heading", r[2] as! String)
        XCTAssertNotNil(r[1])
        XCTAssertNotNil(r[1]["level"])
        XCTAssertEqual("1", r[1]["level"] as! String)
    }

    
    func testHeaderBlock() {
        var result = self.gruberDialect.toTree("Header\n======\nParagraph\n\nHeader\n------\nParagraph\n\n### Header\nParagraph")
        
        XCTAssertNotNil(result)
    }
    
    func testSimpleExtLevel1HeaderBlock() {
        var line = Line(text: "This is a level 1 heading\n======================", lineNumber: 0, trailing: "\n\n")
        
        var result = runBlockHandler(EXT_HEADER_HANDLER_KEY, line: line)
        
        XCTAssertNotNil(result)
        var r : [AnyObject] = result![0] as! [AnyObject]
        XCTAssertTrue(r.count > 0)
        XCTAssertEqual("header", r[0] as! String)
        XCTAssertEqual("This is a level 1 heading", r[2] as! String)
        XCTAssertNotNil(r[1])
        XCTAssertNotNil(r[1]["level"])
        XCTAssertEqual("1", r[1]["level"] as! String)
    }
    
    func testSimpleExtLevel2HeaderBlock() {
        var line = Line(text: "This is a level 2 heading\n--------------------", lineNumber: 0, trailing: "\n\n")
        
        var result = runBlockHandler(EXT_HEADER_HANDLER_KEY, line: line)
        
        XCTAssertNotNil(result)
        var r : [AnyObject] = result![0] as! [AnyObject]
        XCTAssertTrue(r.count > 0)
        XCTAssertEqual("header", r[0] as! String)
        XCTAssertEqual("This is a level 2 heading", r[2] as! String)
        XCTAssertNotNil(r[1])
        XCTAssertNotNil(r[1]["level"])
        XCTAssertEqual("2", r[1]["level"] as! String)
    }
    
    func testSimpleParagraphContainingEmphasizedText() {
        var line = Line(text: "This is *emphasised text* with some following text.", lineNumber: 0, trailing: "\n\n")
        
        var result = runBlockHandler(PARA_BLOCK_HANDLER_KEY, line: line)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.count > 0)
        var r: AnyObject = result![0]
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
        
        var result = runBlockHandler(PARA_BLOCK_HANDLER_KEY, line: line)

        XCTAssertNotNil(result)
        XCTAssertTrue(result!.count > 0)
        var r: AnyObject = result![0]
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

    func testAutoLinkOfURL() {
        var line = Line(text: "URLs like <http://google.com> get autolinkified.",
            lineNumber: 0, trailing: "\n\n")
        
        var result = runBlockHandler(PARA_BLOCK_HANDLER_KEY, line: line)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.count > 0)
        var r: AnyObject = result![0]
        XCTAssertEqual("para", r[0] as! String)
        XCTAssertEqual("URLs like ", r[1] as! String)
        XCTAssertNotNil(r[2])
        var e = r[2] as! [AnyObject]
        XCTAssertEqual("link", e[0] as! String)
        var e2 = e[1] as! [String:String]
        XCTAssertNotNil(e2["href"])
        XCTAssertEqual("http://google.com", e2["href"]!)
        XCTAssertEqual("http://google.com", e[2] as! String)
        XCTAssertEqual(" get autolinkified.", r[3] as! String)
    }
    
    func testAutoLinkOfEmail() {
        var line = Line(text: "Email addresses written like <bill@microsoft.com> get autolinkified.",
            lineNumber: 0, trailing: "\n\n")
        
        var result = runBlockHandler(PARA_BLOCK_HANDLER_KEY, line: line)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.count > 0)
        var r: AnyObject = result![0]
        XCTAssertEqual("para", r[0] as! String)
        XCTAssertEqual("Email addresses written like ", r[1] as! String)
        XCTAssertNotNil(r[2])
        var e = r[2] as! [AnyObject]
        XCTAssertEqual("link", e[0] as! String)
        var e2 = e[1] as! [String:String]
        XCTAssertNotNil(e2["href"])
        XCTAssertEqual("mailto:bill@microsoft.com", e2["href"]!)
        XCTAssertEqual("bill@microsoft.com", e[2] as! String)
        XCTAssertEqual(" get autolinkified.", r[3] as! String)
    }
    
    
    func testAltImageWithTitle() {
        var line = Line(text: "![Alt text](/path/to/img.jpg \"Optional title\")",
            lineNumber: 0, trailing: "\n\n")
        
        var result = runBlockHandler(PARA_BLOCK_HANDLER_KEY, line: line)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.count > 0)
        var r: AnyObject = result![0]
        XCTAssertEqual("para", r[0] as! String)

        var img: [AnyObject] = r[1] as! [AnyObject]
        XCTAssertEqual("img", img[0] as! String)
        var attrs : [String:String] = img[1] as! [String:String]
        XCTAssertEqual("Alt text", attrs["alt"]!)
        XCTAssertEqual("/path/to/img.jpg", attrs["href"]!)
    }
    
    func testCodeBlock() {
        var line = Line(text: "    tell application \"Foo\"\n        beep\n    end tell\n        tab\n",
            lineNumber: 0, trailing: "\n\n")
        
        var result = runBlockHandler(CODE_HANDLER_KEY, line: line)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.count > 0)
        var r : [String] = result![0] as! [String]
        XCTAssertTrue(r.count == 2)
        XCTAssertEqual("code_block", r[0])
        XCTAssertEqual("tell application \"Foo\"\n    beep\nend tell\n    tab", r[1])
    }
    
    func testEscapedCharacters() {
        var chars : [String] = ["\\", "`", "*", "_", "{", "}", "[", "]", "(", ")", "#", "+", "-", ".", "!"]
        var unescape : (String) -> [AnyObject] = self.gruberDialect.inline["\\"]!
        for c in chars {
            var result = unescape("\\"+c)
            XCTAssertNotNil(result)
            XCTAssertTrue(result.count > 0)
            XCTAssertEqual(2, result[0] as! Int)
            XCTAssertEqual(c, result[1] as! String)
        }
    }
    
    func testSimpleLinkWithTitle() {
        var text = "This is [an example](http://example.com/ \"Title\") inline link."
        var line = Line(text: text, lineNumber: 0, trailing: "\n")
        
        var result = runBlockHandler(PARA_BLOCK_HANDLER_KEY, line: line)

        XCTAssertNotNil(result)
        XCTAssertTrue(result!.count > 0)
        var r: AnyObject = result![0]
        XCTAssertEqual("para", r[0] as! String)
        
        var link: [AnyObject] = r[2] as! [AnyObject]
        XCTAssertEqual("link", link[0] as! String)
        var attrs : [String:String] = link[1] as! [String:String]
        XCTAssertEqual("http://example.com/", attrs["href"]!)
        XCTAssertEqual("Title", attrs["title"]!)
        XCTAssertEqual("an example", link[2] as! String)
    }
    
    func testFrontMatterHorizontalLine() {
        var text = "---\nlayout: post\ntitle: A title\n---\n\nPack my box with five dozen liquor jugs."
        
        var result = self.gruberDialect.toTree(text)
        
        println(result.description)
    }
    
    func runBlockHandler(name : String, line: Line) -> [AnyObject]? {
        var lines : Lines = Lines()
        return self.gruberDialect.block[name]!(line, &lines)
    }
}
