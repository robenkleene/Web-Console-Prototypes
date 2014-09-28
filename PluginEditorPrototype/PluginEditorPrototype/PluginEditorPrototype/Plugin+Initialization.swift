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
        var error: NSError?
        if let bundle = self.validBundle(path, error: &error) {
            if let infoDictionary = self.validInfoDictionary(bundle, error: &error) {
                if let identifier = self.validIdentifier(infoDictionary, error: &error) {
                    if let name = self.validName(infoDictionary, error: &error) {
                        return Plugin(bundle: bundle, infoDictionary: infoDictionary, identifier: identifier, name: name)
                    }
                }
            }
        }
        
        println("Failed to load a plugin at path \(path) \(error)")
        return nil
    }
    
    class func validBundle(path: String, error: NSErrorPointer) -> NSBundle? {
        if let bundle = NSBundle(path: path) as NSBundle? {
            return bundle
        }

        if error != nil {
            let errorString = NSLocalizedString("Bundle is invalid at path \(path).", comment: "Invalid plugin bundle error")
            error.memory = NSError.errorWithDescription(errorString, code: ErrorCode.PluginError.toRaw())
        }
        
        return nil
    }
    
    class func validInfoDictionary(bundle: NSBundle, error: NSErrorPointer) -> [NSObject : AnyObject]? {
        let url = self.infoDictionaryURL(bundle)
        let infoDictionary: NSMutableDictionary? = NSMutableDictionary(contentsOfURL: url)
        if infoDictionary != nil {
            return infoDictionary
        }

        if error != nil {
            if let path = url.path {
                let errorString = NSLocalizedString("Info.plist is invalid at path \(path).", comment: "Invalid plugin Info.plist error")
                error.memory = NSError.errorWithDescription(errorString, code: ErrorCode.PluginError.toRaw())
            }
        }
        
        return nil
    }

    class func validName(infoDictionary: [NSObject : AnyObject], error: NSErrorPointer) -> String? {
        if let name = infoDictionary[ClassConstants.pluginNameKey] as NSString? {
            if name.length > 0 {
                return name
            }
        }
        
        if error != nil {
            let errorString = NSLocalizedString("Plugin name is invalid \(infoDictionary).", comment: "Invalid plugin name error")
            error.memory = NSError.errorWithDescription(errorString, code: ErrorCode.PluginError.toRaw())
        }
        
        return nil
    }
    
    class func validIdentifier(infoDictionary: [NSObject : AnyObject], error: NSErrorPointer) -> String? {
        if let uuidString = infoDictionary[ClassConstants.pluginIdentifierKey] as NSString? {
            var uuid: NSUUID? = NSUUID(UUIDString: uuidString)
            if uuid != nil {
                return uuidString
            }
        }

        if error != nil {
            let errorString = NSLocalizedString("Plugin UUID is invalid \(infoDictionary).", comment: "Invalid plugin UUID error")
            error.memory = NSError.errorWithDescription(errorString, code: ErrorCode.PluginError.toRaw())
        }
        
        return nil
    }
}