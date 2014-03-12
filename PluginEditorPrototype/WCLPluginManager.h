//
//  WCLPluginManager.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/4/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLPlugin;

@interface WCLPluginManager : NSObject
+ (id)sharedPluginManager;
- (WCLPlugin *)newPlugin;
- (void)deletePlugin:(WCLPlugin *)plugin;
- (NSArray *)plugins;
- (WCLPlugin *)pluginWithName:(NSString *)name;
@end
