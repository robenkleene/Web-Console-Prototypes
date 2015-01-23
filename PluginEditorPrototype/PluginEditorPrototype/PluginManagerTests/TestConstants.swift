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
let testPluginCommand = "html.rb"
let testPluginCommandTwo = "irb.rb"
let testPluginPathComponent = "\(testPluginName).\(pluginFileExtension)"
let testPluginFileExtension = "html"
let testPluginFileExtensions: [String] = [testPluginFileExtension]
let testPluginFileExtensionsTwo: [String] = ["html", "md", "js"]
let testPluginFileExtensionsEmpty = [String]()



// MARK: Plugin KVO

let testPluginDefaultNewPluginKeyPath = "defaultNewPlugin"



// MARK: Plugin Paths

let testMissingFilePathComponent = "None"
let testSlashPathComponent = "/"
let testPluginInfoDictionaryPathComponent = testPluginContentsDirectoryName + testSlashPathComponent + testPluginInfoDictionaryFilename
let testPluginContentsDirectoryName = "Contents"
let testPluginResourcesDirectoryName = "Resources"
let testPluginInfoDictionaryFilename = "Info.plist"


// MARK: Directories & Files

let testDirectoryName = "test"
let testDirectoryNameTwo = "test2"
let testDirectoryNameThree = "test3"
let testDirectoryNameFour = "test4"
let testFilename = "test.txt"
let testFilenameTwo = "test2.txt"
let testFileContents = "test"

