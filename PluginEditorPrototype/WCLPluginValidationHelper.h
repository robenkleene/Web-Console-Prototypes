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
+ (BOOL)isValidName:(NSString *)name forPlugin:(WCLPlugin *)plugin;
+ (BOOL)nameContainsOnlyValidCharacters:(NSString *)name;
+ (NSString *)uniquePluginNameFromName:(NSString *)name;
@end
