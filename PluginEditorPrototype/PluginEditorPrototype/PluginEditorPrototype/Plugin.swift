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
        static let infoDictionaryPathComponent = "Contents".stringByAppendingPathComponent("Info.plist")
    }
    internal let bundle: NSBundle
    let hidden: Bool
    
    init(bundle: NSBundle,
        infoDictionary: [NSObject : AnyObject],
        identifier: String,
        name: String,
        command: String?,
        suffixes: [String]?,
        hidden: Bool)
    {
        self.infoDictionary = infoDictionary
        self.bundle = bundle
        self.name = name
        self.identifier = identifier
        self.hidden = hidden
        
        // Optional
        self.command = command
        self.suffixes = [String]()
        if let suffixes = suffixes {
            self.suffixes += suffixes
        }
    }
    
    // MARK: Paths

    private var resourcePath: String? {
        get {
            return bundle.resourcePath
        }
    }
    internal var infoDictionary: [NSObject : AnyObject]
    internal var infoDictionaryURL: NSURL {
        get {
            return self.dynamicType.infoDictionaryURLForPluginURL(bundle.bundleURL)
        }
    }

    class func infoDictionaryURLForPlugin(plugin: Plugin) -> NSURL {
        return infoDictionaryURLForPluginURL(plugin.bundle.bundleURL)
    }

    class func infoDictionaryURLForPluginURL(pluginURL: NSURL) -> NSURL {
        return pluginURL.URLByAppendingPathComponent(ClassConstants.infoDictionaryPathComponent)
    }
    
    
    // MARK: Properties
    
    dynamic var name: String {
        didSet {
            infoDictionary[PluginInfoDictionaryKeys.Name] = name
            save()
        }
    }
    var identifier: String {
        didSet {
            infoDictionary[PluginInfoDictionaryKeys.Identifier] = identifier
            save()
        }
    }
    dynamic var command: String? {
        didSet {
            infoDictionary[PluginInfoDictionaryKeys.Command] = command
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
    dynamic var suffixes: [String] {
        didSet {
            infoDictionary[PluginInfoDictionaryKeys.Suffixes] = suffixes
            save()
        }
    }
    dynamic var type: String {
        // TODO: Implement
        return "Built-In"
    }
    
    // MARK: Save
    
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

    // MARK: Description
    
    override var description : String {
        let description = super.description
        return "\(description), Plugin name = \(name),  identifier = \(identifier), defaultNewPlugin = \(defaultNewPlugin)"
    }

}
