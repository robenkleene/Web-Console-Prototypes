//
//  WCLNameToPluginController.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLPlugin;

@interface WCLKeyToObjectController : NSObject
- (instancetype)initWithObjects:(NSArray *)plugins;
- (void)addObjectsFromArray:(NSArray *)plugins;
- (void)addObject:(WCLPlugin *)plugin;
- (void)removeObject:(WCLPlugin *)plugin;
- (void)removeObjectsFromArray:(NSArray *)plugins;
- (WCLPlugin *)objectWithName:(NSString *)name;
- (NSArray *)allObjects;
@end
