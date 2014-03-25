//
//  WCLSharedPluginManagerController.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/5/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLPlugin;

@interface WCLPluginManagerController : NSObject
+ (instancetype)sharedPluginManagerController;

#pragma mark Required Key-Value Coding To-Many Relationship Compliance
- (NSArray *)plugins;
- (void)insertObject:(WCLPlugin *)plugin inPluginsAtIndex:(NSUInteger)index;
- (void)insertPlugins:(NSArray *)pluginsArray atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectFromPluginsAtIndex:(NSUInteger)index;
- (void)removePluginsAtIndexes:(NSIndexSet *)indexes;
@end
