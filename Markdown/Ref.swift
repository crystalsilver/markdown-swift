//
//  Reference.swift
//  Markdown
//
//  Created by Leanne Northrop on 30/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation

public class Ref : Printable {
    public let refId:String
    public let title:String
    public let href:String
    
    public var description:String {
        get {
            return self.refId + " " + self.title + " " + self.href
        }
    }
    
    public init(rid:String, title:String, href:String) {
        self.refId = rid
        self.title = title
        self.href = href
    }
}