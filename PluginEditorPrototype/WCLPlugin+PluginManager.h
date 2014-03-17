//
//  WCLPlugin+PluginManager.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/16/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPlugin.h"

@class WCLPluginManager;

@interface WCLPlugin (PluginManager)
- (WCLPluginManager *)pluginManager;
@end
