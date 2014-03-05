//
//  WCLPluginManager.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/4/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCLPluginManager : NSObject
+ (id)sharedPluginManager;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
