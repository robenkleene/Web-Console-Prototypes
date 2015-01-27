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

    // MARK: Helper
    
    func matchesPlugin(plugin: Plugin, forFileExtension fileExtension: WCLFileExtension) -> Bool {
        let suffix = fileExtension.suffix
        
        let plugins = fileExtension.plugins() as NSArray
        let containsPlugin = plugins.containsObject(plugin)
        
        let suffixes = plugin.fileSuffixes as NSArray
        let containsSuffix = suffixes.containsObject(suffix)
        
        return containsPlugin == containsSuffix
    }
    
    override func setUp() {
        super.setUp()

        // TODO: Assert existing plugin settings in userDefaults are nil? I.e., [WCLFileExtension fileExtensionToPluginDictionary]

        plugin.fileSuffixes = testPluginFileSuffixes
        XCTAssertEqual(FileExtensionsController.sharedInstance.suffixes().count, 1, "The file extensions count should equal one.")
    }

    override func tearDown() {
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: fileExtensionToPluginKey)
        super.tearDown()
    }
    
    func testNewFileExtensionProperties() {
        let fileExtension = FileExtensionsController.sharedInstance.fileExtensionForSuffix(testPluginFileSuffix)
        
        let suffix = fileExtension.suffix
        XCTAssertEqual(fileExtension.suffix, testPluginFileSuffix, "The WCLFileExtension's extension should equal the test extension.")
        XCTAssertEqual(fileExtension.enabled, defaultFileExtensionEnabled, "The WCLFileExtension's enabled should equal the default enabled.")
        XCTAssertEqual(fileExtension.selectedPlugin, fileExtension.plugins()[0] as Plugin, "The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.")

        let plugins = PluginsManager.sharedInstance.plugins() as [Plugin]
        for plugin in plugins {
            let matches = matchesPlugin(plugin, forFileExtension: fileExtension)
            XCTAssertTrue(matches, "The WCLPlugin should match the WCLFileExtension.")
        }
    }
    
    func testSettingEnabled() {
        let fileExtension = FileExtensionsController.sharedInstance.fileExtensionForSuffix(testPluginFileSuffix)

        var isEnabled = fileExtension.enabled
        WCLKeyValueObservingTestsHelper.observeObject(fileExtension,
            forKeyPath: testFileExtensionEnabledKeyPath,
            options: NSKeyValueObservingOptions.New)
        {
            ([NSObject : AnyObject]!) -> Void in
            isEnabled = fileExtension.enabled
        }

        var inverseEnabled = !fileExtension.enabled
        fileExtension.enabled = inverseEnabled
        XCTAssertEqual(isEnabled, inverseEnabled, "The key-value observing change notification for the WCLFileExtensions's enabled property should have occurred.")
        XCTAssertEqual(fileExtension.enabled, inverseEnabled, "The WCLFileExtension's isEnabled should equal the inverse enabled.")

        // Test NSUserDefaults
        var fileExtensionToPluginDictionary = WCLFileExtension.fileExtensionToPluginDictionary()
        var fileExtensionPluginDictionary = fileExtensionToPluginDictionary[fileExtension.suffix] as NSDictionary
        var enabledInDictionary = fileExtensionPluginDictionary.valueForKey(testFileExtensionEnabledKeyPath) as Bool
        XCTAssertEqual(enabledInDictionary, fileExtension.enabled, "The enabled value in the dictionary should match the WCLFileExtension's enabled property")

        // Test key-value observing for the enabled property
        isEnabled = fileExtension.enabled
        WCLKeyValueObservingTestsHelper.observeObject(fileExtension,
            forKeyPath: testFileExtensionEnabledKeyPath,
            options: NSKeyValueObservingOptions.New)
        {
            ([NSObject : AnyObject]!) -> Void in
            isEnabled = fileExtension.enabled
        }

        inverseEnabled = !fileExtension.enabled
        fileExtension.enabled = inverseEnabled
        XCTAssertEqual(isEnabled, inverseEnabled, "The key-value observing change notification for the WCLFileExtensions's enabled property should have occurred.")
        XCTAssertEqual(fileExtension.enabled, inverseEnabled, "The WCLFileExtension's isEnabled should equal the inverse enabled.")

        // Test NSUserDefaults
        fileExtensionToPluginDictionary = WCLFileExtension.fileExtensionToPluginDictionary()
        fileExtensionPluginDictionary = fileExtensionToPluginDictionary[fileExtension.suffix] as NSDictionary
        enabledInDictionary = fileExtensionPluginDictionary.valueForKey(testFileExtensionEnabledKeyPath) as Bool
        XCTAssertEqual(enabledInDictionary, fileExtension.enabled, "The enabled value in the dictionary should match the WCLFileExtension's enabled property")
    }

    func testSettingSelectedPlugin() {
        let fileExtension = FileExtensionsController.sharedInstance.fileExtensionForSuffix(testPluginFileSuffix)

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

        // Test NSUserDefaults
        var fileExtensionToPluginDictionary = WCLFileExtension.fileExtensionToPluginDictionary()
        var fileExtensionPluginDictionary = fileExtensionToPluginDictionary[fileExtension.suffix] as NSDictionary
        var pluginIdentifierInDictionary = fileExtensionPluginDictionary.valueForKey(testFileExtensionPluginIdentifierKey) as String
        XCTAssertEqual(pluginIdentifierInDictionary, fileExtension.selectedPlugin.identifier, "The WCLPlugin's identifier value in the dictionary should match the WCLFileExtension's selected WCLPlugin's identifier.")

        // Test changing the selected plugin
        
        var createdPlugin: Plugin!
        let createdPluginExpectation = expectationWithDescription("Create new plugin")
        PluginsManager.sharedInstance.newPlugin { (newPlugin) -> Void in
            createdPlugin = newPlugin
            createdPluginExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        
        createdPlugin.fileSuffixes = testPluginFileSuffixes

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

        // Test NSUserDefaults
        fileExtensionToPluginDictionary = WCLFileExtension.fileExtensionToPluginDictionary()
        fileExtensionPluginDictionary = fileExtensionToPluginDictionary[fileExtension.suffix] as NSDictionary
        pluginIdentifierInDictionary = fileExtensionPluginDictionary.valueForKey(testFileExtensionPluginIdentifierKey) as String
        XCTAssertEqual(pluginIdentifierInDictionary, fileExtension.selectedPlugin.identifier, "The WCLPlugin's identifier value in the dictionary should match the WCLFileExtension's selected WCLPlugin's identifier.")

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

        // Test NSUserDefaults
        fileExtensionToPluginDictionary = WCLFileExtension.fileExtensionToPluginDictionary()
        fileExtensionPluginDictionary = fileExtensionToPluginDictionary[fileExtension.suffix] as NSDictionary
        pluginIdentifierInDictionary = fileExtensionPluginDictionary.valueForKey(testFileExtensionPluginIdentifierKey) as String
        XCTAssertEqual(pluginIdentifierInDictionary, fileExtension.selectedPlugin.identifier, "The WCLPlugin's identifier value in the dictionary should match the WCLFileExtension's selected WCLPlugin's identifier.")
    }

// - (void)testChangingPluginsFileExtensions
// {
//     WCLFileExtension_old *fileExtension = [[WCLFileExtensionController_old sharedFileExtensionController] fileExtensionForExtension:kTestExtension];
//     WCLPlugin_old *newPlugin = [self addedPlugin];
//     XCTAssertFalse([fileExtension.plugins containsObject:newPlugin], @"The WCLFileExtension's WCLPlugins should not contain the new WCLPlugin.");
//
//     // Test key-value observing for the plugins property
//     __block NSArray *plugins = [fileExtension.plugins copy];
//     [WCLKeyValueObservingTestsHelper observeObject:fileExtension
//                                         forKeyPath:WCLFileExtensionPluginsKey
//                                            options:NSKeyValueObservingOptionNew
//                                    completionBlock:^(NSDictionary *change) {
//                                                plugins = [fileExtension.plugins copy];
//                                            }];
//     XCTAssertFalse([plugins containsObject:newPlugin], @"The WCLPlugins should not contain the new WCLPlugin.");
//     newPlugin.extensions = kTestExtensionsOne;
//     XCTAssertTrue([plugins containsObject:newPlugin], @"The key-value observing change notification for the WCLFileExtensions's WCLPlugins property should have occurred.");
//     XCTAssertTrue([fileExtension.plugins containsObject:newPlugin], @"The WCLFileExtension's WCLPlugins should contain the new WCLPlugin.");
//
//     // Test removing the file extension
//
//     // Test key-value observing for the plugins property
//     [WCLKeyValueObservingTestsHelper observeObject:fileExtension
//                                         forKeyPath:WCLFileExtensionPluginsKey
//                                            options:NSKeyValueObservingOptionNew
//                                    completionBlock:^(NSDictionary *change) {
//                                                plugins = [fileExtension.plugins copy];
//                                            }];
//
//     // Test key-value observing for the selected plugin property
//     fileExtension.selectedPlugin = newPlugin;
//     __block BOOL observedChange = NO;
//     [WCLKeyValueObservingTestsHelper observeObject:fileExtension
//                                         forKeyPath:kTestFileExtensionSelectedPluginKeyPath
//                                            options:NSKeyValueObservingOptionNew
//                                    completionBlock:^(NSDictionary *change) {
//                                                observedChange = YES;
//                                            }];
//     XCTAssertFalse(observedChange, @"The change should not have been observed.");
//
//     newPlugin.extensions = kTestExtensionsEmpty;
//
//     // Test the file extensions plugins property changed
//     XCTAssertFalse([plugins containsObject:newPlugin], @"The key-value observing change notification for the WCLFileExtensions's WCLPlugins property should have occurred.");
//     XCTAssertFalse([fileExtension.plugins containsObject:newPlugin], @"The WCLFileExtension's WCLPlugins should not contain the new WCLPlugin.");
//
//     // Test the file extensions selected plugin property changed
//     XCTAssertTrue(observedChange, @"The key-value observing change should have occurred.");
//     XCTAssertNotEqual(fileExtension.selectedPlugin, newPlugin, @"The WCLFileExtension's selected WCLPlugin should not be the new WCLPlugin.");
//     XCTAssertEqual(fileExtension.selectedPlugin, [fileExtension.plugins firstObject], @"The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.");
//
//     // Test key was removed from NSUserDefaults
//     NSDictionary *fileExtensionToPluginDictionary = [WCLFileExtension_old fileExtensionToPluginDictionary];
//     NSDictionary *fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
//     NSString *pluginIdentifierInDictionary = [fileExtensionPluginDictionary valueForKey:kFileExtensionPluginIdentifierKey];
//     XCTAssertEqual(pluginIdentifierInDictionary, fileExtension.selectedPlugin.identifier, @"The WCLPlugin's identifier value in the dictionary should equal the select WCLPlugin's identifier.");
// }
//
// - (void)testDeletingSelectedPlugin
// {
//     WCLFileExtension_old *fileExtension = [[WCLFileExtensionController_old sharedFileExtensionController] fileExtensionForExtension:kTestExtension];
//     WCLPlugin_old *newPlugin = [self addedPlugin];
//     newPlugin.extensions = kTestExtensionsOne;
//
//     fileExtension.selectedPlugin = newPlugin;
//
//     // Test key-value observing for the plugins property
//     __block NSArray *plugins = [fileExtension.plugins copy];
//     [WCLKeyValueObservingTestsHelper observeObject:fileExtension
//                                         forKeyPath:WCLFileExtensionPluginsKey
//                                            options:NSKeyValueObservingOptionNew
//                                    completionBlock:^(NSDictionary *change) {
//                                        plugins = [fileExtension.plugins copy];
//                                    }];
//
//     // Test key-value observing for the selected plugin property
//     fileExtension.selectedPlugin = newPlugin;
//     __block BOOL observedChange = NO;
//     [WCLKeyValueObservingTestsHelper observeObject:fileExtension
//                                         forKeyPath:kTestFileExtensionSelectedPluginKeyPath
//                                            options:NSKeyValueObservingOptionNew
//                                    completionBlock:^(NSDictionary *change) {
//                                        observedChange = YES;
//                                    }];
//     XCTAssertFalse(observedChange, @"The change should not have been observed.");
//
//     [self deletePlugin:newPlugin];
//
//     // Test the file extensions plugins property changed
//     XCTAssertFalse([plugins containsObject:newPlugin], @"The key-value observing change notification for the WCLFileExtensions's WCLPlugins property should have occurred.");
//     XCTAssertFalse([fileExtension.plugins containsObject:newPlugin], @"The WCLFileExtension's WCLPlugins should not contain the new WCLPlugin.");
//
//     // Test the file extensions selected plugin property changed
//     XCTAssertTrue(observedChange, @"The key-value observing change should have occurred.");
//     XCTAssertNotEqual(fileExtension.selectedPlugin, newPlugin, @"The WCLFileExtension's selected WCLPlugin should not be the new WCLPlugin.");
//     XCTAssertEqual(fileExtension.selectedPlugin, [fileExtension.plugins firstObject], @"The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.");
//
//     // Test key was removed from NSUserDefaults
//     NSDictionary *fileExtensionToPluginDictionary = [WCLFileExtension_old fileExtensionToPluginDictionary];
//     NSDictionary *fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
//     NSString *pluginIdentifierInDictionary = [fileExtensionPluginDictionary valueForKey:kFileExtensionPluginIdentifierKey];
//     XCTAssertEqual(pluginIdentifierInDictionary, fileExtension.selectedPlugin.identifier, @"The WCLPlugin identifier value in the dictionary should equal the select WCLPlugin's identifier.");
// }
// 
// // TODO: Test selectedPlugin validation
// 
// #pragma mark Helpers
// 
// + (BOOL)plugin:(WCLPlugin_old *)plugin matchesForFileExtension:(WCLFileExtension_old *)fileExtension
// {
//     NSString *extension = fileExtension.extension;
// 
//     BOOL containsPlugin = [fileExtension.plugins containsObject:plugin];
//     BOOL containsFileExtesion = [plugin.extensions containsObject:extension];
//     
//     return containsPlugin == containsFileExtesion;
// }
//
}
