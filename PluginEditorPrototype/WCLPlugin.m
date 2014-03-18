//
//  WCLPlugin.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/16/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPlugin.h"
#import "WCLPlugin+Validation.h"
#import "WCLPlugin+PluginManager.h"
#import "WCLPluginManager.h"

#define kObservedSelectionKeyPaths [NSArray arrayWithObjects:@"name", @"command", @"fileExtensions", @"type", nil]

NSString * const WCLPluginNameKey = @"name";
NSString * const WCLPluginFileExtensionsKey = @"fileExtensions";

@interface WCLPlugin ()
@property (nonatomic, retain) NSData * fileExtensionsData;
@end

@implementation WCLPlugin

static void *WCLPluginContext;

@synthesize defaultNewPlugin = _defaultNewPlugin;
@dynamic command;
@dynamic fileExtensionsData;
@dynamic name;
@dynamic type;
@dynamic identifier;

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

- (BOOL)validateFileExtensions:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    NSArray *fileExtensions;
    if ([*ioValue isKindOfClass:[NSArray class]]) {
        fileExtensions = *ioValue;
    }
    
    BOOL valid = [self fileExtensionsAreValid:fileExtensions];
    if (!valid && outError) {
        NSString *errorMessage = @"The file extensions must be unique, and can only contain alphanumeric characters.";
        NSString *errorString = NSLocalizedString(errorMessage, @"Invalid file extensions error.");
        
        NSDictionary *userInfoDict = @{NSLocalizedDescriptionKey: errorString};
        *outError = [[NSError alloc] initWithDomain:kErrorDomain
                                               code:kErrorCodeInvalidPlugin
                                           userInfo:userInfoDict];
    }

    return valid;
}

- (BOOL)validateName:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    NSString *name;
    if ([*ioValue isKindOfClass:[NSString class]]) {
        name = *ioValue;
    }

    BOOL valid = [self nameIsValid:name];
    if (!valid && outError) {
        NSString *errorMessage = @"The plugin name must be unique, and can only contain alphanumeric characters, spaces, hyphens and underscores.";
        NSString *errorString = NSLocalizedString(errorMessage, @"Invalid plugin name error.");

        NSDictionary *userInfoDict = @{NSLocalizedDescriptionKey: errorString};
        *outError = [[NSError alloc] initWithDomain:kErrorDomain
                                               code:kErrorCodeInvalidPlugin
                                           userInfo:userInfoDict];
    }

    return valid;
}

- (BOOL)isDefaultNewPlugin
{
    return [[WCLPluginManager sharedPluginManager] defaultNewPlugin] == self;
}

#pragma mark - Saving

- (void)awakeFromFetch
{
    [super awakeFromFetch];

    for (NSString *keyPath in kObservedSelectionKeyPaths) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew
                  context:&WCLPluginContext];
    }
}

- (void)dealloc
{
    for (NSString *keyPath in kObservedSelectionKeyPaths) {
        [self removeObserver:self
                  forKeyPath:keyPath
                     context:&WCLPluginContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &WCLPluginContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    NSError *error;
    NSLog(@"saving, edited keypath = %@", keyPath);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving. %@", error);
    }
}

@end
