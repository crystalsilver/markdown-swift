//
//  Renderer.swift
//  Markdown
//
//  Created by Leanne Northrop on 22/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation

public class Renderer {
    public init() {}
    
    func escapeHTML(text:String) -> String {
        if !text.isBlank() {
            return  text.replace("&", replacement: "&amp;")
                        .replace("<", replacement: "&lt;")
                        .replace(">", replacement: "&gt;")
                        .replace("\"", replacement: "&quot;")
                        .replace("\'", replacement: "&#39;")
        } else {
            return ""
        }
    }

    func render_tree(jsonml:String) -> String {
        return escapeHTML(jsonml)
    }
    
    func render_tree(var jsonml: [AnyObject]) -> String {
        if jsonml.isEmpty { return "" }
        var tag: AnyObject = jsonml.removeAtIndex(0)
        
        if tag is [AnyObject] {
            return render_tree(tag as! [AnyObject])
        }
        
        var tagName : String = tag as! String
        var attributes : [String:String] = [:]
        var content : [String] = []
        
        if jsonml.count > 0 {
            if jsonml[0] is Dictionary<String,String> {
                attributes = jsonml.removeAtIndex(0) as! Dictionary<String,String>
            }
        }
        
        while jsonml.count > 0 {
            var node: AnyObject = jsonml.removeAtIndex(0)
            if node is [AnyObject] {
                content.append(render_tree(node as! [AnyObject]))
            } else {
                content.append(render_tree(node as! String))
            }
        }
        
        var tag_attrs : String = ""
        if attributes.indexForKey("src") != nil {
            tag_attrs += " src=\"" + escapeHTML(attributes["src"]!) + "\""
            attributes.removeValueForKey("src")
        }
        
        for (key,value) in attributes {
            var escaped = escapeHTML(value)
            if !escaped.isBlank() {
                tag_attrs += " " + key + "=\"" + escaped + "\""
            }
        }
        
        // be careful about adding whitespace here for inline elements
        var str : String = "<"
        str += tag as! String
        str += tag_attrs
        
        if (tagName == "img" || tagName == "br" || tagName == "hr") {
            str += "/>"
        }
        else {
            str += ">"
            str += "".join(content)
            str += "</" + tagName + ">"
        }
        return str
    }
}