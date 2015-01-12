//
//  WCLPluginManager.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

#import "WCLPluginManager.h"
#import "PluginEditorPrototype-Swift.h"

@implementation WCLPluginManager

@synthesize defaultNewPlugin = _defaultNewPlugin;

- (Plugin *)defaultNewPlugin
{
    if (_defaultNewPlugin) {
        return _defaultNewPlugin;
    }
    
    NSString *identifier = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultNewPluginIdentifierKey];
    
    Plugin *plugin = [[PluginManager sharedInstance] pluginWithIdentifier:identifier];
    
    _defaultNewPlugin = plugin;
    
    return _defaultNewPlugin;
}

- (void)setDefaultNewPlugin:(Plugin *)defaultNewPlugin
{
    if (self.defaultNewPlugin == defaultNewPlugin) {
        return;
    }
    
    if (!defaultNewPlugin) {
        // Do this early so that the subsequent calls to the getter don't reset the default new plugin
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDefaultNewPluginIdentifierKey];
    }
    
    Plugin *oldDefaultNewPlugin = _defaultNewPlugin;
    _defaultNewPlugin = defaultNewPlugin;
    
    oldDefaultNewPlugin.defaultNewPlugin = NO;
    
    _defaultNewPlugin.defaultNewPlugin = YES;
    
    if (_defaultNewPlugin) {
        [[NSUserDefaults standardUserDefaults] setObject:_defaultNewPlugin.identifier
                                                  forKey:kDefaultNewPluginIdentifierKey];
    }
}

@end
