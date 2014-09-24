//
//  WCLNewPluginManager.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginManager.h"
#import "WCLPluginDataController.h"
#import "WCLKeyToObjectController.h"
#import "WCLPlugin.h"

@interface WCLPluginManager ()
@property (nonatomic, strong, readonly) WCLPluginDataController *pluginDataController;
@property (nonatomic, strong, readonly) WCLKeyToObjectController *nameToPluginController;
@end

@implementation WCLPluginManager

@synthesize pluginDataController = _pluginDataController;
@synthesize nameToPluginController = _nameToPluginController;
@synthesize defaultNewPlugin = _defaultNewPlugin;

+ (instancetype)sharedPluginManager
{
    static dispatch_once_t pred;
    static WCLPluginManager *pluginManager = nil;
    
    dispatch_once(&pred, ^{
        pluginManager = [[self alloc] init];
    });

    return pluginManager;
}

- (WCLPlugin *)newPlugin
{
    WCLPlugin *defaultPlugin = [self defaultNewPlugin];

    WCLPlugin *newPlugin;
    if (defaultPlugin) {
        newPlugin = [self.pluginDataController newPluginFromPlugin:defaultPlugin];
    }
    
    if (!newPlugin) {
        newPlugin = [self.pluginDataController newPlugin];
    }
    
    [self.nameToPluginController addObject:newPlugin];
    return newPlugin;
}

- (WCLPlugin *)newPluginFromPlugin:(WCLPlugin *)plugin
{
    WCLPlugin *newPlugin = [self.pluginDataController newPluginFromPlugin:plugin];
    [self.nameToPluginController addObject:newPlugin];
    return newPlugin;
}

- (void)deletePlugin:(WCLPlugin *)plugin
{
    if (self.defaultNewPlugin == plugin) {
        self.defaultNewPlugin = nil;
    }
    
    [self.nameToPluginController removeObject:plugin];
    [self.pluginDataController deletePlugin:plugin];
}

- (WCLPlugin *)pluginWithName:(NSString *)name
{
    return [self.nameToPluginController objectWithName:name];
}

- (NSArray *)plugins
{
    return [self.nameToPluginController allObjects];
}

#pragma mark Properties

- (WCLPlugin *)defaultNewPlugin
{
    if (_defaultNewPlugin) {
        return _defaultNewPlugin;
    }

    NSString *identifier = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultNewPluginIdentifierKey];

    WCLPlugin *plugin = [self pluginWithIdentifier:identifier];

    _defaultNewPlugin = plugin;
    
    return _defaultNewPlugin;
}

- (void)setDefaultNewPlugin:(WCLPlugin *)defaultNewPlugin
{
    if (self.defaultNewPlugin == defaultNewPlugin) {
        return;
    }
    
    if (!defaultNewPlugin) {
        // Do this early so that the subsequent calls to the getter don't reset the default new plugin
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDefaultNewPluginIdentifierKey];
    }
    
    WCLPlugin *oldDefaultNewPlugin = _defaultNewPlugin;
    _defaultNewPlugin = defaultNewPlugin;
    
    oldDefaultNewPlugin.defaultNewPlugin = NO;

    _defaultNewPlugin.defaultNewPlugin = YES;

    if (_defaultNewPlugin) {
        [[NSUserDefaults standardUserDefaults] setObject:_defaultNewPlugin.identifier
                                                  forKey:kDefaultNewPluginIdentifierKey];
    }
}

- (WCLPlugin *)pluginWithIdentifier:(NSString *)identifer
{
    NSArray *plugins = [self plugins];
    for (WCLPlugin *plugin in plugins) {
        if ([plugin.identifier isEqualToString:identifer]) {
            return plugin;
        }
    }

    return nil;
}

- (WCLKeyToObjectController *)nameToPluginController
{
    if (_nameToPluginController) {
        return _nameToPluginController;
    }

    _nameToPluginController = [[WCLKeyToObjectController alloc] init];
    [_nameToPluginController addObjectsFromArray:[self.pluginDataController existingPlugins]];

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
