//
//  Plugin.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa


class Plugin: NSObject {
    struct ClassConstants {
        static let pluginNameKey = "WCName"
        static let pluginIdentifierKey = "WCUUID"
        static let infoDictionaryPathComponent = "Contents".stringByAppendingPathComponent("Info.plist")
    }
    let bundle: NSBundle
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
    func save() {
        let infoDictionaryURL = self.dynamicType.infoDictionaryURL(self.bundle)
        var error: NSError?
        self.dynamicType.writeDictionary(infoDictionary, toURL: infoDictionaryURL, error: &error)
    }
    
    
    class func writeDictionary(dictionary: [NSObject : AnyObject], toURL url: NSURL, error: NSErrorPointer) {
        let writableDictionary = NSDictionary(dictionary: dictionary)
        let success = writableDictionary.writeToURL(url, atomically: true)
        if !success && error != nil {
            if let path = url.path {
                let errorString = NSLocalizedString("Failed to write to dictionary at path \(path).", comment: "Failed to write to dictionary")
                error.memory = NSError.errorWithDescription(errorString, code: ErrorCode.PluginError.rawValue)
            }
        }
    }
    class func infoDictionaryURL(bundle: NSBundle) -> NSURL {
        return bundle.bundleURL.URLByAppendingPathComponent(ClassConstants.infoDictionaryPathComponent)
    }
    init(bundle: NSBundle, infoDictionary: [NSObject : AnyObject], identifier: String, name: String) {
        self.infoDictionary = infoDictionary
        self.bundle = bundle
        self.name = name
        self.identifier = identifier
    }
}
