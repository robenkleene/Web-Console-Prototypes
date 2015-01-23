//
//  WCLPlugin.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

#import "WCLPlugin.h"

@implementation WCLPlugin

@synthesize defaultNewPlugin = _defaultNewPlugin;

- (void)setDefaultNewPlugin:(BOOL)defaultNewPlugin
{
#warning It's problematic that using this setter without going through the plugin manager, will set the flag to true without it actually being the default new plugin
    
    if (_defaultNewPlugin != defaultNewPlugin) {
        _defaultNewPlugin = defaultNewPlugin;
    }
}

- (BOOL)isDefaultNewPlugin
{
    BOOL isDefaultNewPlugin = [self isPluginManagerDefaultNewPlugin];

    if (_defaultNewPlugin != isDefaultNewPlugin) {
        _defaultNewPlugin = isDefaultNewPlugin;
    }
    
    return _defaultNewPlugin;
}

- (BOOL)isPluginManagerDefaultNewPlugin
{
    NSAssert(NO, @"Subclass must implement");
    return NO;
}

@end
