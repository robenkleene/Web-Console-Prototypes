//
//  WCLPlugin+Validation.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPlugin_old.h"

@interface WCLPlugin_old (Validation)
#pragma mark Name
+ (BOOL)nameContainsOnlyValidCharacters:(NSString *)name;
- (BOOL)nameIsValid:(NSString *)name;
- (void)renameWithUniqueName;
- (NSString *)uniquePluginNameFromName:(NSString *)name;
#pragma mark File Extensions
- (BOOL)extensionsAreValid:(NSArray *)extensions;
+ (NSArray *)validExtensionsFromExtensions:(NSArray *)extensions;
@end
