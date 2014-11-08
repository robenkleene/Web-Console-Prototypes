//
//  Plugin.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa


class Plugin: NSObject {
    // TODO BEGIN extension Plugin+Initialization
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
                        let command = validCommand(infoDictionary, error: &error)
                        return Plugin(bundle: bundle, infoDictionary: infoDictionary, identifier: identifier, name: name, command: command)
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
            error.memory = ErrorHelper.errorWithDescription(errorString, code: ClassConstants.errorCode)
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
                error.memory = ErrorHelper.errorWithDescription(errorString, code: ClassConstants.errorCode)
            }
        }
        
        return nil
    }

    // TODO: A plugin command can be nil
    class func validCommand(infoDictionary: [NSObject : AnyObject], error: NSErrorPointer) -> String? {
        if let command = infoDictionary[ClassConstants.pluginCommandKey] as NSString? {
            if command.length > 0 {
                return command
            }
        }
        
        if error != nil {
            let errorString = NSLocalizedString("Plugin command is invalid \(infoDictionary).", comment: "Invalid plugin command error")
            error.memory = ErrorHelper.errorWithDescription(errorString, code: ClassConstants.errorCode)
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
            error.memory = ErrorHelper.errorWithDescription(errorString, code: ClassConstants.errorCode)
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
            error.memory = ErrorHelper.errorWithDescription(errorString, code: ClassConstants.errorCode)
        }
        
        return nil
    }
    // TODO END extension Plugin+Initialization
    
    struct ClassConstants {
        static let errorCode = -43
        static let pluginNameKey = "WCName"
        static let pluginIdentifierKey = "WCUUID"
        static let pluginCommandKey = "WCCommand"
        static let infoDictionaryPathComponent = "Contents".stringByAppendingPathComponent("Info.plist")
    }
    internal let bundle: NSBundle
    var infoDictionary: [NSObject : AnyObject]
    var name: String {
        didSet {
            infoDictionary[ClassConstants.pluginNameKey] = name
            save()
        }
    }
    var identifier: String {
        didSet {
            infoDictionary[ClassConstants.pluginIdentifierKey] = identifier
            save()
        }
    }
    var command: String? {
        didSet {
            infoDictionary[ClassConstants.pluginCommandKey] = command
            save()
        }
    }
    var commandPath: String? {
        get {
            if let resourcePath = resourcePath {
                if let command = command {
                    return resourcePath.stringByAppendingPathComponent(command)
                }
            }
            return nil
        }
    }
    private var resourcePath: String? {
        get {
            return bundle.resourcePath
        }
    }
    
    private func save() {
        let infoDictionaryURL = self.dynamicType.infoDictionaryURL(bundle)
        var error: NSError?
        self.dynamicType.writeDictionary(infoDictionary, toURL: infoDictionaryURL, error: &error)
    }
    class func writeDictionary(dictionary: [NSObject : AnyObject], toURL url: NSURL, error: NSErrorPointer) {
        let writableDictionary = NSDictionary(dictionary: dictionary)
        let success = writableDictionary.writeToURL(url, atomically: true)
        if !success && error != nil {
            if let path = url.path {
                let errorString = NSLocalizedString("Failed to write to dictionary at path \(path).", comment: "Failed to write to dictionary")
                error.memory = ErrorHelper.errorWithDescription(errorString, code: ClassConstants.errorCode)
            }
        }
    }
    class func infoDictionaryURL(bundle: NSBundle) -> NSURL {
        return bundle.bundleURL.URLByAppendingPathComponent(ClassConstants.infoDictionaryPathComponent)
    }
    init(bundle: NSBundle, infoDictionary: [NSObject : AnyObject], identifier: String, name: String, command: String?) {
        self.infoDictionary = infoDictionary
        self.bundle = bundle
        self.name = name
        self.identifier = identifier
        self.command = command
    }
}