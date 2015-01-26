//
//  WCLFileExtension.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/23/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

extern NSString * const WCLFileExtensionPluginsKey;
extern NSString * const WCLFileExtensionSuffixKey;

@class Plugin;

@interface WCLFileExtension : NSObject
- (id)initWithSuffix:(NSString *)extension;
@property (nonatomic, strong, readonly) NSString *suffix;
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;
@property (nonatomic, strong) Plugin *selectedPlugin;
@property (nonatomic, strong) NSArrayController *pluginsArrayController;

#pragma mark Required Key-Value Coding To-Many Relationship Compliance
- (NSArray *)plugins;
- (void)insertObject:(Plugin *)plugin inPluginsAtIndex:(NSUInteger)index;
- (void)insertPlugins:(NSArray *)pluginsArray atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectFromPluginsAtIndex:(NSUInteger)index;
- (void)removePluginsAtIndexes:(NSIndexSet *)indexes;
@end
