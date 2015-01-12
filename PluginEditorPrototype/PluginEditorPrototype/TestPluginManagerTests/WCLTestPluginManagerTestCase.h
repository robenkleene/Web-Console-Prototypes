//
//  WCLTestPluginManagerTestCase.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

@class WCLPlugin_old;

@interface WCLTestPluginManagerTestCase : XCTestCase
- (WCLPlugin_old *)addedPlugin;
- (void)deletePlugin:(WCLPlugin_old *)plugin;
- (void)deleteAllPlugins;
@end
