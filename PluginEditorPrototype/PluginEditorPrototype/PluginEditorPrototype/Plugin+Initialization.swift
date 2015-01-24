//
//  Plugin+Initialization.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/2/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

extension Plugin {
    class func pluginWithURL(url: NSURL) -> Plugin? {
        if let path = url.path {
            return self.pluginWithPath(path)
        }
        return nil
    }
    
    class func pluginWithPath(path: String) -> Plugin? {
        var error: NSError?
        if let bundle = validBundle(path, error: &error) {
            if let infoDictionary = validInfoDictionary(bundle, error: &error) {
                if let identifier = validIdentifier(infoDictionary, error: &error) {
                    if let name = validName(infoDictionary, error: &error) {
    
                        // Optional Values
                        let command = validCommand(infoDictionary, error: &error)
                        if (error == nil) {
                            let extensions = validExtensions(infoDictionary, error: &error)
                            if (error == nil) {
                                return Plugin(bundle: bundle,
                                    infoDictionary: infoDictionary,
                                    identifier: identifier,
                                    name: name,
                                    command: command,
                                    extensions: extensions)
                            }
                        }

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
            error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
        }
        
        return nil
    }
    
    class func validInfoDictionary(bundle: NSBundle, error: NSErrorPointer) -> [NSObject : AnyObject]? {
        let url = self.infoDictionaryURLForPluginURL(bundle.bundleURL)
        let infoDictionary: NSMutableDictionary? = NSMutableDictionary(contentsOfURL: url)
        if infoDictionary != nil {
            return infoDictionary
        }
        
        if error != nil {
            if let path = url.path {
                let errorString = NSLocalizedString("Info.plist is invalid at path \(path).", comment: "Invalid plugin Info.plist error")
                error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
            }
        }
        
        return nil
    }

    class func validExtensions(infoDictionary: [NSObject : AnyObject], error: NSErrorPointer) -> [String]? {
        if let extensions = infoDictionary[ClassConstants.pluginExtensionsKey] as? [String] {
            return extensions
        }

        if let extensions: AnyObject = infoDictionary[ClassConstants.pluginExtensionsKey] {
            if error != nil {
                let errorString = NSLocalizedString("Plugin file extensions is invalid \(infoDictionary).", comment: "Invalid plugin file extensions error")
                error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
            }
        }
        
        return nil
    }

    class func validCommand(infoDictionary: [NSObject : AnyObject], error: NSErrorPointer) -> String? {
        if let command = infoDictionary[ClassConstants.pluginCommandKey] as NSString? {
            if command.length > 0 {
                return command
            }
        }

        if let commnd: AnyObject = infoDictionary[ClassConstants.pluginCommandKey] {
            if error != nil {
                let errorString = NSLocalizedString("Plugin command is invalid \(infoDictionary).", comment: "Invalid plugin command error")
                error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
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
            error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
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
            error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
        }
        
        return nil
    }
}
