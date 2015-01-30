//
//  WCLPlugin+PluginsManager.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/29/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation

extension WCLPlugin {

    func pluginsManager() -> PluginsManager {
        return self.dynamicType.pluginsManager()
    }
    
    class func pluginsManager() -> PluginsManager {
        return PluginsManager.sharedInstance
    }
}