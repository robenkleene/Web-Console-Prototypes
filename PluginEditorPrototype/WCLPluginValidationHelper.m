//
//  WCLPluginValidationHelper.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/11/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginValidationHelper.h"
#import "WCLPluginManager.h"

@interface WCLPluginValidationHelper ()
+ (NSString *)generateUniquePluginNameFromName:(NSString *)name index:(NSUInteger)index;
@end

@implementation WCLPluginValidationHelper

+ (BOOL)isValidName:(NSString *)name
{
    if (!name) {
        return NO;
    }

    if (![WCLPluginValidationHelper nameContainsOnlyValidCharacters:name]) {
        return NO;
    }

    if (![WCLPluginValidationHelper nameIsUnique:name]) {
        return NO;
    }
#warning Need to check that a name can be written to disk here too to make sure it is valid.
    
    return YES;
}

+ (BOOL)nameContainsOnlyValidCharacters:(NSString *)name
{
    NSMutableCharacterSet *allowedCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"_- "];
    [allowedCharacterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
    
    NSCharacterSet *disallowedCharacterSet = [allowedCharacterSet invertedSet];
    
    NSRange disallowedRange = [name rangeOfCharacterFromSet:disallowedCharacterSet];
    BOOL foundDisallowedCharacter = !(NSNotFound == disallowedRange.location);
    
    return !foundDisallowedCharacter;
}

+ (BOOL)nameIsUnique:(NSString *)name
{
    WCLPlugin *plugin = [[WCLPluginManager sharedPluginManager] pluginWithName:name];

    return plugin ? NO : YES;
}

+ (NSString *)uniquePluginNameFromName:(NSString *)name
{
    if ([WCLPluginValidationHelper nameIsUnique:name]) {
        return name;
    }
    
    NSString *newName = [WCLPluginValidationHelper generateUniquePluginNameFromName:name index:0];

    if (!newName) {
#warning Return guid here
        NSAssert(NO, @"Implement");
    }
    
    return newName;
}

+ (NSString *)generateUniquePluginNameFromName:(NSString *)name index:(NSUInteger)index
{
    if (index > 99) {
        return nil;
    }
    
    if ([WCLPluginValidationHelper nameIsUnique:name]) {
        return name;
    }

    index++;
    return [WCLPluginValidationHelper generateUniquePluginNameFromName:[NSString stringWithFormat:@"%@ %lu", name, (unsigned long)index]
                                                                 index:index];
}

@end