//
//  Markdown.swift
//  Markdown
//
//  Created by Leanne Northrop on 15/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation

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
}