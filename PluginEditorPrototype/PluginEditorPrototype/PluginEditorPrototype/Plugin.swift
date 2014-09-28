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
        static let infoDictionaryPathComponent = "Info.plist"
    }
    let bundle: NSBundle
    var infoDictionary: [NSObject : AnyObject]
    var name: String {
        didSet {
            
        }
    }
    var identifier: String {
        didSet {
            
        }
    }
    init(bundle: NSBundle, infoDictionary: [NSObject : AnyObject], identifier: String, name: String) {
        self.infoDictionary = infoDictionary
        self.bundle = bundle
        self.name = name
        self.identifier = identifier
    }
}
