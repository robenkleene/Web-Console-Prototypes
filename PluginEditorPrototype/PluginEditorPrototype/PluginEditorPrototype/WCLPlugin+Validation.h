//
//  WCLPlugin+Validation.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPlugin.h"

@interface WCLPlugin (Validation)
#pragma mark Name
+ (BOOL)nameContainsOnlyValidCharacters:(NSString *)name;
- (BOOL)nameIsValid:(NSString *)name;
+ (NSString *)uniquePluginNameFromName:(NSString *)name;
+ (NSString *)uniquePluginNameFromName:(NSString *)name forPlugin:(WCLPlugin *)plugin;
#pragma mark File Extensions
- (BOOL)extensionsAreValid:(NSArray *)extensions;
+ (NSArray *)validExtensionsFromExtensions:(NSArray *)extensions;
@end
