//
//  WCLNewPluginManager.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLPlugin_old;

@interface WCLPluginManager_old : NSObject
+ (instancetype)sharedPluginManager;
- (WCLPlugin_old *)newPlugin;
- (WCLPlugin_old *)newPluginFromPlugin:(WCLPlugin_old *)plugin;
- (void)deletePlugin:(WCLPlugin_old *)plugin;
- (WCLPlugin_old *)pluginWithName:(NSString *)name;
- (WCLPlugin_old *)pluginWithIdentifier:(NSString *)identifier;
- (NSArray *)plugins;
@property (nonatomic, strong) WCLPlugin_old *defaultNewPlugin;
@end