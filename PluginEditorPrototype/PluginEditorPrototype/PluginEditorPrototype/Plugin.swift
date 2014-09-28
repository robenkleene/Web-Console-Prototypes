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
    }
    let bundle: NSBundle
    var name: String
    var identifier: String
    init(bundle: NSBundle, identifier: String, name: String) {
        self.bundle = bundle
        self.name = name
        self.identifier = identifier
    }
}
