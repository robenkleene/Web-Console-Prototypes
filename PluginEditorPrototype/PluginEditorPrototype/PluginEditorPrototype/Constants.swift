//
//  Constants.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

let pluginFileExtension = "wcplugin"
let pluginNameKey = WCLPluginNameKey
let applicationName = NSBundle.mainBundle().infoDictionary![kCFBundleNameKey as NSString] as NSString
let errorDomain = NSBundle.mainBundle().bundleIdentifier! as NSString

enum Directory {
    case Caches
    case ApplicationSupport
    case ApplicationSupportPlugins
    case BuiltInPlugins
    func path() -> String {
        switch self {
        case .Caches:
            let cachesDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as String
            return cachesDirectory.stringByAppendingPathComponent(applicationName)
        case .ApplicationSupport:
            let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as String
            return applicationSupportDirectory.stringByAppendingPathComponent(applicationName)
        case .ApplicationSupportPlugins:
            let pluginsPathComponent = "PlugIns"
            return Directory.ApplicationSupport.path().stringByAppendingPathComponent(pluginsPathComponent)
        case .BuiltInPlugins:
            return NSBundle.mainBundle().builtInPlugInsPath!
        }
    }
    func URL() -> NSURL {
        return NSURL(fileURLWithPath: self.path())!
    }
}