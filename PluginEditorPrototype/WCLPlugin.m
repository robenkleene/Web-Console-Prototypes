//
//  WCLPlugin.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/16/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPlugin.h"

#define kObservedSelectionKeyPaths [NSArray arrayWithObjects:@"name", @"command", @"fileExtensions", @"type", nil]

@interface WCLPlugin ()
@property (nonatomic, retain) NSData * fileExtensionsData;
+ (BOOL)isValidName:(NSString *)name;
+ (BOOL)nameIsUnique:(NSString *)name;
@end

@implementation WCLPlugin

static void *WCLPlugiContext;


@dynamic command;
@dynamic fileExtensionsData;
@dynamic name;
@dynamic type;

#pragma mark - Properties

- (void)setFileExtensions:(NSArray *)fileExtensions
{
    self.fileExtensionsData = [NSKeyedArchiver archivedDataWithRootObject:fileExtensions];
}

- (NSArray *)fileExtensions
{
    if (!self.fileExtensionsData) return nil;
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.fileExtensionsData];
}

- (BOOL)validateName:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    NSString *name;
    if ([*ioValue isKindOfClass:[NSString class]]) {
        name = *ioValue;
    }

    BOOL valid = [WCLPlugin isValidName:name];
    if (!valid && outError) {
        NSString *errorMessage = @"The plugin name must be unique, and can only contain alphanumeric characters, spaces, hyphens and underscores.";
        NSString *errorString = NSLocalizedString(errorMessage, @"Invalid plugin name error.");

        NSDictionary *userInfoDict = @{NSLocalizedDescriptionKey: errorString};
        *outError = [[NSError alloc] initWithDomain:kErrorDomain
                                               code:kErrorCodeInvalidePluginName
                                           userInfo:userInfoDict];
    }

    return valid;
}

+ (BOOL)isValidName:(NSString *)name
{
    return name && [WCLPlugin nameContainsOnlyValidCharacters:name] && [WCLPlugin nameIsUnique:name];
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
    return YES;
}

#pragma mark - Saving

- (void)awakeFromFetch
{
    [super awakeFromFetch];

    for (NSString *keyPath in kObservedSelectionKeyPaths) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew
                  context:&WCLPlugiContext];
    }
}

- (void)dealloc
{
    for (NSString *keyPath in kObservedSelectionKeyPaths) {
        [self removeObserver:self
                  forKeyPath:keyPath
                     context:&WCLPlugiContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &WCLPlugiContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    NSError *error;
    NSLog(@"saving, edited keypath = %@", keyPath);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving.");
    }
}

@end
