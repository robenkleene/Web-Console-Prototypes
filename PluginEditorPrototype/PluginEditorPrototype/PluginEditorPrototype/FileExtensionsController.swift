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
    
    struct Singleton {
        static let instance: FileExtensionsController = FileExtensionsController()
        static var overrideSharedInstance: FileExtensionsController?
    }
    
    class var sharedInstance: FileExtensionsController {
        if let overrideSharedInstance = Singleton.overrideSharedInstance {
            return overrideSharedInstance
        }
        
        // TODO: Assert that the non-overridden instance is never returned when running tests?
        
        return Singleton.instance
    }
    
    class func setOverrideSharedInstance(fileExtensionsController: FileExtensionsController?) {
        Singleton.overrideSharedInstance = fileExtensionsController
    }

    // MARK: Init

    override init(pluginsManager: PluginsManager) {
        super.init(pluginsManager: pluginsManager)
    }

    convenience override init() {
        self.init(pluginsManager: PluginsManager.sharedInstance)
    }
    
}
