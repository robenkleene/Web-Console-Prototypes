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
    
    NSArray *fileExtensions = [[self fileExtensionsController] fileExtensions];
    XCTAssertFalse([fileExtensions count] > 0, @"There should not be any file extensions after deleting all plugins.");

    
    [super tearDown];
}

#pragma mark Helpers

- (void)deleteAllPlugins
{
    NSArray *plugins = [[self pluginManagerController] plugins];
    
    NSRange range = NSMakeRange(0, [plugins count]);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [[self pluginManagerController] removePluginsAtIndexes:indexSet];
    
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
