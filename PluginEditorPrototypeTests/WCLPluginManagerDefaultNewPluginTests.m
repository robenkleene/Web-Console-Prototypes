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

#define kTestPluginName @"Test Plugin"

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
    newPlugin.name = kTestPluginName;

    [[self pluginManager] setDefaultNewPlugin:newPlugin];
    
    // Assert that the identifier is set correctly
    NSString *defaultNewPluginIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultNewPluginIdentifier];
    XCTAssertTrue([newPlugin.identifier isEqualToString:defaultNewPluginIdentifier], @"The default new WCLPlugin's identifier should equal the WCLPlugin's identifier.");
    
    // Assert that the default new plugin is returned
    WCLPlugin *defaultNewPlugin = [[self pluginManager] defaultNewPlugin];
    XCTAssertTrue([defaultNewPlugin.name isEqualToString:kTestPluginName], @"The default new WCLPlugin's name should equal the test plugin name.");
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

@end
