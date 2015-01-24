//
//  FileExtensionsController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/24/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa

class FileExtensionsController: WCLFileExtensionsController {

    // MARK: Singleton
    
    class var sharedInstance: FileExtensionsController {
        struct Singleton {
            static let instance: FileExtensionsController = FileExtensionsController()
        }
        return Singleton.instance
    }

    // MARK: Plugins Manager

    override func pluginsManager() -> PluginsManager {
        return PluginsManager.sharedInstance
    }
}
