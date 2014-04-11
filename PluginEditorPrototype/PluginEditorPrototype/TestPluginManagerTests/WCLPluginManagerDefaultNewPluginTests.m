//
//  WCLPluginManagerTests.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WCLTestPluginManagerTestCase.h"

#import "Web_ConsoleTestsConstants.h"

#import "WCLPluginManager.h"
#import "WCLPlugin.h"

#import "WCLKeyValueObservingTestsHelper.h"



@interface WCLPluginManagerDefaultNewPluginTests : WCLTestPluginManagerTestCase

@end

@implementation WCLPluginManagerDefaultNewPluginTests

- (void)setUp
{
    [super setUp];

    [[WCLPluginManager sharedPluginManager] setDefaultNewPlugin:nil];
}

- (void)tearDown
{
    [[WCLPluginManager sharedPluginManager] setDefaultNewPlugin:nil];
    
    [super tearDown];
}

- (void)testSettingDefaultNewPlugin
{
    WCLPlugin *plugin = [[WCLPluginManager sharedPluginManager] newPlugin];
    [[WCLPluginManager sharedPluginManager] setDefaultNewPlugin:plugin];
    
    // Assert the WCLPlugin's isDefaultNewPlugin property
    XCTAssertTrue(plugin.isDefaultNewPlugin, @"The WCLPlugin should be the default new WCLPlugin.");
    
    // Assert the default new plugin identifier in NSUserDefaults
    NSString *defaultNewPluginIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultNewPluginIdentifierKey];
    XCTAssertTrue([plugin.identifier isEqualToString:defaultNewPluginIdentifier], @"The default WCLPlugin's identifier should equal the WCLPlugin's identifier.");
    
    // Assert the default new plugin is returned from the WCLPluginManager
    WCLPlugin *defaultNewPlugin = [[WCLPluginManager sharedPluginManager] defaultNewPlugin];
    XCTAssertEqual(defaultNewPlugin, plugin, @"The default new WCLPlugin should be the WCLPlugin.");
}

- (void)testDeletingDefaultNewPlugin
{
    WCLPlugin *plugin = [[WCLPluginManager sharedPluginManager] newPlugin];
    [[WCLPluginManager sharedPluginManager] setDefaultNewPlugin:plugin];

    WCLPlugin *defaultNewPlugin = [[WCLPluginManager sharedPluginManager] defaultNewPlugin];
    XCTAssertNotNil(defaultNewPlugin, @"The default WCLPlugin should not be nil.");
    NSString *defaultNewPluginIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultNewPluginIdentifierKey];
    XCTAssertNotNil(defaultNewPluginIdentifier, @"The default new WCLPlugin identifier should not be nil.");
    
    [[WCLPluginManager sharedPluginManager] deletePlugin:plugin];

    defaultNewPlugin = [[WCLPluginManager sharedPluginManager] defaultNewPlugin];
    XCTAssertNil(defaultNewPlugin, @"The default WCLPlugin should be nil.");
    defaultNewPluginIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultNewPluginIdentifierKey];
    XCTAssertNil(defaultNewPluginIdentifier, @"The default new WCLPlugin identifier should be nil.");
}

- (void)testChangingDefaultNewPlugin
{
    WCLPlugin *plugin = [[WCLPluginManager sharedPluginManager] newPlugin];
    [[WCLPluginManager sharedPluginManager] setDefaultNewPlugin:plugin];

    XCTAssertTrue(plugin.isDefaultNewPlugin, @"The WCLPlugin should be the default WCLPlugin.");

    WCLPlugin *pluginTwo = [[WCLPluginManager sharedPluginManager] newPlugin];
    [[WCLPluginManager sharedPluginManager] setDefaultNewPlugin:pluginTwo];

    XCTAssertFalse(plugin.isDefaultNewPlugin, @"The WCLPlugin should not be the default WCLPlugin.");
    XCTAssertTrue(pluginTwo.isDefaultNewPlugin, @"The second WCLPlugin should be the default WCLPlugin.");
    WCLPlugin *defaultNewPlugin = [[WCLPluginManager sharedPluginManager] defaultNewPlugin];
    XCTAssertEqual(defaultNewPlugin, pluginTwo, @"The default WCLPlugin should be the second WCLPlugin.");
}

- (void)testDefaultNewPlugin
{
    WCLPlugin *plugin = [[WCLPluginManager sharedPluginManager] newPlugin];
    plugin.name = kTestPluginName;
    plugin.extensions = kTestExtensions;
    plugin.command = kTestPluginCommand;

    [[WCLPluginManager sharedPluginManager] setDefaultNewPlugin:plugin];
    
    WCLPlugin *newPlugin = [[WCLPluginManager sharedPluginManager] newPlugin];

    XCTAssertTrue([newPlugin.name hasPrefix:plugin.name], @"The new WCLPlugin's name should start with the WCLPlugin's name.");
    XCTAssertFalse([newPlugin.name isEqualToString:plugin.name], @"The new WCLPlugin's name should not equal the WCLPlugin's name.");
    XCTAssertTrue([newPlugin.command isEqualToString:plugin.command], @"The new WCLPlugin's command should equal the WCLPlugin's command.");
    XCTAssertTrue([newPlugin.extensions isEqualToArray:plugin.extensions], @"The new WCLPlugin's file extensions should equal the WCLPlugin's file extensions.");
}

