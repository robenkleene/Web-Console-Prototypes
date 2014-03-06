//
//  WCLSharedPluginManagerController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/5/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLSharedPluginManagerController.h"
#import "WCLPlugin.h"
#import "WCLPluginManager.h"

@interface WCLSharedPluginManagerController ()
@property (nonatomic, strong, readonly) NSMutableArray *mutablePlugins;
@end

@implementation WCLSharedPluginManagerController


#pragma mark - Interface Builder Compatible Singleton

+ (id)sharedUserDefaultsController
{
    static dispatch_once_t pred;
    static WCLSharedPluginManagerController *pluginManagerController = nil;
    
    dispatch_once(&pred, ^{
        pluginManagerController = [[self hiddenAlloc] hiddenInit];
    });
    return pluginManagerController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedUserDefaultsController];
}

+ (id)alloc
{
    return [self sharedUserDefaultsController];
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


#pragma mark - Properties

- (NSMutableArray *)mutablePlugins
{
    return [[WCLPluginManager sharedPluginManager] plugins];
}

#pragma mark - Required Key-Value Coding To-Many Relationship Compliance

- (NSArray *)plugins
{
#warning I think what I really want to do is call will change object for key on this property, but for now, just pass the mutable version so it's observable.
//    return [NSArray arrayWithArray:self.mutablePlugins];
    return self.mutablePlugins;
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
    WCLPlugin *pluginToDelete = [self.mutablePlugins objectAtIndex:index];
    
    [self.mutablePlugins removeObjectAtIndex:index];

    [[WCLPluginManager sharedPluginManager] deletePlugin:pluginToDelete];
}

- (void)removePluginsAtIndexes:(NSIndexSet *)indexes
{
    NSArray *objectsToDelete = [self.mutablePlugins objectsAtIndexes:indexes];
    
    [self.mutablePlugins removeObjectsAtIndexes:indexes];

    for (WCLPlugin *aPlugin in objectsToDelete) {
        [[WCLPluginManager sharedPluginManager] deletePlugin:aPlugin];
    }
}


#pragma mark - Optional Key-Value Coding To-Many Relationship Compliance

- (void)replaceObjectInPluginsAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [self.mutablePlugins replaceObjectAtIndex:index withObject:anObject];
}

- (void)replacePluginsAtIndexes:(NSIndexSet *)indexes withPlugins:(NSArray *)pluginArray
{
    [self.mutablePlugins replaceObjectsAtIndexes:indexes withObjects:pluginArray];
}

@end