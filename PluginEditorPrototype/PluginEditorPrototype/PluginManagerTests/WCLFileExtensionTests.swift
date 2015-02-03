//
//  WCLFileExtensionTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/25/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

let fileExtensionToPluginKey = "WCLFileExtensionToPlugin"

class WCLFileExtensionTests: FileExtensionsTestCase {
    var fileExtension: WCLFileExtension!
    var fileExtensionPluginDictionary: NSDictionary {
        get {
            var fileExtensionToPluginDictionary = WCLFileExtension.fileExtensionToPluginDictionary()
            return fileExtensionToPluginDictionary[fileExtension.suffix] as NSDictionary
        }
    }

    // MARK: Helper
    
    func matchesPlugin(plugin: Plugin, forFileExtension fileExtension: WCLFileExtension) -> Bool {
        let suffix = fileExtension.suffix
        
        let plugins = fileExtension.plugins() as NSArray
        let containsPlugin = plugins.containsObject(plugin)
        
        let suffixes = plugin.suffixes as NSArray
        let containsSuffix = suffixes.containsObject(suffix)
        
        return containsPlugin == containsSuffix
    }
    
    func confirmPluginIdentifierInFileExtensionPluginDictionary() {
        let pluginIdentifierInDictionary = fileExtensionPluginDictionary.valueForKey(testFileExtensionPluginIdentifierKey) as String
        XCTAssertEqual(pluginIdentifierInDictionary, fileExtension.selectedPlugin.identifier, "The WCLPlugin's identifier value in the dictionary should match the WCLFileExtension's selected WCLPlugin's identifier.")
    }

    // MARK: Tests
    
    override func setUp() {
        super.setUp()
        plugin.suffixes = testPluginSuffixes
        XCTAssertEqual(FileExtensionsController.sharedInstance.suffixes().count, 1, "The file extensions count should equal one.")
        fileExtension = FileExtensionsController.sharedInstance.fileExtensionForSuffix(testPluginSuffix)
    }

