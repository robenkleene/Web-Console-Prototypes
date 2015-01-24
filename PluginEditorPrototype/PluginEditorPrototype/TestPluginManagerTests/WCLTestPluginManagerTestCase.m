//
//  WCLTestPluginManagerTestCase.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLTestPluginManagerTestCase.h"

#import "WCLPluginManager_old.h"
#import "WCLFileExtensionController_old.h"

@implementation WCLTestPluginManagerTestCase

- (void)tearDown
{
    [self deleteAllPlugins];
    
    NSArray *plugins = [[WCLPluginManager_old sharedPluginManager] plugins];
    XCTAssertFalse([plugins count] > 0, @"The WCLPluginManager should not have any WCLPlugins.");
    
    NSArray *extensions = [[WCLFileExtensionController_old sharedFileExtensionController] extensions];
    XCTAssertFalse([extensions count] > 0, @"There should not be any file extensions after deleting all plugins.");

    XCTAssertNil([[WCLPluginManager_old sharedPluginManager] defaultNewPlugin], @"The WCLPluginManager's default new WCLPlugin should be nil.");
    
    [super tearDown];
}

#pragma mark Helpers

- (WCLPlugin_old *)addedPlugin
{
    WCLPlugin_old *plugin = [[WCLPluginManager_old sharedPluginManager] newPlugin];
    
    return plugin;
}

- (void)deletePlugin:(WCLPlugin_old *)plugin
{
    [[WCLPluginManager_old sharedPluginManager] deletePlugin:plugin];
}

- (void)deleteAllPlugins
{
    NSArray *plugins = [[WCLPluginManager_old sharedPluginManager] plugins];
    for (WCLPlugin_old *plugin in plugins) {
        [[WCLPluginManager_old sharedPluginManager] deletePlugin:plugin];
    }
}

@end
