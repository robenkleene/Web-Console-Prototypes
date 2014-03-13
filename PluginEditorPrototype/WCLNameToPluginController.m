//
//  WCLNameToPluginController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLNameToPluginController.h"
#import "WCLPlugin.h"
#import "WCLPluginValidationHelper.h"

@interface WCLNameToPluginController ()
@property (nonatomic, strong, readonly) NSMutableDictionary *nameToPluginDictionary;
@end

@implementation WCLNameToPluginController

@synthesize nameToPluginDictionary = _nameToPluginDictionary;

- (void)addPlugin:(WCLPlugin *)plugin
{
    if (self.nameToPluginDictionary[plugin.name]) {
        plugin.name = [WCLPluginValidationHelper uniquePluginNameFromName:plugin.name];
    }
    
    self.nameToPluginDictionary[plugin.name] = plugin;
}

- (void)removePlugin:(WCLPlugin *)plugin
{
    [self.nameToPluginDictionary removeObjectForKey:plugin.name];
}

- (void)addPluginsFromArray:(NSArray *)plugins
{
    for (WCLPlugin *plugin in plugins) {
        [self addPlugin:plugin];
    }
}

- (void)removePluginsFromArray:(NSArray *)plugins
{
    for (WCLPlugin *plugin in plugins) {
        [self removePlugin:plugin];
    }
}

- (WCLPlugin *)pluginWithName:(NSString *)name
{
    return self.nameToPluginDictionary[name];
}

- (NSArray *)allPlugins
{
    return [self.nameToPluginDictionary allValues];
}

#pragma mark Properties

- (NSMutableDictionary *)nameToPluginDictionary
{
    if (_nameToPluginDictionary) {
        return _nameToPluginDictionary;
    }

    _nameToPluginDictionary = [NSMutableDictionary dictionary];
    
    return _nameToPluginDictionary;
}

@end
