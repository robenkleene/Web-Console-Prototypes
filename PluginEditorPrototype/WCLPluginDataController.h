//
//  WCLPluginDataController.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLPlugin;

@interface WCLPluginDataController : NSObject
- (WCLPlugin *)newPlugin;
- (void)deletePlugin:(WCLPlugin *)plugin;
- (NSArray *)existingPlugins;
@end
