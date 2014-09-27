//
//  Constants.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

let pluginsFileExtension = "wcplugin"
let pluginNameKey = WCLPluginNameKey
let applicationName = NSBundle.mainBundle().infoDictionary[kCFBundleNameKey as NSString] as NSString

enum Directory {
    case ApplicationSupport
    case ApplicationSupportPlugins
    case BuiltInPlugins
    func path() -> String {
        switch self {
        case .ApplicationSupport:
            let applicationSupportPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as String
            return applicationSupportPath.stringByAppendingPathComponent(applicationName)
        case .ApplicationSupportPlugins:
            let pluginsPathComponent = "PlugIns"
            return Directory.ApplicationSupport.path().stringByAppendingPathComponent(pluginsPathComponent)
        case .BuiltInPlugins:
            return NSBundle.mainBundle().builtInPlugInsPath!
        }
    }
    func URL() -> NSURL {
        return NSURL(fileURLWithPath: self.path())
    }
}