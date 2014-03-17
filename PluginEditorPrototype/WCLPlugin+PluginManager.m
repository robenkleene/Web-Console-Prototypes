//
//  WCLPlugin+PluginManager.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/16/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPlugin+PluginManager.h"

#import "WCLPluginManager.h"

@implementation WCLPlugin (PluginManager)

- (WCLPluginManager *)pluginManager
{
    return [WCLPluginManager sharedPluginManager];
}

@end
