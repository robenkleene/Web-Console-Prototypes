//
//  Plugin+Initialization.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/2/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

extension Plugin {
    struct InfoDictionaryKeys {
        static let Name = "WCName"
        static let Identifier = "WCUUID"
        static let Command = "WCCommand"
        static let Suffixes = "WCFileExtensions"
        static let Hidden = "WCHidden"
        static let Editable = "WCEditable"
    }

    enum PluginType {
        case BuiltIn, User, Other
        func name() -> String {
            switch self {
            case .BuiltIn:
                return "Built-In"
            case .User:
                return "User"
            case .Other:
                return "Other"
            }
        }
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
                                    let editable = validEditable(infoDictionary, error: &error)
                                    if error == nil {
                                        let pluginType = validPluginTypeFromPath(path)
                                        return Plugin(bundle: bundle,
                                            infoDictionary: infoDictionary,
                                            pluginType: pluginType,
                                            identifier: identifier,
                                            name: name,
                                            command: command,
                                            suffixes: suffixes,
                                            hidden: hidden,
                                            editable: editable)
                                    }
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
    
    // MARK: Info Dictionary
    
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
        if let suffixes = infoDictionary[InfoDictionaryKeys.Suffixes] as? [String] {
            return suffixes
        }

        if let suffixes: AnyObject = infoDictionary[InfoDictionaryKeys.Suffixes] {
            if error != nil {
                let errorString = NSLocalizedString("Plugin file extensions is invalid \(infoDictionary).", comment: "Invalid plugin file extensions error")
                error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
            }
        }
        
        return nil
    }

    class func validCommand(infoDictionary: [NSObject : AnyObject], error: NSErrorPointer) -> String? {
        if let command = infoDictionary[InfoDictionaryKeys.Command] as NSString? {
            if command.length > 0 {
                return command
            }
        }

        if let commnd: AnyObject = infoDictionary[InfoDictionaryKeys.Command] {
            if error != nil {
                let errorString = NSLocalizedString("Plugin command is invalid \(infoDictionary).", comment: "Invalid plugin command error")
                error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
            }
        }
        
        return nil
    }
    
    class func validName(infoDictionary: [NSObject : AnyObject], error: NSErrorPointer) -> String? {
        if let name = infoDictionary[InfoDictionaryKeys.Name] as NSString? {
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
        if let uuidString = infoDictionary[InfoDictionaryKeys.Identifier] as NSString? {
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
        if let hidden = infoDictionary[InfoDictionaryKeys.Hidden] as Int? {
            return NSNumber(integer: hidden).boolValue
        }
        
        if let hidden: AnyObject = infoDictionary[InfoDictionaryKeys.Hidden] {
            if error != nil {
                let errorString = NSLocalizedString("Plugin hidden is invalid \(infoDictionary).", comment: "Invalid plugin name error")
                error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
            }
        }

        return false
    }

    class func validEditable(infoDictionary: [NSObject : AnyObject], error: NSErrorPointer) -> Bool {
        if let editable = infoDictionary[InfoDictionaryKeys.Editable] as Int? {
            return NSNumber(integer: editable).boolValue
        }
        
        if let editable: AnyObject = infoDictionary[InfoDictionaryKeys.Editable] {
            if error != nil {
                let errorString = NSLocalizedString("Plugin editable is invalid \(infoDictionary).", comment: "Invalid plugin name error")
                error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
            }
        }
        
        return true
    }

    class func validPluginTypeFromPath(path: NSString) -> PluginType {
        let pluginContainerDirectory = path.stringByDeletingLastPathComponent
        switch pluginContainerDirectory {
        case Directory.ApplicationSupportPlugins.path():
            return PluginType.User
        case Directory.BuiltInPlugins.path():
            return PluginType.BuiltIn
        default:
            return PluginType.Other
        }
    }
}
