//
//  Web_ConsoleTestsConstants.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#pragma mark Test Plugin

#define kTestPluginName @"Test Plugin"
#define kTestPluginCommand @"wcprint.rb"
#define kTestPluginDefaultNewPluginKeyPath @"defaultNewPlugin"

#pragma mark Extensions

#define kTestExtensions @[@"html", @"md", @"js"]
#define kTestExtension @"html"
#define kTestExtensionsOne @[kTestExtension]
#define kTestExtensionsEmpty @[]

#pragma mark File Extensions

#define kTestFileExtensionEnabledKeyPath @"enabled"
#define kTestFileExtensionSelectedPluginKeyPath @"selectedPlugin"


#warning Cut & Paste job from Web Console
#pragma mark - Window Sizes

#define kTestWindowFrame NSMakeRect(158, 97, 425, 450)
#define kTestWindowFrameTwo NSMakeRect(200, 200, 333, 388)