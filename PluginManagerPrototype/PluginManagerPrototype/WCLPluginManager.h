//
//  WCLNewPluginManager.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLPlugin;

@interface WCLPluginManager : NSObject
+ (instancetype)sharedPluginManager;
- (WCLPlugin *)newPlugin;
- (WCLPlugin *)newPluginFromPlugin:(WCLPlugin *)plugin;
- (void)deletePlugin:(WCLPlugin *)plugin;
- (WCLPlugin *)pluginWithName:(NSString *)name;
- (WCLPlugin *)pluginWithIdentifier:(NSString *)identifier;
- (NSArray *)plugins;
@property (nonatomic, strong) WCLPlugin *defaultNewPlugin;
@end