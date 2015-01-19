//
//  WCLPluginManager.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Plugin;

@interface WCLPluginsManager : NSObject
@property (nonatomic, strong) Plugin *defaultNewPlugin;
@end
