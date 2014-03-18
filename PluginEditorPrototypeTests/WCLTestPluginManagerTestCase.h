//
//  WCLTestPluginManagerTestCase.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

@class WCLTestFileExtensionController;
@class WCLTestPluginManager;
@class WCLTestPluginManagerController;

@interface WCLTestPluginManagerTestCase : XCTestCase
- (void)deleteAllPlugins;
- (WCLTestFileExtensionController *)fileExtensionsController;
- (WCLTestPluginManager *)pluginManager;
- (WCLTestPluginManagerController *)pluginManagerController;
@end
