//
//  WCLTestPluginManagerTestCase.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLTestPluginManagerTestCase.h"

#import "WCLPluginManager.h"
#import "WCLFileExtensionController.h"
#import "WCLPluginManagerController.h"

@implementation WCLTestPluginManagerTestCase

- (void)tearDown
{
    [self deleteAllPlugins];
    
    NSArray *plugins = [[WCLPluginManager sharedPluginManager] plugins];
    XCTAssertFalse([plugins count] > 0, @"The WCLPluginManager should not have any WCLPlugins.");
    
    NSArray *extensions = [[WCLFileExtensionController sharedFileExtensionController] extensions];
    XCTAssertFalse([extensions count] > 0, @"There should not be any file extensions after deleting all plugins.");

    XCTAssertNil([[WCLPluginManager sharedPluginManager] defaultNewPlugin], @"The WCLPluginManager's default new WCLPlugin should be nil.");
    
    [super tearDown];
}

#pragma mark Helpers

- (WCLPlugin *)addedPlugin
{
    WCLPlugin *plugin = [[WCLPluginManager sharedPluginManager] newPlugin];
    
    // You have to insert the plugin into the plugin manager controller because
    // the pluginManagerController implements the key-value coding to-many
    // relationship accessors
    [[WCLPluginManagerController sharedPluginManagerController] insertObject:plugin inPluginsAtIndex:0];

    return plugin;
}

- (void)deletePlugin:(WCLPlugin *)plugin
{
    NSUInteger index = [[[WCLPluginManagerController sharedPluginManagerController] plugins] indexOfObject:plugin];
    NSAssert(index != NSNotFound, @"Attempted to remove a plugin from pluginManagerController's plugins that was not found.");
    [[WCLPluginManagerController sharedPluginManagerController] removeObjectFromPluginsAtIndex:index];
    
    [[WCLPluginManager sharedPluginManager] deletePlugin:plugin];
}

- (void)deleteAllPlugins
{
    NSArray *plugins = [[WCLPluginManagerController sharedPluginManagerController] plugins];
    
    NSRange range = NSMakeRange(0, [plugins count]);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [[WCLPluginManagerController sharedPluginManagerController] removePluginsAtIndexes:indexSet];
    
    for (WCLPlugin *plugin in plugins) {
        [[WCLPluginManager sharedPluginManager] deletePlugin:plugin];
    }

    plugins = [[WCLPluginManager sharedPluginManager] plugins];
    for (WCLPlugin *plugin in plugins) {
        [[WCLPluginManager sharedPluginManager] deletePlugin:plugin];
    }
}

@end
