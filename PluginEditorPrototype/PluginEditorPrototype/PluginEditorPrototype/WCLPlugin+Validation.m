//
//  WCLPlugin+Validation.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPlugin+Validation.h"
#import "WCLPluginManager_old.h"

@implementation WCLPlugin_old (Validation)

#pragma mark Name Public

+ (BOOL)nameContainsOnlyValidCharacters:(NSString *)name
{
    return [self string:name containsOnlyCharactersInCharacterSet:[WCLPlugin_old nameAllowedCharacterSet]];
}

- (BOOL)nameIsValid:(NSString *)name
{
    if (!name) {
        return NO;
    }
    
    if (![WCLPlugin_old nameContainsOnlyValidCharacters:name]) {
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
    self.name = [self uniquePluginNameFromName:self.name];
}

- (NSString *)uniquePluginNameFromName:(NSString *)name
{
    if ([self isUniqueName:name]) {
        return name;
    }
    
    NSString *newName = [self uniquePluginNameFromName:name index:2];
    
    if (!newName) {
        newName = self.identifier;
    }
    
    return newName;
}

#pragma mark Name Private

- (BOOL)isUniqueName:(NSString *)name
{
    WCLPlugin_old *existingPlugin = [[WCLPluginManager_old sharedPluginManager] pluginWithName:name];
    
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


#pragma mark File Extensions Public

- (BOOL)extensionsAreValid:(NSArray *)extensions
{
    NSCountedSet *extensionsCountedSet = [[NSCountedSet alloc] initWithArray:extensions];
    for (NSString *extension in extensionsCountedSet) {
        if (![extension isKindOfClass:[NSString class]] || // Must be a string
            !(extension.length > 0) || // Must be greater than zero characters
            !([WCLPlugin_old extensionContainsOnlyValidCharacters:extension])) { // Must only contain valid characters
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
        NSString *validFileExtension = [WCLPlugin_old extensionContainingOnlyValidCharactersFromExtension:fileExtension];
        if (validFileExtension &&
            ![validExtensions containsObject:validFileExtension]) {
            [validExtensions addObject:validFileExtension];
        }
    }
    
    return validExtensions;
}

#pragma mark File Extensions Private

+ (BOOL)extensionContainsOnlyValidCharacters:(NSString *)extension
{
    return [self string:extension containsOnlyCharactersInCharacterSet:[self fileExtensionAllowedCharacterSet]];
}

+ (NSString *)extensionContainingOnlyValidCharactersFromExtension:(NSString *)extension
{
    NSCharacterSet *disallowedCharacterSet = [[self fileExtensionAllowedCharacterSet] invertedSet];

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

#pragma mark Helpers

+ (BOOL)string:(NSString *)string containsOnlyCharactersInCharacterSet:(NSCharacterSet *)characterSet
{
    NSCharacterSet *invertedCharacterSet = [characterSet invertedSet];
    
    NSRange disallowedRange = [string rangeOfCharacterFromSet:invertedCharacterSet];
    BOOL foundCharacterInInvertedSet = !(NSNotFound == disallowedRange.location);
    
    return !foundCharacterInInvertedSet;
}
@end
