//
//  WCLTestPluginManagerTestCase.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

@class WCLPlugin;

@interface WCLTestPluginManagerTestCase : XCTestCase
- (WCLPlugin *)addedPlugin;
- (void)deletePlugin:(WCLPlugin *)plugin;
- (void)deleteAllPlugins;
@end