- (void)testSettingDefaultNewPluginToNil
{
    WCLPlugin *plugin = [[WCLPluginManager sharedPluginManager] newPlugin];
    plugin.name = kTestPluginName;
    [[WCLPluginManager sharedPluginManager] setDefaultNewPlugin:plugin];
    WCLPlugin *newPlugin = [[WCLPluginManager sharedPluginManager] newPlugin];
    XCTAssertTrue([newPlugin.name hasPrefix:plugin.name], @"The new WCLPlugin's name should start with the WCLPlugin's name.");

    [[WCLPluginManager sharedPluginManager] setDefaultNewPlugin:nil];
    WCLPlugin *newPluginTwo = [[WCLPluginManager sharedPluginManager] newPlugin];
    XCTAssertTrue([newPluginTwo.name hasPrefix:kTestDefaultNewPluginName], @"The new WCLPlugin's name should start with the default new plugin name.");
}

- (void)testDefaultNewPluginKeyValueObserving
{
    // Test that key-value observing notifications occur when a new plugin is set as the default new plugin
    WCLPlugin *plugin = [[WCLPluginManager sharedPluginManager] newPlugin];
    XCTAssertFalse(plugin.isDefaultNewPlugin, @"The WCLPlugin should not be the default new WCLPlugin.");
    __block BOOL isDefaultNewPlugin = plugin.isDefaultNewPlugin;
    [WCLKeyValueObservingTestsHelper observeObject:plugin
                                        forKeyPath:kTestPluginDefaultNewPluginKeyPath
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
                                               isDefaultNewPlugin = plugin.isDefaultNewPlugin;
                                           }];
    [[WCLPluginManager sharedPluginManager] setDefaultNewPlugin:plugin];
    XCTAssertTrue(isDefaultNewPlugin, @"The key-value observing change notification for the WCLPlugin's default new WCLPlugin property should have occurred.");
    XCTAssertTrue(plugin.isDefaultNewPlugin, @"The WCLPlugin should be the default new WCLPlugin.");

    // Test that key-value observing notifications occur when second new plugin is set as the default new plugin
    WCLPlugin *pluginTwo = [[WCLPluginManager sharedPluginManager] newPlugin];
    XCTAssertFalse(pluginTwo.isDefaultNewPlugin, @"The second WCLPlugin should not be the default new WCLPlugin.");
    [WCLKeyValueObservingTestsHelper observeObject:plugin
                                        forKeyPath:kTestPluginDefaultNewPluginKeyPath
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
                                               isDefaultNewPlugin = plugin.isDefaultNewPlugin;
                                           }];
    __block BOOL isDefaultNewPluginTwo = pluginTwo.isDefaultNewPlugin;
    [WCLKeyValueObservingTestsHelper observeObject:pluginTwo
                                        forKeyPath:kTestPluginDefaultNewPluginKeyPath
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
                                               isDefaultNewPluginTwo = pluginTwo.isDefaultNewPlugin;
                                           }];
    [[WCLPluginManager sharedPluginManager] setDefaultNewPlugin:pluginTwo];
    XCTAssertFalse(isDefaultNewPlugin, @"The key-value observing change notification for the WCLPlugin's default new WCLPlugin property should have occurred.");
    XCTAssertTrue(isDefaultNewPluginTwo, @"The key-value observing change notification for the second WCLPlugin's default new WCLPlugin property should have occurred.");
    XCTAssertFalse(plugin.isDefaultNewPlugin, @"The WCLPlugin should not be the default new WCLPlugin.");
    XCTAssertTrue(pluginTwo.isDefaultNewPlugin, @"The second WCLPlugin should be the default new WCLPlugin.");

    // Test that key-value observing notifications occur when the default new plugin is set to nil
    [WCLKeyValueObservingTestsHelper observeObject:pluginTwo
                                        forKeyPath:kTestPluginDefaultNewPluginKeyPath
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
                                               isDefaultNewPluginTwo = pluginTwo.isDefaultNewPlugin;
                                           }];
    [[WCLPluginManager sharedPluginManager] setDefaultNewPlugin:nil];
    XCTAssertFalse(isDefaultNewPluginTwo, @"The key-value observing change notification for the second WCLPlugin's default new WCLPlugin property should have occurred.");
    XCTAssertFalse(pluginTwo.isDefaultNewPlugin, @"The second WCLPlugin should not be the default new WCLPlugin.");
}

@end
