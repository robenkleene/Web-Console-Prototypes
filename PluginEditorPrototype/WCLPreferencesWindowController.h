//
//  WCLPreferencesWindowController.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, WCLPreferencePane) {
    WCLPreferencePaneEnvironment,
    WCLPreferencePanePlugins
};

#define kPreferencesWindowControllerNibName @"WCLPreferencesWindowController"

@interface WCLPreferencesWindowController : NSWindowController

@end
