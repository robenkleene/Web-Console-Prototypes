//
//  WCLNewPluginManager.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginManager_old.h"
#import "WCLPluginDataController.h"
#import "WCLKeyToObjectController.h"
#import "WCLPlugin_old.h"
#import "PluginEditorPrototype-Swift.h"

@interface WCLPluginManager_old ()
@property (nonatomic, strong, readonly) WCLPluginDataController *pluginDataController;
@property (nonatomic, strong, readonly) MultiCollectionController *pluginsController;
@end

@implementation WCLPluginManager_old

@synthesize pluginDataController = _pluginDataController;
@synthesize pluginsController = _pluginsController;
@synthesize defaultNewPlugin = _defaultNewPlugin;

+ (instancetype)sharedPluginManager
{
    static dispatch_once_t pred;
    static WCLPluginManager_old *pluginManager = nil;
    
    dispatch_once(&pred, ^{
        pluginManager = [[self alloc] init];
    });

    return pluginManager;
}

- (WCLPlugin_old *)newPlugin
{
    WCLPlugin_old *defaultPlugin = [self defaultNewPlugin];

    WCLPlugin_old *newPlugin;
    if (defaultPlugin) {
        newPlugin = [self.pluginDataController newPluginFromPlugin:defaultPlugin];
    }
    
    if (!newPlugin) {
        newPlugin = [self.pluginDataController newPlugin];
    }
    
    [self.pluginsController addObject:newPlugin];
    return newPlugin;
}

- (WCLPlugin_old *)newPluginFromPlugin:(WCLPlugin_old *)plugin
{
    WCLPlugin_old *newPlugin = [self.pluginDataController newPluginFromPlugin:plugin];
    [self.pluginsController addObject:newPlugin];
    return newPlugin;
}

- (void)deletePlugin:(WCLPlugin_old *)plugin
{
    if (self.defaultNewPlugin == plugin) {
        self.defaultNewPlugin = nil;
    }
    
    [self.pluginsController removeObject:plugin];
    [self.pluginDataController deletePlugin:plugin];
}

- (WCLPlugin_old *)pluginWithName:(NSString *)name
{
    return [self.pluginsController objectWithKey:name];
}

- (NSArray *)plugins
{
    return [self.pluginsController objects];
}

#pragma mark Properties

- (WCLPlugin_old *)defaultNewPlugin
{
    if (_defaultNewPlugin) {
        return _defaultNewPlugin;
    }

    NSString *identifier = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultNewPluginIdentifierKey];

    WCLPlugin_old *plugin = [self pluginWithIdentifier:identifier];

    _defaultNewPlugin = plugin;
    
    return _defaultNewPlugin;
}

- (void)setDefaultNewPlugin:(WCLPlugin_old *)defaultNewPlugin
{
    if (self.defaultNewPlugin == defaultNewPlugin) {
        return;
    }
    
    if (!defaultNewPlugin) {
        // Do this early so that the subsequent calls to the getter don't reset the default new plugin
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDefaultNewPluginIdentifierKey];
    }
    
    WCLPlugin_old *oldDefaultNewPlugin = _defaultNewPlugin;
    _defaultNewPlugin = defaultNewPlugin;
    
    oldDefaultNewPlugin.defaultNewPlugin = NO;

    _defaultNewPlugin.defaultNewPlugin = YES;

    if (_defaultNewPlugin) {
        [[NSUserDefaults standardUserDefaults] setObject:_defaultNewPlugin.identifier
                                                  forKey:kDefaultNewPluginIdentifierKey];
    }
}

- (WCLPlugin_old *)pluginWithIdentifier:(NSString *)identifer
{
    NSArray *plugins = [self plugins];
    for (WCLPlugin_old *plugin in plugins) {
        if ([plugin.identifier isEqualToString:identifer]) {
            return plugin;
        }
    }

    return nil;
}

- (MultiCollectionController *)pluginsController
{
    if (_pluginsController) {
        return _pluginsController;
    }
    

    NSArray *plugins = [self.pluginDataController existingPlugins];
    _pluginsController = [[MultiCollectionController alloc] init:plugins key:WCLPluginNameKey];
    
    return _pluginsController;
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