//
//  WCLPluginManager.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/4/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLPlugin;

@interface WCLPluginManager : NSObject
+ (id)sharedPluginManager;
#warning Should be able to make the managedObjectContext private
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
- (WCLPlugin *)newPlugin;
@property (readonly, strong, nonatomic) NSMutableArray *plugins;
@end
