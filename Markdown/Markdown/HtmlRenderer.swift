//
//  HtmlRenderer.swift
//  Markdown
//
//  Created by Leanne Northrop on 22/06/2015.
//  Copyright (c) 2015 Leanne Northrop. All rights reserved.
//

import Foundation
public class HtmlRenderer: Renderer {
    public override init() { super.init() }

    public func toHTML(source : [AnyObject]) -> String {
        var input = self.toHTMLTree(source, preprocessTreeNode: nil)
        return self.renderHTML(input, includeRoot: true)
    }
    
    public func toHTMLTree(input: String, dialectName : String, options : AnyObject) -> [AnyObject] {
        let md = Markdown(dialectName: dialectName)
        let result : [AnyObject] = md.parse(input)
        return self.toHTMLTree(result, preprocessTreeNode: nil)
    }
    
    public func toHTMLTree(input : [AnyObject],
                           preprocessTreeNode : (([AnyObject],[String:String]) -> [AnyObject])!) -> [AnyObject] {
        // Convert the MD tree to an HTML tree
        
        // remove references from the tree
        var refs :[String:String] = [:]
        let attrs : [String:AnyObject]? = extract_attr(input)
        if attrs != nil {
            let rs = attrs!["refs"] as? [String:String]
            if rs != nil {
                refs = rs!
            }
        }
        
        var html = convert_tree_to_html(input, refs: refs, preprocessTreeNode: preprocessTreeNode)
        //todomerge_text_nodes(html)
        
        return html
    }
    
    func extract_attr(jsonml : [AnyObject]) -> [String:AnyObject]? {
        if jsonml.count > 1 {
            if let attrs = jsonml[1] as? [String:AnyObject] {
                return jsonml[1] as? [String:AnyObject]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func convert_tree_to_html(tree : [AnyObject]?,
                              refs : [String:String],
                              preprocessTreeNode : (([AnyObject],[String:String]) -> [AnyObject])!) -> [AnyObject] {
        if tree == nil {
            return []
        }
                                
        // shallow clone
        var jsonml : [AnyObject] = []
        if preprocessTreeNode != nil {
            jsonml = preprocessTreeNode(tree!, refs)
        } else {
            jsonml = tree!
        }

        var attrs : [String:AnyObject]? = extract_attr(jsonml)
    
        // convert this node
        if !(jsonml[0] is String) {
            if jsonml[0] is [AnyObject] {
                return convert_tree_to_html(jsonml[0] as? [AnyObject], refs: refs, preprocessTreeNode: preprocessTreeNode)
            } else {
                return []
            }
        }
        var nodeName : String = jsonml[0] as! String
        switch nodeName {
            case "header":
                jsonml[0] = "h" + ((attrs?["level"])! as! String)
                attrs?.removeValueForKey("level")
            case "bulletlist":
                jsonml[0] = "ul"
            case "numberlist":
                jsonml[0] = "ol"
            case "listitem":
                jsonml[0] = "li"
            case "para":
                jsonml[0] = "p"
            case "markdown":
                jsonml[0] = "body"
                if attrs != nil {
                    attrs?.removeValueForKey("refs")
                }
            case "code_block":
                jsonml[0] = "pre"
                var j = attrs != nil ? 2 : 1
                var k = 1
                if attrs != nil {
                    k = 2
                }
                var code : [AnyObject] = ["code"]
                for var a = k; a < (jsonml.count - k); a++ {
                    code.append(jsonml.removeAtIndex(a))
                }
                jsonml[k] = code
            case "uchen_block":
                jsonml[0] = "p"
                var k = 1
                if attrs != nil {
                    k = 2
                }
                var uchen : [AnyObject] = ["uchen"]
                for var a = k; a < (jsonml.count - k); a++ {
                    uchen.append(jsonml.removeAtIndex(a))
                }
                jsonml[k] = uchen
            case "uchen":
                jsonml[0] = "span"
            case "inlinecode":
                jsonml[0] = "code"
            case "img":
                println("img")
                //todo jsonml[1].src = jsonml[ 1 ].href;
                //delete jsonml[ 1 ].href;
            case "linebreak":
                jsonml[0] = "br"
            case "link":
                jsonml[0] = "a"
            case "link_ref":
                jsonml[0] = "a"
                if attrs != nil {
                    var attributes : [String:AnyObject] = attrs!
                    var key = attributes["ref"] as? String
                    if key != nil {
                        // grab this ref and clean up the attribute node
                        var ref = refs[key!]
            
                        // if the reference exists, make the link
                        if ref != nil {
                            attributes.removeValueForKey("ref")
                            // add in the href if present
                            // todo attributes["href"] = ref!["href"]
                            
                            // get rid of the unneeded original text
                            attributes.removeValueForKey("original")
                        } /*else {
                            return (attributes.indexForKey("original") != nil) ? attributes["original"]! : []
                        }*/
                    }
                }
            case "img_ref":
                jsonml[0] = "img"
                if attrs != nil {
                    var attributes = attrs!
                    // grab this ref and clean up the attribute node
                    //var ref = refs[attributes["ref"]]
        
                    /* if the reference exists, make the link
                    if ref != nil {
                        attrs.removeValueForKey("ref")
        
                        // add in the href and title, if present
                        attrs.src = ref.href;
                        if ( ref.title )
                            attrs.title = ref.title;
        
                        // get rid of the unneeded original text
                        delete attrs.original;
                    } else {
                        return attrs.original
                    }*/
                }
            default:
                println("convert_to_html encountered unsupported element " + nodeName)
        }
    
        // convert all the children
        var l = 1
    
        // deal with the attribute node, if it exists
        if attrs != nil {
            var attributes = attrs!
            // if there are keys, skip over it
            for (key,value) in attributes {
                l = 2
                break
            }
        }
                                
        // if there aren't, remove it
        //if l == 1 {
        //    jsonml.removeAtIndex(1)
        //}
    
        for l; l < jsonml.count; ++l {
            if (jsonml[l] is [AnyObject]) {
                var node : [AnyObject] = jsonml[l] as! [AnyObject]
                jsonml[l] = convert_tree_to_html(node, refs: refs, preprocessTreeNode: preprocessTreeNode)
            }
        }
    
        return jsonml
    }
    
    func renderHTML(var jsonml : [AnyObject], includeRoot : Bool) -> String {
        var content : [String] = []
        
        if includeRoot {
            content.append("<!DOCTYPE html>")
            content.append("<html>")
            content.append("<head>")
            content.append("<meta charset=\"UTF-8\">")
            content.append("<title>Markdown</title>")
            content.append("</head>")
            content.append(super.render_tree(jsonml))
            content.append("</html>")
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
                    println("HTML renderer found a " + v!.type)
                }
            }
        }
        
        var joiner = "\n\n"
        var joined = joiner.join(content)
        return joined
    }
}