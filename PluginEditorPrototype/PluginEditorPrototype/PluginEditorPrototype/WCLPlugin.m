//
//  WCLPlugin.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

#import "WCLPlugin.h"

#import "PluginEditorPrototype-Swift.h"

@implementation WCLPlugin

@synthesize defaultNewPlugin = _defaultNewPlugin;

- (void)setDefaultNewPlugin:(BOOL)defaultNewPlugin
{
    if (_defaultNewPlugin != defaultNewPlugin) {
        _defaultNewPlugin = defaultNewPlugin;
    }
}

- (BOOL)isDefaultNewPlugin
{
    BOOL isDefaultNewPlugin = [[PluginManager sharedInstance] defaultNewPlugin] == self;
    
    if (_defaultNewPlugin != isDefaultNewPlugin) {
        _defaultNewPlugin = isDefaultNewPlugin;
    }
    
    return _defaultNewPlugin;
}

@end
