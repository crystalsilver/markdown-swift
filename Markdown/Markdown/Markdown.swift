//
//  Markdown.swift
//  Markdown
//
//  Created by Leanne Northrop on 15/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation

public func markdownParse(source : String, dialect : String) -> [AnyObject] {
    var md : Markdown = Markdown(dialectName: dialect)
    return md.parse(source)
}

public class Markdown {
    static let dialects :[String:Dialect] = ["wylie":WylieDialect()]
    var dialect : Dialect
    
    public convenience init(dialectName : String){
        self.init(dialect: Markdown.dialects[dialectName]!)
    }
    
    init(dialect : Dialect?){
        if (dialect == nil) {
            // gruber should be default
            self.dialect = Markdown.dialects["wylie"]!
        } else {
            self.dialect = dialect!
        }
    }
    
    public func parse(source : String) -> [AnyObject] {
        return self.toTree(source)
    }
    
    public func toTree(source : String) -> [AnyObject] {
        var tree : [AnyObject] = ["markdown"]
        var lines : Lines = Lines(source: source)
            
        while !lines.isEmpty() {
            var processedLine = self._processBlock(lines.shift(), next : lines)
    
            tree.append(processedLine)
        }
        
        return tree
    }
    
    func _processBlock(line : Line?, next : Lines) -> [AnyObject] {
        if line == nil {
            return []
        } else {
            return []
        }
    }
}