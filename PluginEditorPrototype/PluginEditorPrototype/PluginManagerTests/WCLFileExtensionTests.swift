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
        let fileSuffixes = FileExtensionsController.sharedInstance.fileExtensionForSuffix(testPluginFileSuffix)
        
//        let extension = fileExtension.extension
//        XCTAssertEqual(fileExtension.extension, testPluginExtension, "The WCLFileExtension's extension should equal the test extension.")
//        XCTAssertTrue(fileExtension.isEnabled == kFileExtensionDefaultEnabled, @"The WCLFileExtension's enabled should equal the default enabled.");
//        XCTAssertEqual(fileExtension.selectedPlugin, [fileExtension.plugins firstObject], @"The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.");

    }

// - (void)testNewFileExtensionProperties
// {
//     WCLFileExtension_old *fileExtension = [[WCLFileExtensionController_old sharedFileExtensionController] fileExtensionForExtension:kTestExtension];
//
//     XCTAssertTrue([fileExtension.extension isEqualToString:kTestExtension] , @"The WCLFileExtension's extension should equal the test extension.");
//     XCTAssertTrue(fileExtension.isEnabled == kFileExtensionDefaultEnabled, @"The WCLFileExtension's enabled should equal the default enabled.");
//     XCTAssertEqual(fileExtension.selectedPlugin, [fileExtension.plugins firstObject], @"The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.");
//
//     NSArray *plugins = [[WCLPluginManager_old sharedPluginManager] plugins];
//
//     for (WCLPlugin_old *plugin in plugins) {
//         BOOL matches = [[self class] plugin:plugin matchesForFileExtension:fileExtension];
//         XCTAssertTrue(matches, @"The WCLPlugin should match the WCLFileExtension.");
//     }
// }
//
// - (void)testSettingEnabled
// {
//     WCLFileExtension_old *fileExtension = [[WCLFileExtensionController_old sharedFileExtensionController] fileExtensionForExtension:kTestExtension];
//
//     // Test setting the enabled property
//
//     // Test key-value observing for the enabled property
//     __block BOOL isEnabled = fileExtension.isEnabled;
//     [WCLKeyValueObservingTestsHelper observeObject:fileExtension
//                                         forKeyPath:kTestFileExtensionEnabledKeyPath
//                                            options:NSKeyValueObservingOptionNew
//                                    completionBlock:^(NSDictionary *change) {
//                                                isEnabled = fileExtension.isEnabled;
//                                            }];
//     BOOL inverseEnabled = !fileExtension.isEnabled;
//     fileExtension.enabled = inverseEnabled;
//     XCTAssertEqual(isEnabled, inverseEnabled, @"The key-value observing change notification for the WCLFileExtensions's enabled property should have occurred.");
//     XCTAssertEqual(fileExtension.isEnabled, inverseEnabled, @"The WCLFileExtension's isEnabled should equal the inverse enabled.");
//
//     // Test NSUserDefaults is set
//     NSDictionary *fileExtensionToPluginDictionary = [WCLFileExtension_old fileExtensionToPluginDictionary];
//     NSDictionary *fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
//     BOOL enabledInDictionary = [[fileExtensionPluginDictionary valueForKey:kFileExtensionEnabledKey] boolValue];
//     XCTAssertEqual(enabledInDictionary, fileExtension.isEnabled, @"The enabled value in the dictionary should match the WCLFileExtension's enabled property");
//
//     // Test inverting the enabled property
//
//     // Test key-value observing for the enabled property
//     isEnabled = fileExtension.isEnabled;
//     [WCLKeyValueObservingTestsHelper observeObject:fileExtension
//                                         forKeyPath:kTestFileExtensionEnabledKeyPath
//                                            options:NSKeyValueObservingOptionNew
//                                    completionBlock:^(NSDictionary *change) {
//                                                isEnabled = fileExtension.isEnabled;
//                                            }];
//     inverseEnabled = !fileExtension.isEnabled;
//     fileExtension.enabled = inverseEnabled;
//     XCTAssertEqual(isEnabled, inverseEnabled, @"The key-value observing change notification for the WCLFileExtensions's enabled property should have occurred.");
//     XCTAssertEqual(fileExtension.isEnabled, inverseEnabled, @"The WCLFileExtension's isEnabled should equal the inverse enabled.");
//
//     // Test NSUserDefaults is set
//     fileExtensionToPluginDictionary = [WCLFileExtension_old fileExtensionToPluginDictionary];
//     fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
//     enabledInDictionary = [[fileExtensionPluginDictionary valueForKey:kFileExtensionEnabledKey] boolValue];
//     XCTAssertEqual(enabledInDictionary, fileExtension.isEnabled, @"The enabled value in the dictionary should match the WCLFileExtension's enabled property");
// }
//
// - (void)testSettingSelectedPlugin
// {
//     WCLFileExtension_old *fileExtension = [[WCLFileExtensionController_old sharedFileExtensionController] fileExtensionForExtension:kTestExtension];
//
//     // Test key-value observing for the selected plugin property
//     __block BOOL observedChange = NO;
//     [WCLKeyValueObservingTestsHelper observeObject:fileExtension
//                                         forKeyPath:kTestFileExtensionSelectedPluginKeyPath
//                                            options:NSKeyValueObservingOptionNew
//                                    completionBlock:^(NSDictionary *change) {
//                                                observedChange = YES;
//                                            }];
//     WCLPlugin_old *plugin = fileExtension.plugins[0];
//     XCTAssertFalse(observedChange, @"The change should not have been observed.");
//     fileExtension.selectedPlugin = plugin;
//     XCTAssertTrue(observedChange, @"The key-value observing change should have occurred.");
//     XCTAssertEqual(fileExtension.selectedPlugin, plugin, @"The WCLFileExtension's selected WCLPlugin should equal the WCLPlugin.");
//
//     // Test NSUserDefaults is set
//     NSDictionary *fileExtensionToPluginDictionary = [WCLFileExtension_old fileExtensionToPluginDictionary];
//     NSDictionary *fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
//     NSString *pluginIdentifierInDictionary = [fileExtensionPluginDictionary valueForKey:kFileExtensionPluginIdentifierKey];
//     XCTAssertEqual(pluginIdentifierInDictionary, fileExtension.selectedPlugin.identifier, @"The WCLPlugin's identifier value in the dictionary should match the WCLFileExtension's selected WCLPlugin's identifier.");
//
//     // Test changing the selected plugin
//
//     // Test key-value observing for the selected plugin property
//     WCLPlugin_old *newPlugin = [self addedPlugin];
//     newPlugin.extensions = kTestExtensionsOne;
//
//     observedChange = NO;
//     [WCLKeyValueObservingTestsHelper observeObject:fileExtension
//                                         forKeyPath:kTestFileExtensionSelectedPluginKeyPath
//                                            options:NSKeyValueObservingOptionNew
//                                    completionBlock:^(NSDictionary *change) {
//                                                observedChange = YES;
//                                            }];
//     XCTAssertFalse(observedChange, @"The change should not have been observed.");
//     fileExtension.selectedPlugin = newPlugin;
//     XCTAssertTrue(observedChange, @"The key-value observing change should have occurred.");
//     XCTAssertEqual(fileExtension.selectedPlugin, newPlugin, @"The WCLFileExtension's selected WCLPlugin should equal the WCLPlugin.");
//
//     // Test NSUserDefaults is set
//     fileExtensionToPluginDictionary = [WCLFileExtension_old fileExtensionToPluginDictionary];
//     fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
//     pluginIdentifierInDictionary = [fileExtensionPluginDictionary valueForKey:kFileExtensionPluginIdentifierKey];
//     XCTAssertEqual(pluginIdentifierInDictionary, fileExtension.selectedPlugin.identifier, @"The WCLPlugin identifier value in the dictionary should match the WCLFileExtension's selected WCLPlugin's identifier.");
//
//     // Test setting the selected plugin to nil
//
//     // Test key-value observing for the selected plugin property
//     observedChange = NO;
//     [WCLKeyValueObservingTestsHelper observeObject:fileExtension
//                                         forKeyPath:kTestFileExtensionSelectedPluginKeyPath
//                                            options:NSKeyValueObservingOptionNew
//                                    completionBlock:^(NSDictionary *change) {
//                                                observedChange = YES;
//                                            }];
//     XCTAssertFalse(observedChange, @"The change should not have been observed.");
//     fileExtension.selectedPlugin = nil;
//     XCTAssertTrue(observedChange, @"The key-value observing change should have occurred.");
//
//     XCTAssertEqual(fileExtension.selectedPlugin, [fileExtension.plugins firstObject], @"The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.");
//
//     // Test key was set in NSUserDefaults
//     fileExtensionToPluginDictionary = [WCLFileExtension_old fileExtensionToPluginDictionary];
//     fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
//     pluginIdentifierInDictionary = [fileExtensionPluginDictionary valueForKey:kFileExtensionPluginIdentifierKey];
//     XCTAssertEqual(pluginIdentifierInDictionary, fileExtension.selectedPlugin.identifier, @"The WCLPlugin's identifier value in the dictionary should equal the select WCLPlugin's identifier.");
// }
//
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
