//
//  WCLNameToPluginController.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLPlugin;

@interface WCLNameToPluginController : NSObject
- (void)addPluginsFromArray:(NSArray *)plugins;
- (void)addPlugin:(WCLPlugin *)plugin;
- (void)removePlugin:(WCLPlugin *)plugin;
- (void)removePluginsFromArray:(NSArray *)plugins;
- (WCLPlugin *)pluginWithName:(NSString *)name;
- (NSArray *)allPlugins;
@end
