//
//  WCLNameToPluginController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLKeyToObjectController.h"
#import "WCLPlugin.h"
#import "WCLPlugin+Validation.h"

@interface WCLKeyToObjectController ()
@property (nonatomic, strong, readonly) NSMutableDictionary *nameToPluginDictionary;
@end

@implementation WCLKeyToObjectController

static void *WCLNameToPluginControllerContext;

@synthesize nameToPluginDictionary = _nameToPluginDictionary;

- (instancetype)initWithObjects:(NSArray *)plugins
{
    self = [super init];
    if (self) {
        [self addObjectsFromArray:plugins];
    }
    return self;
}

- (void)addObject:(WCLPlugin *)plugin
{
    NSAssert(self.nameToPluginDictionary[plugin.name] == nil, @"Attemped to add a plugin with an existing name.");

    self.nameToPluginDictionary[plugin.name] = plugin;
    [plugin addObserver:self
             forKeyPath:WCLPluginNameKey
                options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                context:&WCLNameToPluginControllerContext];
}

- (void)removeObject:(WCLPlugin *)plugin
{
    [self.nameToPluginDictionary removeObjectForKey:plugin.name];
	[plugin removeObserver:self
                forKeyPath:WCLPluginNameKey
                   context:&WCLNameToPluginControllerContext];
}

- (void)dealloc
{
    NSArray *plugins = [self allObjects];
    for (WCLPlugin *plugin in plugins) {
        [self removeObject:plugin];
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

- (void)addObjectsFromArray:(NSArray *)plugins
{
    for (WCLPlugin *plugin in plugins) {
        [self addObject:plugin];
    }
}

- (void)removeObjectsFromArray:(NSArray *)plugins
{
    for (WCLPlugin *plugin in plugins) {
        [self removeObject:plugin];
    }
}


#pragma mark Accessing Plugins

- (WCLPlugin *)objectWithName:(NSString *)name
{
    return self.nameToPluginDictionary[name];
}

- (NSArray *)allObjects
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
