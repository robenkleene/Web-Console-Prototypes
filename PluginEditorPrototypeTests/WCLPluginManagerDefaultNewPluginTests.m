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
    
    
    // Assert that the default new plugin is returned
    WCLPlugin *defaultNewPlugin = [[self pluginManager] defaultNewPlugin];
    XCTAssertTrue([defaultNewPlugin.name isEqualToString:kTestPluginName], @"The default new plugins name should equal the test plugin name.");
}

- (void)testDeletingDefaultNewPlugin
{
    WCLPlugin *newPlugin = [[self pluginManager] newPlugin];
    [[self pluginManager] setDefaultNewPlugin:newPlugin];

    XCTAssertNotNil([[self pluginManager] defaultNewPlugin], @"The default new plugin should not be nil.");

    [[self pluginManager] deletePlugin:newPlugin];

    XCTAssertNil([[self pluginManager] defaultNewPlugin], @"The default new plugin should be nil.");
}

@end
