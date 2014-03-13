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
@property (nonatomic, strong, readonly) NSMutableArray *plugins;
@end

@implementation WCLPluginManagerController

@synthesize plugins = _plugins;

#pragma mark - Interface Builder Compatible Singleton

+ (id)sharedPluginManagerController
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


#pragma mark - Required Key-Value Coding To-Many Relationship Compliance

- (NSMutableArray *)plugins
{
    if (_plugins) {
        return _plugins;
    }
    
    _plugins = [[[WCLPluginManager sharedPluginManager] plugins] mutableCopy];
    
    return _plugins;
}

- (void)insertObject:(WCLPlugin *)plugin inPluginsAtIndex:(NSUInteger)index
{
    [self.plugins insertObject:plugin atIndex:index];
}

- (void)insertPlugins:(NSArray *)pluginsArray atIndexes:(NSIndexSet *)indexes
{
    [self.plugins insertObjects:pluginsArray atIndexes:indexes];
}

- (void)removeObjectFromPluginsAtIndex:(NSUInteger)index
{
    WCLPlugin *pluginToDelete = [self.plugins objectAtIndex:index];
    
    [self.plugins removeObjectAtIndex:index];

    [[WCLPluginManager sharedPluginManager] deletePlugin:pluginToDelete];
}

- (void)removePluginsAtIndexes:(NSIndexSet *)indexes
{
    NSArray *objectsToDelete = [self.plugins objectsAtIndexes:indexes];
    
    [self.plugins removeObjectsAtIndexes:indexes];

    for (WCLPlugin *aPlugin in objectsToDelete) {
        [[WCLPluginManager sharedPluginManager] deletePlugin:aPlugin];
    }
}


#pragma mark - Optional Key-Value Coding To-Many Relationship Compliance

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