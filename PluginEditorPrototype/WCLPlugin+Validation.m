//
//  WCLPlugin+Validation.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPlugin+Validation.h"

#import "WCLPluginManager.h"

@implementation WCLPlugin (Validation)

+ (BOOL)nameContainsOnlyValidCharacters:(NSString *)name
{
    NSMutableCharacterSet *allowedCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"_- "];
    [allowedCharacterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
    
    NSCharacterSet *disallowedCharacterSet = [allowedCharacterSet invertedSet];
    
    NSRange disallowedRange = [name rangeOfCharacterFromSet:disallowedCharacterSet];
    BOOL foundDisallowedCharacter = !(NSNotFound == disallowedRange.location);
    
    return !foundDisallowedCharacter;
}

- (BOOL)nameIsValid:(NSString *)name
{
    if (!name) {
        return NO;
    }
    
    if (![WCLPlugin nameContainsOnlyValidCharacters:name]) {
        return NO;
    }
    
    if (![self isUniqueName:name]) {
        return NO;
    }

#warning Need to check that a name can be written to disk here too to make sure it is valid.
    
    return YES;
}

- (void)renameWithUniqueName
{
    if ([self isUniqueName:self.name]) {
        return;
    }
    
    NSString *newName = [self uniquePluginNameFromName:self.name index:2];
    
    if (!newName) {
#warning Return GUID here
        NSAssert(NO, @"Implement");
    }
    
    self.name = newName;
}

#pragma mark Private

- (WCLPluginManager *)pluginManager
{
    return [WCLPluginManager sharedPluginManager];
}

- (BOOL)isUniqueName:(NSString *)name
{
    WCLPlugin *existingPlugin = [[WCLPluginManager sharedPluginManager] pluginWithName:name];
    
    if (!existingPlugin) {
        return YES;
    }
    
    return self == existingPlugin;
}

- (NSString *)uniquePluginNameFromName:(NSString *)name index:(NSUInteger)index
{
    if (index > 99) {
        return nil;
    }
    
    NSString *newName = [NSString stringWithFormat:@"%@ %lu", name, (unsigned long)index];
    if ([self isUniqueName:newName]) {
        return newName;
    }
    
    index++;
    return [self uniquePluginNameFromName:name
                                    index:index];
}

@end
