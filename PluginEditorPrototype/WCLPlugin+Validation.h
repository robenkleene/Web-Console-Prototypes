//
//  WCLPlugin+Validation.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPlugin.h"

@interface WCLPlugin (Validation)
#pragma mark - File Extensions
+ (BOOL)nameContainsOnlyValidCharacters:(NSString *)name;
- (BOOL)nameIsValid:(NSString *)name;
- (void)renameWithUniqueName;
#pragma mark - File Extensions
- (BOOL)fileExtensionsAreValid:(NSArray *)fileExtensions;
+ (NSArray *)validFileExtensionsFromFileExtensions:(NSArray *)fileExtensions;
@end