//
//  PluginManagerDefaultNewPluginTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/17/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginsManagerDefaultNewPluginTests: PluginsManagerTestCase {

    override func setUp() {
        super.setUp()
        PluginsManager.sharedInstance.defaultNewPlugin = plugin
    }
    override func tearDown() {
        PluginsManager.sharedInstance.defaultNewPlugin = nil
        super.tearDown()
    }
    
    func testSettingAndDeletingDefaultNewPlugin() {
        var newPlugin: Plugin!
        let newPluginExpectation = expectationWithDescription("Create new plugin")
        PluginsManager.sharedInstance.newPlugin { (createdPlugin) -> Void in
            newPlugin = createdPlugin
            newPluginExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        
        PluginsManager.sharedInstance.defaultNewPlugin = newPlugin
        
        // Assert the WCLPlugin's isDefaultNewPlugin property
        XCTAssertTrue(newPlugin.defaultNewPlugin, "The WCLPlugin should be the default new WCLPlugin.")
        
        // Assert the default new plugin identifier in NSUserDefaults
        let defaultNewPluginIdentifier: String! = NSUserDefaults.standardUserDefaults().stringForKey(defaultNewPluginIdentifierKey)
        XCTAssertEqual(newPlugin.identifier, defaultNewPluginIdentifier, "The default WCLPlugin's identifier should equal the WCLPlugin's identifier.")

        // Assert the default new plugin is returned from the WCLPluginManager
        let defaultNewPlugin = PluginsManager.sharedInstance.defaultNewPlugin
        XCTAssertEqual(defaultNewPlugin, newPlugin, "The default new WCLPlugin should be the WCLPlugin.")
    
        movePluginToTrashAndCleanUpWithConfirmation(newPlugin)

        let defaultNewPluginTwo = PluginsManager.sharedInstance.defaultNewPlugin
        XCTAssertNil(defaultNewPluginTwo, "The default WCLPlugin should be nil.")
        let defaultNewPluginIdentifierTwo = NSUserDefaults.standardUserDefaults().stringForKey(defaultNewPluginIdentifierKey)
        XCTAssertNil(defaultNewPluginIdentifierTwo, "The default new WCLPlugin identifier should be nil.")
    }
    
    //- (void)testChangingDefaultNewPlugin
    //{
    //    WCLPlugin_old *plugin = [[WCLPluginManager_old sharedPluginManager] newPlugin];
    //    [[WCLPluginManager_old sharedPluginManager] setDefaultNewPlugin:plugin];
    //
    //    XCTAssertTrue(plugin.isDefaultNewPlugin, @"The WCLPlugin should be the default WCLPlugin.");
    //
    //    WCLPlugin_old *pluginTwo = [[WCLPluginManager_old sharedPluginManager] newPlugin];
    //    [[WCLPluginManager_old sharedPluginManager] setDefaultNewPlugin:pluginTwo];
    //
    //    XCTAssertFalse(plugin.isDefaultNewPlugin, @"The WCLPlugin should not be the default WCLPlugin.");
    //    XCTAssertTrue(pluginTwo.isDefaultNewPlugin, @"The second WCLPlugin should be the default WCLPlugin.");
    //    WCLPlugin_old *defaultNewPlugin = [[WCLPluginManager_old sharedPluginManager] defaultNewPlugin];
    //    XCTAssertEqual(defaultNewPlugin, pluginTwo, @"The default WCLPlugin should be the second WCLPlugin.");
    //}
    //
    //- (void)testDefaultNewPlugin
    //{
    //    WCLPlugin_old *plugin = [[WCLPluginManager_old sharedPluginManager] newPlugin];
    //    plugin.name = kTestPluginName;
    //    plugin.extensions = kTestExtensions;
    //    plugin.command = kTestPluginCommand;
    //
    //    [[WCLPluginManager_old sharedPluginManager] setDefaultNewPlugin:plugin];
    //
    //    WCLPlugin_old *newPlugin = [[WCLPluginManager_old sharedPluginManager] newPlugin];
    //
    //    XCTAssertTrue([newPlugin.name hasPrefix:plugin.name], @"The new WCLPlugin's name should start with the WCLPlugin's name.");
    //    XCTAssertFalse([newPlugin.name isEqualToString:plugin.name], @"The new WCLPlugin's name should not equal the WCLPlugin's name.");
    //    XCTAssertTrue([newPlugin.command isEqualToString:plugin.command], @"The new WCLPlugin's command should equal the WCLPlugin's command.");
    //    XCTAssertTrue([newPlugin.extensions isEqualToArray:plugin.extensions], @"The new WCLPlugin's file extensions should equal the WCLPlugin's file extensions.");
    //}
    //
    //- (void)testSettingDefaultNewPluginToNil
    //{
    //    WCLPlugin_old *plugin = [[WCLPluginManager_old sharedPluginManager] newPlugin];
    //    plugin.name = kTestPluginName;
    //    [[WCLPluginManager_old sharedPluginManager] setDefaultNewPlugin:plugin];
    //    WCLPlugin_old *newPlugin = [[WCLPluginManager_old sharedPluginManager] newPlugin];
    //    XCTAssertTrue([newPlugin.name hasPrefix:plugin.name], @"The new WCLPlugin's name should start with the WCLPlugin's name.");
    //
    //    [[WCLPluginManager_old sharedPluginManager] setDefaultNewPlugin:nil];
    //    WCLPlugin_old *newPluginTwo = [[WCLPluginManager_old sharedPluginManager] newPlugin];
    //    XCTAssertTrue([newPluginTwo.name hasPrefix:kTestDefaultNewPluginName], @"The new WCLPlugin's name should start with the default new plugin name.");
    //}
    //
    //- (void)testDefaultNewPluginKeyValueObserving
    //{
    //    // Test that key-value observing notifications occur when a new plugin is set as the default new plugin
    //    WCLPlugin_old *plugin = [[WCLPluginManager_old sharedPluginManager] newPlugin];
    //    XCTAssertFalse(plugin.isDefaultNewPlugin, @"The WCLPlugin should not be the default new WCLPlugin.");
    //    __block BOOL isDefaultNewPlugin = plugin.isDefaultNewPlugin;
    //    [WCLKeyValueObservingTestsHelper observeObject:plugin
    //                                        forKeyPath:kTestPluginDefaultNewPluginKeyPath
    //                                           options:NSKeyValueObservingOptionNew
    //                                   completionBlock:^(NSDictionary *change) {
    //                                               isDefaultNewPlugin = plugin.isDefaultNewPlugin;
    //                                           }];
    //    [[WCLPluginManager_old sharedPluginManager] setDefaultNewPlugin:plugin];
    //    XCTAssertTrue(isDefaultNewPlugin, @"The key-value observing change notification for the WCLPlugin's default new WCLPlugin property should have occurred.");
    //    XCTAssertTrue(plugin.isDefaultNewPlugin, @"The WCLPlugin should be the default new WCLPlugin.");
    //
    //    // Test that key-value observing notifications occur when second new plugin is set as the default new plugin
    //    WCLPlugin_old *pluginTwo = [[WCLPluginManager_old sharedPluginManager] newPlugin];
    //    XCTAssertFalse(pluginTwo.isDefaultNewPlugin, @"The second WCLPlugin should not be the default new WCLPlugin.");
    //    [WCLKeyValueObservingTestsHelper observeObject:plugin
    //                                        forKeyPath:kTestPluginDefaultNewPluginKeyPath
    //                                           options:NSKeyValueObservingOptionNew
    //                                   completionBlock:^(NSDictionary *change) {
    //                                               isDefaultNewPlugin = plugin.isDefaultNewPlugin;
    //                                           }];
    //    __block BOOL isDefaultNewPluginTwo = pluginTwo.isDefaultNewPlugin;
    //    [WCLKeyValueObservingTestsHelper observeObject:pluginTwo
    //                                        forKeyPath:kTestPluginDefaultNewPluginKeyPath
    //                                           options:NSKeyValueObservingOptionNew
    //                                   completionBlock:^(NSDictionary *change) {
    //                                               isDefaultNewPluginTwo = pluginTwo.isDefaultNewPlugin;
    //                                           }];
    //    [[WCLPluginManager_old sharedPluginManager] setDefaultNewPlugin:pluginTwo];
    //    XCTAssertFalse(isDefaultNewPlugin, @"The key-value observing change notification for the WCLPlugin's default new WCLPlugin property should have occurred.");
    //    XCTAssertTrue(isDefaultNewPluginTwo, @"The key-value observing change notification for the second WCLPlugin's default new WCLPlugin property should have occurred.");
    //    XCTAssertFalse(plugin.isDefaultNewPlugin, @"The WCLPlugin should not be the default new WCLPlugin.");
    //    XCTAssertTrue(pluginTwo.isDefaultNewPlugin, @"The second WCLPlugin should be the default new WCLPlugin.");
    //
    //    // Test that key-value observing notifications occur when the default new plugin is set to nil
    //    [WCLKeyValueObservingTestsHelper observeObject:pluginTwo
    //                                        forKeyPath:kTestPluginDefaultNewPluginKeyPath
    //                                           options:NSKeyValueObservingOptionNew
    //                                   completionBlock:^(NSDictionary *change) {
    //                                               isDefaultNewPluginTwo = pluginTwo.isDefaultNewPlugin;
    //                                           }];
    //    [[WCLPluginManager_old sharedPluginManager] setDefaultNewPlugin:nil];
    //    XCTAssertFalse(isDefaultNewPluginTwo, @"The key-value observing change notification for the second WCLPlugin's default new WCLPlugin property should have occurred.");
    //    XCTAssertFalse(pluginTwo.isDefaultNewPlugin, @"The second WCLPlugin should not be the default new WCLPlugin.");
    //}

}
