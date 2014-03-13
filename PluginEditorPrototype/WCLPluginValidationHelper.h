//
//  WCLPluginValidationHelper.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/11/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLPlugin;

@interface WCLPluginValidationHelper : NSObject
+ (BOOL)nameContainsOnlyValidCharacters:(NSString *)name;
+ (BOOL)nameIsUnique:(NSString *)name;
+ (NSString *)uniquePluginNameFromName:(NSString *)name;
@end
