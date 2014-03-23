//
//  WCLPlugin+Validation.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPlugin+Validation.h"
#import "WCLPlugin+PluginManager.h"
#import "WCLPluginManager.h"

@implementation WCLPlugin (Validation)

#pragma mark - Name

#pragma mark Public

+ (BOOL)nameContainsOnlyValidCharacters:(NSString *)name
{
    return [WCLPlugin string:name containsOnlyCharactersInCharacterSet:[WCLPlugin nameAllowedCharacterSet]];
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

+ (NSCharacterSet *)nameAllowedCharacterSet
{
    NSMutableCharacterSet *allowedCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"_- "];
    [allowedCharacterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
    
    return allowedCharacterSet;
}

#pragma mark - File Extensions

#pragma mark Public

- (BOOL)extensionsAreValid:(NSArray *)extensions
{
    NSCountedSet *extensionsCountedSet = [[NSCountedSet alloc] initWithArray:extensions];
    for (NSString *extension in extensionsCountedSet) {
        if (![extension isKindOfClass:[NSString class]] || // Must be a string
            !(extension.length > 0) || // Must be greater than zero characters
            !([WCLPlugin extensionContainsOnlyValidCharacters:extension])) { // Must only contain valid characters
            return NO;
        }
        
        if ([extensionsCountedSet countForObject:extension] > 1) {
            // Must not contain duplicates
            return NO;
        }
    }

    return YES;
}

+ (NSArray *)validExtensionsFromExtensions:(NSArray *)extensions
{
    NSMutableArray *validExtensions = [NSMutableArray array];
    for (NSString *fileExtension in extensions) {
        NSString *validFileExtension = [WCLPlugin extensionContainingOnlyValidCharactersFromExtension:fileExtension];
        if (validFileExtension &&
            ![validExtensions containsObject:validFileExtension]) {
            [validExtensions addObject:validFileExtension];
        }
    }
    
    return validExtensions;
}

#pragma mark Private

+ (BOOL)extensionContainsOnlyValidCharacters:(NSString *)extension
{
    return [WCLPlugin string:extension containsOnlyCharactersInCharacterSet:[WCLPlugin fileExtensionAllowedCharacterSet]];
}

+ (NSString *)extensionContainingOnlyValidCharactersFromExtension:(NSString *)extension
{
    NSCharacterSet *disallowedCharacterSet = [[WCLPlugin fileExtensionAllowedCharacterSet] invertedSet];

    NSString *validExtension = [[extension componentsSeparatedByCharactersInSet:disallowedCharacterSet] componentsJoinedByString:@""];

    if (!(validExtension.length > 0)) {
        return nil;
    }

    return validExtension;
}

+ (NSCharacterSet *)fileExtensionAllowedCharacterSet
{
    return [NSCharacterSet alphanumericCharacterSet];
}

#pragma mark - Helpers

+ (BOOL)string:(NSString *)string containsOnlyCharactersInCharacterSet:(NSCharacterSet *)characterSet
{
    NSCharacterSet *invertedCharacterSet = [characterSet invertedSet];
    
    NSRange disallowedRange = [string rangeOfCharacterFromSet:invertedCharacterSet];
    BOOL foundCharacterInInvertedSet = !(NSNotFound == disallowedRange.location);
    
    return !foundCharacterInInvertedSet;
}
@end
