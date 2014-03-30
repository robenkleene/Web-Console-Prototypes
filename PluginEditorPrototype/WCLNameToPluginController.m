//
//  WCLNameToPluginController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLNameToPluginController.h"
#import "WCLPlugin.h"
#import "WCLPlugin+Validation.h"

@interface WCLNameToPluginController ()
@property (nonatomic, strong, readonly) NSMutableDictionary *nameToPluginDictionary;
@end

@implementation WCLNameToPluginController

static void *WCLNameToPluginControllerContext;

@synthesize nameToPluginDictionary = _nameToPluginDictionary;

- (void)addPlugin:(WCLPlugin *)plugin
{
    NSAssert(self.nameToPluginDictionary[plugin.name] == nil, @"Attemped to add a plugin with an existing name.");

    self.nameToPluginDictionary[plugin.name] = plugin;
    [plugin addObserver:self
             forKeyPath:WCLPluginNameKey
                options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                context:&WCLNameToPluginControllerContext];
}

- (void)removePlugin:(WCLPlugin *)plugin
{
    [self.nameToPluginDictionary removeObjectForKey:plugin.name];
	[plugin removeObserver:self
                forKeyPath:WCLPluginNameKey
                   context:&WCLNameToPluginControllerContext];
}

- (void)dealloc
{
    NSArray *plugins = [self allPlugins];
    for (WCLPlugin *plugin in plugins) {
        [self removePlugin:plugin];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context != &WCLNameToPluginControllerContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    NSKeyValueChange keyValueChange = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if (keyValueChange != NSKeyValueChangeSetting) {
        return;
    }
    
    if (![keyPath isEqualToString:WCLPluginNameKey]) {
        return;
    }

    NSString *oldName = change[NSKeyValueChangeOldKey];
    NSString *newName = change[NSKeyValueChangeNewKey];

    if (![object isKindOfClass:[WCLPlugin class]]) {
        return;
    }
    
    WCLPlugin *plugin = (WCLPlugin *)object;
    [self.nameToPluginDictionary removeObjectForKey:oldName];
    self.nameToPluginDictionary[newName] = plugin;
}



#pragma mark Convienence Methods

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


#pragma mark Accessing Plugins

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
