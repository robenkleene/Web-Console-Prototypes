//
//  PluginsDirectoryManager.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

protocol PluginsDirectoryManagerDelegate {
// infoDictionaryWasCreatedOrModified
// infoDictionaryWasRemoved
    optional func directoryWillChange(directoryURL: NSURL)
}

class PluginsDirectoryManager: WCLPluginsDirectoryManager {
    var delegate: PluginsDirectoryManagerDelegate?

    override init(pluginsDirectoryURL: NSURL) {
        super.init(pluginsDirectoryURL: pluginsDirectoryURL)

    }
}


