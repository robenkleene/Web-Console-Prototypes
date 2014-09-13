//
//  Plugin.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

class Plugin: NSObject {
    var bundle: NSBundle
    init(path: String) {
        self.bundle = NSBundle(path: path)
    }
}
