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

#pragma mark Interface Builder Compatible Singleton

+ (instancetype)sharedPluginManager
{
    static dispatch_once_t pred;
    static WCLPluginManager_old *pluginManager = nil;
    
    dispatch_once(&pred, ^{
        pluginManager = [[self hiddenAlloc] hiddenInit];
    });
    
    return pluginManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedPluginManager];
}

+ (id)alloc
{
    return [self sharedPluginManager];
}

- (id)init
{
    return self;
}

+ (id)hiddenAlloc
{
    return [super allocWithZone:NULL];
}

- (id)hiddenInit
{
    return [super init];
}

#pragma mark Plugins

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
    
    [self addPlugin:newPlugin];

    return newPlugin;
}

- (WCLPlugin_old *)newPluginFromPlugin:(WCLPlugin_old *)plugin
{
    WCLPlugin_old *newPlugin = [self.pluginDataController newPluginFromPlugin:plugin];
    [self addPlugin:newPlugin];
    return newPlugin;
}

- (void)deletePlugin:(WCLPlugin_old *)plugin
{
    if (self.defaultNewPlugin == plugin) {
        self.defaultNewPlugin = nil;
    }

    [self removePlugin:plugin];
    [self.pluginDataController deletePlugin:plugin];
}

- (WCLPlugin_old *)pluginWithName:(NSString *)name
{
    return [self.pluginsController objectWithKey:name];
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

#pragma mark Convenience

- (void)addPlugin:(WCLPlugin_old *)plugin
{
    [self insertObject:plugin inPluginsAtIndex:0];
}

- (void)removePlugin:(WCLPlugin_old *)plugin
{
    NSUInteger index = [self.pluginsController indexOfObject:plugin];
    if (index != NSNotFound) {
        [self removeObjectFromPluginsAtIndex:index];
    }
}

#pragma mark Required Key-Value Coding To-Many Relationship Compliance

- (NSArray *)plugins
{
    return [self.pluginsController objects];
}

- (void)insertObject:(WCLPlugin_old *)plugin inPluginsAtIndex:(NSUInteger)index
{
    if (_pluginsController) {
        [self.pluginsController insertObject:plugin inObjectsAtIndex:index];
    }
}

- (void)insertPlugins:(NSArray *)pluginsArray atIndexes:(NSIndexSet *)indexes
{
    [self.pluginsController insertObjects:pluginsArray atIndexes:indexes];
}

- (void)removeObjectFromPluginsAtIndex:(NSUInteger)index
{
    [self.pluginsController removeObjectFromObjectsAtIndex:index];
}

- (void)removePluginsAtIndexes:(NSIndexSet *)indexes
{
    [self.pluginsController removeObjectsAtIndexes:indexes];
}

@end
