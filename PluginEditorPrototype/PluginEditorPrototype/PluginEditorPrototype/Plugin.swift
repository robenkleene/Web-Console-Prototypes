//
//  Plugin.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa


class Plugin: WCLPlugin {
    struct ClassConstants {
        static let errorCode = -43
        static let pluginNameKey = "WCName"
        static let pluginIdentifierKey = "WCUUID"
        static let pluginCommandKey = "WCCommand"
        static let infoDictionaryPathComponent = "Contents".stringByAppendingPathComponent("Info.plist")
    }
    internal let bundle: NSBundle
    internal var infoDictionary: [NSObject : AnyObject]
    internal var infoDictionaryURL: NSURL {
        get {
            return self.dynamicType.infoDictionaryURL(bundle)
        }
    }
    dynamic var name: String {
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
        let infoDictionaryURL = self.infoDictionaryURL
        var error: NSError?
        self.dynamicType.writeDictionary(infoDictionary, toURL: infoDictionaryURL, error: &error)
    }
    class func writeDictionary(dictionary: [NSObject : AnyObject], toURL url: NSURL, error: NSErrorPointer) {
        let writableDictionary = NSDictionary(dictionary: dictionary)
        let success = writableDictionary.writeToURL(url, atomically: true)
        if !success && error != nil {
            if let path = url.path {
                let errorString = NSLocalizedString("Failed to write to dictionary at path \(path).", comment: "Failed to write to dictionary")
                error.memory = NSError.errorWithDescription(errorString, code: ClassConstants.errorCode)
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
    override func isPluginManagerDefaultNewPlugin() -> Bool {
        return PluginManager.sharedInstance.defaultNewPlugin? == self
    }
    override var description : String {
        return "Plugin name = \(name),  identifier = \(identifier), defaultNewPlugin = \(defaultNewPlugin)"
    }
}
