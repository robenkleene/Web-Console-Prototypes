//
//  WCLTestPluginManagerTestCase.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLTestPluginManagerTestCase.h"

#import "WCLTestPluginManager.h"

@implementation WCLTestPluginManagerTestCase

- (void)tearDown
{
    [self deleteAllPlugins];
    
    NSArray *plugins = [[self pluginManager] plugins];
    XCTAssertFalse([plugins count] > 0, @"The WCLPluginManager should not have any WCLPlugins.");
    
    NSArray *extensions = [[self fileExtensionsController] extensions];
    XCTAssertFalse([extensions count] > 0, @"There should not be any file extensions after deleting all plugins.");

    XCTAssertNil([[self pluginManager] defaultNewPlugin], @"The WCLPluginManager's default new WCLPlugin should be nil.");
    
    [super tearDown];
}

#pragma mark Helpers

- (WCLPlugin *)addedPlugin
{
    WCLPlugin *plugin = [[self pluginManager] newPlugin];
    
    // You have to insert the plugin into the plugin manager controller because
    // the pluginManagerController implements the key-value coding to-many
    // relationship accessors
    [[self pluginManagerController] insertObject:plugin inPluginsAtIndex:0];

    return plugin;
}

- (void)deletePlugin:(WCLPlugin *)plugin
{
    NSUInteger index = [[[self pluginManagerController] plugins] indexOfObject:plugin];
    NSAssert(index != NSNotFound, @"Attempted to remove a plugin from pluginManagerController's plugins that was not found.");
    [[self pluginManagerController] removeObjectFromPluginsAtIndex:index];
    
    [[self pluginManager] deletePlugin:plugin];
}

- (void)deleteAllPlugins
{
    NSArray *plugins = [[self pluginManagerController] plugins];
    
    NSRange range = NSMakeRange(0, [plugins count]);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [[self pluginManagerController] removePluginsAtIndexes:indexSet];
    
    for (WCLPlugin *plugin in plugins) {
        [[self pluginManager] deletePlugin:plugin];
    }

    plugins = [[self pluginManager] plugins];
    for (WCLPlugin *plugin in plugins) {
        [[self pluginManager] deletePlugin:plugin];
    }
}

#pragma mark Test Singletons

- (WCLTestFileExtensionController *)fileExtensionsController
{
    return [WCLTestFileExtensionController sharedFileExtensionController];
}

- (WCLTestPluginManager *)pluginManager
{
    return [WCLTestPluginManager sharedPluginManager];
}

- (WCLTestPluginManagerController *)pluginManagerController
{
    return [WCLTestPluginManagerController sharedPluginManagerController];
}

@end
