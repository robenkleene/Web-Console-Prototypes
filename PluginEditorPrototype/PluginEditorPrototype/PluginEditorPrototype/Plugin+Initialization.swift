//
//  Plugin+Initialization.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/2/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

extension Plugin {
    struct PluginInfoDictionaryKeys {
        static let Name = "WCName"
        static let Identifier = "WCUUID"
        static let Command = "WCCommand"
        static let Suffixes = "WCFileExtensions"
        static let Hidden = "WCHidden"
    }
    
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
    
                        // Optional Keys
                        let command = validCommand(infoDictionary, error: &error) // Can be nil
                        if error == nil {
                            let suffixes = validSuffixes(infoDictionary, error: &error) // Can be nil
                            if error == nil {
                                let hidden = validHidden(infoDictionary, error: &error)
                                if error == nil {
                                    return Plugin(bundle: bundle,
                                        infoDictionary: infoDictionary,
                                        identifier: identifier,
                                        name: name,
                                        command: command,
                                        suffixes: suffixes,
                                        hidden: hidden)
                                }
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

    class func validSuffixes(infoDictionary: [NSObject : AnyObject], error: NSErrorPointer) -> [String]? {
        if let suffixes = infoDictionary[PluginInfoDictionaryKeys.Suffixes] as? [String] {
            return suffixes
        }

        if let suffixes: AnyObject = infoDictionary[PluginInfoDictionaryKeys.Suffixes] {
            if error != nil {
                let errorString = NSLocalizedString("Plugin file extensions is invalid \(infoDictionary).", comment: "Invalid plugin file extensions error")
                error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
            }
        }
        
        return nil
    }

    class func validCommand(infoDictionary: [NSObject : AnyObject], error: NSErrorPointer) -> String? {
        if let command = infoDictionary[PluginInfoDictionaryKeys.Command] as NSString? {
            if command.length > 0 {
                return command
            }
        }

        if let commnd: AnyObject = infoDictionary[PluginInfoDictionaryKeys.Command] {
            if error != nil {
                let errorString = NSLocalizedString("Plugin command is invalid \(infoDictionary).", comment: "Invalid plugin command error")
                error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
            }
        }
        
        return nil
    }
    
    class func validName(infoDictionary: [NSObject : AnyObject], error: NSErrorPointer) -> String? {
        if let name = infoDictionary[PluginInfoDictionaryKeys.Name] as NSString? {
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
        if let uuidString = infoDictionary[PluginInfoDictionaryKeys.Identifier] as NSString? {
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

    class func validHidden(infoDictionary: [NSObject : AnyObject], error: NSErrorPointer) -> Bool {
        if let hidden = infoDictionary[PluginInfoDictionaryKeys.Hidden] as Int? {
            return NSNumber(integer: hidden).boolValue
        }
        
        if let hidden: AnyObject = infoDictionary[PluginInfoDictionaryKeys.Hidden] {
            if error != nil {
                let errorString = NSLocalizedString("Plugin hidden is invalid \(infoDictionary).", comment: "Invalid plugin name error")
                error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
            }
        }

        return false
    }
}
