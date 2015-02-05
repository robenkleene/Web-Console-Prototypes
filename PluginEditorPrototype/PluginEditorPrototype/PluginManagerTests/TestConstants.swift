//
//  TestConstants.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/24/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

let defaultTimeout = 20.0


// MARK: Plugin

let testPluginsPaths = [Directory.BuiltInPlugins.path()]
let testPluginName = "HTML"
let testPluginNameTwo = "IRB"
let testPluginNameNoPlugin = "Not a Plugin Name"
let testPluginCommand = "html.rb"
let testPluginCommandTwo = "irb.rb"
let testPluginPathComponent = "\(testPluginName).\(pluginFileExtension)"

// MARK: Extensions

let testPluginSuffix = "html"
let testPluginSuffixes: [String] = [testPluginSuffix]
let testPluginSuffixesTwo: [String] = ["html", "md", "js"]
let testPluginSuffixesEmpty = [String]()



// MARK: KVO Keys

let testPluginDefaultNewPluginKeyPath = "defaultNewPlugin"
let testFileExtensionEnabledKeyPath = "enabled"
let testFileExtensionSelectedPluginKeyPath = "selectedPlugin"
let testFileExtensionPluginIdentifierKey = "pluginIdentifier"
let testFileExtensionPluginsKey = "plugins"

// MARK: Plugin Paths

let testMissingFilePathComponent = "None"
let testSlashPathComponent = "/"
let testPluginInfoDictionaryPathComponent = testPluginContentsDirectoryName + testSlashPathComponent + testPluginInfoDictionaryFilename
let testPluginContentsDirectoryName = "Contents"
let testPluginResourcesDirectoryName = "Resources"
let testPluginInfoDictionaryFilename = "Info.plist"


// MARK: Directories & Files

let testPluginDirectoryName = DuplicatePluginController.pluginFilenameFromName(testDirectoryName)
let testPluginDirectoryNameTwo = DuplicatePluginController.pluginFilenameFromName(testDirectoryNameTwo)
let testDirectoryName = "test"
let testDirectoryNameTwo = "test2"
let testDirectoryNameThree = "test3"
let testDirectoryNameFour = "test4"
let testFilename = "test.txt"
let testFilenameTwo = "test2.txt"
let testFileContents = "test"
let testApplicationSupportDirectoryName = "Application Support"
let testHiddenDirectoryName = ".DS_Store"
