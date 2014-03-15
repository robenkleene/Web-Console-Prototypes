//
//  WCLFileExtensionsControllerTests.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WCLFileExtensionController.h"

#import "WCLPluginManagerController.h"
#import "WCLTestPluginManager.h"

@interface WCLFileExtensionsControllerTests : XCTestCase
@end

@implementation WCLFileExtensionsControllerTests

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

- (void)testAddingPluginWithNoFileExtensions
{
    WCLPlugin *plugin = [[self pluginManager] newPlugin];
    [[self pluginManagerController] insertObject:plugin inPluginsAtIndex:0];

    
    
//    id newObject = [self.pluginArrayController newObject];
//    [self.pluginArrayController addObject:newObject];
    
    
//    [WCLPluginManagerController ]
    
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

#pragma mark Helpers

- (WCLTestPluginManager *)pluginManager
{
    return [WCLTestPluginManager sharedPluginManager];
}

- (WCLTestPluginManagerController *)pluginManagerController
{
    return [WCLTestPluginManagerController sharedPluginManagerController];
}

@end
