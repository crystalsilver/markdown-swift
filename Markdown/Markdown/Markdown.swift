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
    
    func toTree(source : String) -> [AnyObject] {
        var tree : [AnyObject] = ["markdown"]
        var lines : Lines = Lines(source: source)
            
        while !lines.isEmpty() {
            var processedLine = self.processBlock(lines.shift(), next : lines)
            if processedLine != nil {
                tree.append(processedLine!)
            }
        }
        
        return tree
    }
    
    func processBlock(line : Line?, next : Lines) -> [AnyObject]? {
        if line == nil {
            return []
        } else {
            var dialect = self.dialect
            
            if dialect.block["__call__"] != nil {
                return dialect.block["__call__"]!(line!, next)
            } else {
                var blockHandlers = dialect.block
                var ord = dialect.__order__
                for var i = 0; i < ord.count; i++ {
                    var res = blockHandlers[ord[i]]!(line!, next)
                    if res != nil {
                        var r : [AnyObject] = res!
                        var node : [AnyObject]? = r[0] as? [AnyObject]
                        if (!r.isEmpty && node == nil) {
                            println(ord[i] + " didn't return proper JsonML")
                        } else if node != nil &&
                                  node!.isEmpty &&
                                  node![0] as? String == nil {
                            println(ord[i] + " didn't return proper JsonML")
                        }
                        
                        return res
                    }
                }
            }
            
            return nil
        }
    }
    
    func processInline(line : Line, patterns: String?)->[AnyObject]{
        return self.dialect.__inline_call__(line, patterns)
    }
}