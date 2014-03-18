//
//  WCLSharedPluginManagerController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/5/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginManagerController.h"
#import "WCLPlugin.h"
#import "WCLPluginManager.h"

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

- (WCLPluginManager *)pluginManager
{
    return [WCLPluginManager sharedPluginManager];
}

#pragma mark Required Key-Value Coding To-Many Relationship Compliance

- (NSArray *)plugins
{
    return [NSArray arrayWithArray:self.mutablePlugins];
}

- (NSMutableArray *)mutablePlugins
{
    if (_mutablePlugins) {
        return _mutablePlugins;
    }
    
    _mutablePlugins = [[[self pluginManager] plugins] mutableCopy];
    
    return _mutablePlugins;
}

- (void)insertObject:(WCLPlugin *)plugin inPluginsAtIndex:(NSUInteger)index
{    
    [self.mutablePlugins insertObject:plugin atIndex:index];
}

- (void)insertPlugins:(NSArray *)pluginsArray atIndexes:(NSIndexSet *)indexes
{
    [self.mutablePlugins insertObjects:pluginsArray atIndexes:indexes];
}

- (void)removeObjectFromPluginsAtIndex:(NSUInteger)index
{
    [self.mutablePlugins removeObjectAtIndex:index];
}

- (void)removePluginsAtIndexes:(NSIndexSet *)indexes
{
    [self.mutablePlugins removeObjectsAtIndexes:indexes];
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