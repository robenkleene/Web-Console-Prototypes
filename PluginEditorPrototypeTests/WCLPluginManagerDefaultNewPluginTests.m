//
//  WCLPluginManagerTests.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WCLTestPluginManagerTestCase.h"
#import "WCLTestPluginManager.h"

//#define kTestPluginName @"Test Plugin"

@interface WCLPluginManagerDefaultNewPluginTests : WCLTestPluginManagerTestCase

@end

@implementation WCLPluginManagerDefaultNewPluginTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSettingDefaultNewPlugin
{
    WCLPlugin *newPlugin = [[self pluginManager] newPlugin];

    [[self pluginManager] setDefaultNewPlugin:newPlugin];
    
    // Assert the WCLPlugin's isDefaultNewPlugin property
    XCTAssertTrue(newPlugin.isDefaultNewPlugin, @"The WCLPlugin should be the default new plugin.");
    
    // Assert the default new plugin identifier in NSUserDefaults
    NSString *defaultNewPluginIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultNewPluginIdentifier];
    XCTAssertTrue([newPlugin.identifier isEqualToString:defaultNewPluginIdentifier], @"The default new WCLPlugin's identifier should equal the WCLPlugin's identifier.");
    
    // Assert the default new plugin is returned from the WCLPluginManager
    WCLPlugin *defaultNewPlugin = [[self pluginManager] defaultNewPlugin];
    XCTAssertEqual(defaultNewPlugin, newPlugin, @"The default new WCLPlugin should be the new WCLPlugin.");
}

- (void)testDeletingDefaultNewPlugin
{
    WCLPlugin *newPlugin = [[self pluginManager] newPlugin];
    [[self pluginManager] setDefaultNewPlugin:newPlugin];

    WCLPlugin *defaultNewPlugin = [[self pluginManager] defaultNewPlugin];
    XCTAssertNotNil(defaultNewPlugin, @"The default new WCLPlugin should not be nil.");
    NSString *defaultNewPluginIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultNewPluginIdentifier];
    XCTAssertNotNil(defaultNewPluginIdentifier, @"The default new plugin identifier should not be nil.");
    
    [[self pluginManager] deletePlugin:newPlugin];

    defaultNewPlugin = [[self pluginManager] defaultNewPlugin];
    XCTAssertNil(defaultNewPlugin, @"The default new WCLPlugin should be nil.");
    defaultNewPluginIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultNewPluginIdentifier];
    XCTAssertNil(defaultNewPluginIdentifier, @"The default new plugin identifier should be nil.");
}

- (void)testChangingDefaultNewPlugin
{
    WCLPlugin *newPlugin = [[self pluginManager] newPlugin];
    [[self pluginManager] setDefaultNewPlugin:newPlugin];

    XCTAssertTrue(newPlugin.isDefaultNewPlugin, @"The WCLPlugin should be the default new plugin.");

    WCLPlugin *newPluginTwo = [[self pluginManager] newPlugin];
    [[self pluginManager] setDefaultNewPlugin:newPluginTwo];

    XCTAssertFalse(newPlugin.isDefaultNewPlugin, @"The WCLPlugin should not be the default new plugin.");
    XCTAssertTrue(newPluginTwo.isDefaultNewPlugin, @"The second WCLPlugin should be the default new plugin.");
    WCLPlugin *defaultNewPlugin = [[self pluginManager] defaultNewPlugin];
    XCTAssertEqual(defaultNewPlugin, newPluginTwo, @"The default new WCLPlugin should be the second new WCLPlugin.");
}

// Test that when creating a new plugin it is created from the default new plugin
// Do this by first changing a couple of properties on the plugin, not name, file extensions and command
// Actually test that the names are not equal, but that the second plugin begins with the default new plugins name
@end
