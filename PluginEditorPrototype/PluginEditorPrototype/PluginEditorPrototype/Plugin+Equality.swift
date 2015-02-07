//
//  Plugin+Equality.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/7/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation

extension Plugin {
    func isEqualToPlugin(plugin: Plugin) -> Bool {

        if self.name != plugin.name {
            return false
        }
        
        if self.identifier != plugin.identifier {
            return false
        }

        if self.editable != plugin.editable {
            return false
        }

        if self.type != plugin.type {
            return false
        }
        
        if self.command != plugin.command {
            return false
        }

        if self.commandPath != plugin.commandPath {
            return false
        }

        if self.infoDictionaryURL != plugin.infoDictionaryURL {
            return false
        }
        
        return true
    }
}