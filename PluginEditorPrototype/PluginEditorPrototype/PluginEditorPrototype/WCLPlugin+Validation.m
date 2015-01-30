//
//  WCLPlugin+Validation.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPlugin+Validation.h"
#import "PluginEditorPrototype-Swift.h"

@implementation WCLPlugin (Validation)

#pragma mark Name Public

+ (BOOL)nameContainsOnlyValidCharacters:(NSString *)name
{
    return [self string:name containsOnlyCharactersInCharacterSet:[WCLPlugin nameAllowedCharacterSet]];
}

- (BOOL)nameIsValid:(NSString *)name
{
    if (!name) {
        return NO;
    }

    if (![WCLPlugin nameContainsOnlyValidCharacters:name]) {
        return NO;
    }

    if (![[self class] isUniqueName:name forPlugin:self]) {
        return NO;
    }

    return YES;
}

- (NSString *)identifier
{
    NSAssert(NO, @"Subclass must override");
    return nil;
}

+ (NSString *)uniquePluginNameFromName:(NSString *)name
{
    return [self uniquePluginNameFromName:name forPlugin:nil];
}

+ (NSString *)uniquePluginNameFromName:(NSString *)name forPlugin:(WCLPlugin *)plugin
{
    if ([self isUniqueName:name forPlugin:plugin]) {
        return name;
    }
    
    NSString *newName = [self uniquePluginNameFromName:name forPlugin:plugin index:2];
    
    if (!newName && plugin) {
        newName = plugin.identifier;
    }
    
    return newName;
}


#pragma mark Name Private

+ (BOOL)isUniqueName:(NSString *)name forPlugin:(WCLPlugin *)plugin
{
    Plugin *existingPlugin = [self.pluginsManager pluginWithName:name];
    
    if (!existingPlugin) {
        return YES;
    }

    // Once we've determined there is an existing plugin, the name is only valid if the existing plugin is this plugin
    if (!plugin) {
        return NO;
    }
    
    return plugin == existingPlugin;
}

+ (NSString *)uniquePluginNameFromName:(NSString *)name forPlugin:(WCLPlugin *)plugin index:(NSUInteger)index
{
    if (index > 99) {
        return nil;
    }

    NSString *newName = [NSString stringWithFormat:@"%@ %lu", name, (unsigned long)index];
    if ([self isUniqueName:newName forPlugin:plugin]) {
        return newName;
    }

    index++;
    return [self uniquePluginNameFromName:name
                                forPlugin:plugin
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
    return [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
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
