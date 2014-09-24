//
//  WCLNameToPluginController.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCLKeyToObjectController : NSObject
- (instancetype)initWithKey:(NSString *)key;
- (instancetype)initWithKey:(NSString *)key objects:(NSArray *)objects;
- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (void)addObjectsFromArray:(NSArray *)plugins;
- (void)removeObjectsFromArray:(NSArray *)plugins;
- (id)objectWithName:(NSString *)name;
- (NSArray *)allObjects;
@end