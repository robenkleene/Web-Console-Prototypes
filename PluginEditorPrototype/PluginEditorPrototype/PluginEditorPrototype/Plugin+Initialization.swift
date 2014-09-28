//
//  Plugin+Initialization.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/28/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

extension Plugin {
    class func pluginWithPath(path: String) -> Plugin? {
        if let bundle = NSBundle(path: path) as NSBundle? {
            if let identifier = self.validIdentifier(bundle.infoDictionary) {
                if let name = self.validName(bundle.infoDictionary) {
                    return Plugin(bundle: bundle, identifier: identifier, name: name)
                }
            }
            return nil
        }
        
        println("Failed to load a plugin at path \(path)")
        return nil
    }
    
    class func validName(infoDictionary: [NSObject : AnyObject]) -> String? {
        if let name = infoDictionary[ClassConstants.pluginNameKey] as NSString? {
            if name.length > 0 {
                return name
            }
        }
        return nil
    }
    
    class func validIdentifier(infoDictionary: [NSObject : AnyObject]) -> String? {
        if let uuidString = infoDictionary[ClassConstants.pluginIdentifierKey] as NSString? {
            var uuid: NSUUID? = NSUUID(UUIDString: uuidString)
            if uuid != nil {
                return uuidString
            }
        }
        return nil
    }
}