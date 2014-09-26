//
//  PluginCopyController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/25/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

class PluginCopyController {
//    let copyCacheDirectoryURL: NSURL
    
    init() {
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as String
        println("cachesDirectory = \(cachesDirectory)")
    }

    func copyPlugin(plugin: Plugin, toURL dstURL: NSURL) -> Plugin? {
        println("Plugin.bundle.bundleURL = \(plugin.bundle.bundleURL)")

        // Copy the plugin to the to a cache location
        
        // Update the plist and filename
        
        // Copy to the destination

        return nil
    }
}