    override func tearDown() {
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: fileExtensionToPluginKey)
        super.tearDown()
    }
    
    func testNewFileExtensionProperties() {
        let suffix = fileExtension.suffix
        XCTAssertEqual(fileExtension.suffix, testPluginSuffix, "The WCLFileExtension's extension should equal the test extension.")
        XCTAssertEqual(fileExtension.enabled, defaultFileExtensionEnabled, "The WCLFileExtension's enabled should equal the default enabled.")
        XCTAssertEqual(fileExtension.selectedPlugin, fileExtension.plugins()[0] as Plugin, "The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.")

        let plugins = PluginsManager.sharedInstance.plugins() as [Plugin]
        for plugin in plugins {
            let matches = matchesPlugin(plugin, forFileExtension: fileExtension)
            XCTAssertTrue(matches, "The WCLPlugin should match the WCLFileExtension.")
        }
    }
    
    func testSettingEnabled() {
        var isEnabled = fileExtension.enabled
        WCLKeyValueObservingTestsHelper.observeObject(fileExtension,
            forKeyPath: testFileExtensionEnabledKeyPath,
            options: NSKeyValueObservingOptions.New)
        {
            ([NSObject : AnyObject]!) -> Void in
            isEnabled = self.fileExtension.enabled
        }

        var inverseEnabled = !fileExtension.enabled
        fileExtension.enabled = inverseEnabled
        XCTAssertEqual(isEnabled, inverseEnabled, "The key-value observing change notification for the WCLFileExtensions's enabled property should have occurred.")
        XCTAssertEqual(fileExtension.enabled, inverseEnabled, "The WCLFileExtension's isEnabled should equal the inverse enabled.")

        // Test NSUserDefaults
        var enabledInDictionary = fileExtensionPluginDictionary.valueForKey(testFileExtensionEnabledKeyPath) as Bool
        XCTAssertEqual(enabledInDictionary, fileExtension.enabled, "The enabled value in the dictionary should match the WCLFileExtension's enabled property")

        // Test key-value observing for the enabled property
        isEnabled = fileExtension.enabled
        WCLKeyValueObservingTestsHelper.observeObject(fileExtension,
            forKeyPath: testFileExtensionEnabledKeyPath,
            options: NSKeyValueObservingOptions.New)
        {
            ([NSObject : AnyObject]!) -> Void in
            isEnabled = self.fileExtension.enabled
        }

        inverseEnabled = !fileExtension.enabled
        fileExtension.enabled = inverseEnabled
        XCTAssertEqual(isEnabled, inverseEnabled, "The key-value observing change notification for the WCLFileExtensions's enabled property should have occurred.")
        XCTAssertEqual(fileExtension.enabled, inverseEnabled, "The WCLFileExtension's isEnabled should equal the inverse enabled.")

        // Test NSUserDefaults
        enabledInDictionary = fileExtensionPluginDictionary.valueForKey(testFileExtensionEnabledKeyPath) as Bool
        XCTAssertEqual(enabledInDictionary, fileExtension.enabled, "The enabled value in the dictionary should match the WCLFileExtension's enabled property")
    }

    func testSettingSelectedPlugin() {
        var observedChange = false
        WCLKeyValueObservingTestsHelper.observeObject(fileExtension,
            forKeyPath: testFileExtensionSelectedPluginKeyPath,
            options: NSKeyValueObservingOptions.New)
        {
            ([NSObject : AnyObject]!) -> Void in
            observedChange = true
        }

        XCTAssertFalse(observedChange, "The change should not have been observed.")
        fileExtension.selectedPlugin = plugin
        XCTAssertTrue(observedChange, "The key-value observing change should have occurred.")
        XCTAssertEqual(fileExtension.selectedPlugin, plugin, "The WCLFileExtension's selected WCLPlugin should equal the WCLPlugin.")
        confirmPluginIdentifierInFileExtensionPluginDictionary()

        // Test changing the selected plugin
        
        var createdPlugin = newPluginWithConfirmation()
        createdPlugin.suffixes = testPluginSuffixes

        observedChange = false
        WCLKeyValueObservingTestsHelper.observeObject(fileExtension,
            forKeyPath: testFileExtensionSelectedPluginKeyPath,
            options: NSKeyValueObservingOptions.New)
        {
                ([NSObject : AnyObject]!) -> Void in
                observedChange = true
        }
        XCTAssertFalse(observedChange, "The change should not have been observed.")
        fileExtension.selectedPlugin = createdPlugin
        XCTAssertTrue(observedChange, "The key-value observing change should have occurred.")
        XCTAssertEqual(fileExtension.selectedPlugin, createdPlugin, "The WCLFileExtension's selected WCLPlugin should equal the WCLPlugin.")
        confirmPluginIdentifierInFileExtensionPluginDictionary()
        
        // Test setting the selected plugin to nil

        observedChange = false
        WCLKeyValueObservingTestsHelper.observeObject(fileExtension,
            forKeyPath: testFileExtensionSelectedPluginKeyPath,
            options: NSKeyValueObservingOptions.New)
        {
            ([NSObject : AnyObject]!) -> Void in
            observedChange = true
        }
        XCTAssertFalse(observedChange, "The change should not have been observed.")
        fileExtension.selectedPlugin = nil
        XCTAssertTrue(observedChange, "The key-value observing change should have occurred.")
        XCTAssertEqual(fileExtension.selectedPlugin, fileExtension.plugins()[0] as Plugin, "The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.")
        confirmPluginIdentifierInFileExtensionPluginDictionary()
    }

    func testChangingPluginsFileExtensions() {
        var createdPlugin = newPluginWithConfirmation()
        createdPlugin.suffixes = testPluginSuffixesEmpty

        XCTAssertFalse(contains(fileExtension.plugins() as [Plugin], createdPlugin), "The WCLFileExtension's WCLPlugins should not contain the new WCLPlugin.")

        var plugins = fileExtension.plugins() as [Plugin]
        WCLKeyValueObservingTestsHelper.observeObject(fileExtension,
            forKeyPath: testFileExtensionPluginsKey,
            options: NSKeyValueObservingOptions.New)
        {
            ([NSObject : AnyObject]!) -> Void in
            plugins = self.fileExtension.plugins() as [Plugin]
        }
        XCTAssertFalse(contains(plugins, createdPlugin), "The WCLPlugins should not contain the new WCLPlugin.")
        createdPlugin.suffixes = testPluginSuffixes
        XCTAssertTrue(contains(plugins, createdPlugin), "The key-value observing change notification for the WCLFileExtensions's WCLPlugins property should have occurred.")
        XCTAssertTrue(contains(fileExtension.plugins() as [Plugin], createdPlugin), "The WCLFileExtension's WCLPlugins should contain the new WCLPlugin.")

        fileExtension.selectedPlugin = createdPlugin
        
        // Test removing the file extension

        // Test key-value observing for the plugins property
        WCLKeyValueObservingTestsHelper.observeObject(fileExtension,
            forKeyPath: testFileExtensionPluginsKey,
            options: NSKeyValueObservingOptions.New)
        {
            ([NSObject : AnyObject]!) -> Void in
            plugins = self.fileExtension.plugins() as [Plugin]
        }

        // Test key-value observing for the selected plugin property
        var observedChange = false
        WCLKeyValueObservingTestsHelper.observeObject(fileExtension,
            forKeyPath: testFileExtensionSelectedPluginKeyPath,
            options: NSKeyValueObservingOptions.New)
        {
            ([NSObject : AnyObject]!) -> Void in
            observedChange = true
        }
        XCTAssertFalse(observedChange, "The change should not have been observed.")

        createdPlugin.suffixes = testPluginSuffixesEmpty

        // Test the file extensions plugins property changed
        XCTAssertFalse(contains(plugins, createdPlugin), "The key-value observing change notification for the WCLFileExtensions's WCLPlugins property should have occurred.")
        XCTAssertFalse(contains(fileExtension.plugins() as [Plugin], createdPlugin), "The WCLFileExtension's WCLPlugins should not contain the new WCLPlugin.")

        // Test the file extensions selected plugin property changed
        XCTAssertTrue(observedChange, "The key-value observing change should have occurred.")
        XCTAssertNotEqual(fileExtension.selectedPlugin, createdPlugin, "The WCLFileExtension's selected WCLPlugin should not be the new WCLPlugin.")
        XCTAssertEqual(fileExtension.selectedPlugin, fileExtension.plugins()[0] as Plugin, "The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.")

        confirmPluginIdentifierInFileExtensionPluginDictionary()
    }

    func testDeletingSelectedPlugin() {
        var createdPlugin = newPluginWithConfirmation()
        createdPlugin.suffixes = testPluginSuffixes
        fileExtension.selectedPlugin = createdPlugin

        // Test key-value observing for the plugins property
        var plugins = fileExtension.plugins() as [Plugin]
        WCLKeyValueObservingTestsHelper.observeObject(fileExtension,
            forKeyPath: testFileExtensionPluginsKey,
            options: NSKeyValueObservingOptions.New)
        {
            ([NSObject : AnyObject]!) -> Void in
            plugins = self.fileExtension.plugins() as [Plugin]
        }
        
        // Test key-value observing for the selected plugin property
        var observedChange = false
        WCLKeyValueObservingTestsHelper.observeObject(fileExtension,
            forKeyPath: testFileExtensionSelectedPluginKeyPath,
            options: NSKeyValueObservingOptions.New)
            {
                ([NSObject : AnyObject]!) -> Void in
                observedChange = true
        }
        XCTAssertFalse(observedChange, "The change should not have been observed.")

        // Move plugin to trash
        movePluginToTrashAndCleanUpWithConfirmation(createdPlugin)

        // Test the file extensions plugins property changed
        XCTAssertFalse(contains(plugins, createdPlugin), "The key-value observing change notification for the WCLFileExtensions's WCLPlugins property should have occurred.")
        XCTAssertFalse(contains(fileExtension.plugins() as [Plugin], createdPlugin), "The WCLFileExtension's WCLPlugins should not contain the new WCLPlugin.")

        // Test the file extensions selected plugin property changed
        XCTAssertTrue(observedChange, "The key-value observing change should have occurred.")
        XCTAssertNotEqual(fileExtension.selectedPlugin, createdPlugin, "The WCLFileExtension's selected WCLPlugin should not be the new WCLPlugin.")
        XCTAssertEqual(fileExtension.selectedPlugin, fileExtension.plugins()[0] as Plugin, "The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.")
        
        confirmPluginIdentifierInFileExtensionPluginDictionary()
    }

}
