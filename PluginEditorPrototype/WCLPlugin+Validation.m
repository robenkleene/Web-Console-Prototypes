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

#pragma mark - Name

#pragma mark Public

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

#pragma mark - File Extensions

#pragma mark Public

+ (NSArray *)validFileExtensionsFromFileExtensions:(NSArray *)fileExtensions
{
    NSMutableArray *validFileExtensions = [NSMutableArray array];
    for (NSString *fileExtension in fileExtensions) {
        NSString *validFileExtension = [WCLPlugin fileExtensionContainingOnlyValidCharactersFromFileExtension:fileExtension];
        if (validFileExtension &&
            ![validFileExtensions containsObject:validFileExtension]) {
            [validFileExtensions addObject:validFileExtension];
        }
    }
    
    return validFileExtensions;
}

#pragma mark Private

+ (NSString *)fileExtensionContainingOnlyValidCharactersFromFileExtension:(NSString *)fileExtension
{
    NSCharacterSet *disallowedCharacterSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

    NSString *validFileExtension = [[fileExtension componentsSeparatedByCharactersInSet:disallowedCharacterSet] componentsJoinedByString:@""];

    if (!(validFileExtension.length > 0)) {
        return nil;
    }

    return validFileExtension;
}


@end
