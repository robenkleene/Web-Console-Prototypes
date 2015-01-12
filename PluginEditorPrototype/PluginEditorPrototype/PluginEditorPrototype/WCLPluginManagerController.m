//
//  WCLSharedPluginManagerController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/5/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginManagerController.h"
#import "WCLPlugin_old.h"
#import "WCLPluginManager_old.h"

@interface WCLPluginManagerController ()
@property (nonatomic, strong, readonly) NSMutableArray *mutablePlugins;
@end

@implementation WCLPluginManagerController

@synthesize mutablePlugins = _mutablePlugins;

#pragma mark Interface Builder Compatible Singleton

+ (instancetype)sharedPluginManagerController
{
    static dispatch_once_t pred;
    static WCLPluginManagerController *pluginManagerController = nil;
    
    dispatch_once(&pred, ^{
        pluginManagerController = [[self hiddenAlloc] hiddenInit];
    });
    return pluginManagerController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedPluginManagerController];
}

+ (id)alloc
{
    return [self sharedPluginManagerController];
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

#pragma mark Properties

- (NSMutableArray *)mutablePlugins
{
    if (_mutablePlugins) {
        return _mutablePlugins;
    }
    
    _mutablePlugins = [[[WCLPluginManager_old sharedPluginManager] plugins] mutableCopy];
    
    return _mutablePlugins;
}

#pragma mark Required Key-Value Coding To-Many Relationship Compliance

// All accessors do nothing if _mutablePlugins is nil because we don't care about
// key-value observing until the plugins array is being observed.
// This prevents a plugin from being added twice if the _mutablePlugins is
// instantiated during an accessor. The plugin can be added twice if its
// already been added to the plugin manager, i.e., once from plugin manager's
// plugins in the getter, and once being added by the insert.

- (NSArray *)plugins
{
    return [NSArray arrayWithArray:self.mutablePlugins];
}

- (void)insertObject:(WCLPlugin_old *)plugin inPluginsAtIndex:(NSUInteger)index
{
    if (_mutablePlugins) {
        [self.mutablePlugins insertObject:plugin atIndex:index];
    }
}

- (void)insertPlugins:(NSArray *)pluginsArray atIndexes:(NSIndexSet *)indexes
{
    if (_mutablePlugins) {
        [self.mutablePlugins insertObjects:pluginsArray atIndexes:indexes];
    }
}

- (void)removeObjectFromPluginsAtIndex:(NSUInteger)index
{
    if (_mutablePlugins) {
        [self.mutablePlugins removeObjectAtIndex:index];
    }
}

- (void)removePluginsAtIndexes:(NSIndexSet *)indexes
{
    if (_mutablePlugins) {
        [self.mutablePlugins removeObjectsAtIndexes:indexes];
    }
}


#pragma mark Optional Key-Value Coding To-Many Relationship Compliance

// Don't implement these to avoid implementing delete for them.

//- (void)replaceObjectInPluginsAtIndex:(NSUInteger)index withObject:(id)anObject
//{
//    [self.mutablePlugins replaceObjectAtIndex:index withObject:anObject];
//}
//
//- (void)replacePluginsAtIndexes:(NSIndexSet *)indexes withPlugins:(NSArray *)pluginArray
//{
//    [self.mutablePlugins replaceObjectsAtIndexes:indexes withObjects:pluginArray];
//}

@end