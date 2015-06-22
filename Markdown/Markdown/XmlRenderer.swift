//
//  XmlRenderer.swift
//  Markdown
//
//  Created by Leanne Northrop on 22/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation

public class XmlRenderer: Renderer {
    public override init() {
        super.init()
    }
    
    public func toXML(var jsonml : [AnyObject], includeRoot:Bool) -> String {
        var content : [String] = []
    
        if includeRoot {
            content.append("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>")
            content.append(super.render_tree(jsonml))
        } else {
            // remove tag
            jsonml.removeAtIndex(0)
            if var objArray = jsonml[0] as? [AnyObject] {
                // remove attributes
                objArray.removeAtIndex(0)
            }
            
            while jsonml.count > 0 {
                var v : AnyObject? = jsonml.removeAtIndex(0)
                if v is String {
                    content.append(super.render_tree(v as! String))
                } else if v is [AnyObject] {
                    let arr : [AnyObject] = v as! [AnyObject]
                    content.append(super.render_tree(arr))
                } else  {
                    println("XML renderer found a " + v!.type)
                }
            }
        }
    
        var joiner = "\n\n"
        var joined = joiner.join(content)
        return joined
    }
}