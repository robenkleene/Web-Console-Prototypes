//
//  WCLNewPluginManager.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginManager.h"
#import "WCLPluginDataController.h"
#import "WCLNameToPluginController.h"
#import "WCLPlugin.h"

@interface WCLPluginManager ()
@property (nonatomic, strong, readonly) WCLPluginDataController *pluginDataController;
@property (nonatomic, strong, readonly) WCLNameToPluginController *nameToPluginController;

@end

@implementation WCLPluginManager

@synthesize pluginDataController = _pluginDataController;
@synthesize nameToPluginController = _nameToPluginController;

+ (id)sharedPluginManager
{
    static dispatch_once_t pred;
    static WCLPluginManager *pluginManager = nil;
    
    dispatch_once(&pred, ^{ pluginManager = [[self alloc] init]; });
    return pluginManager;
}

- (WCLPlugin *)newPlugin
{
    WCLPlugin *plugin = [self.pluginDataController newPlugin];
    [self.nameToPluginController addPlugin:plugin];
    return plugin;
}

- (void)deletePlugin:(WCLPlugin *)plugin
{
    [self.nameToPluginController removePlugin:plugin];
    [self.pluginDataController deletePlugin:plugin];
}

- (WCLPlugin *)pluginWithName:(NSString *)name
{
    return [self.nameToPluginController pluginWithName:name];
}

- (NSArray *)plugins
{
    return [self.nameToPluginController allPlugins];
}

#pragma mark Properties

- (WCLNameToPluginController *)nameToPluginController
{
    if (_nameToPluginController) {
        return _nameToPluginController;
    }

    _nameToPluginController = [[WCLNameToPluginController alloc] init];
    [_nameToPluginController addPluginsFromArray:[self.pluginDataController existingPlugins]];

    return _nameToPluginController;
}

- (WCLPluginDataController *)pluginDataController
{
    if (_pluginDataController) {
        return _pluginDataController;
    }

    _pluginDataController = [[WCLPluginDataController alloc] init];

    return _pluginDataController;
}

@end
