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

NSString * const WCLPluginNameKey = @"name";
NSString * const WCLPluginExtensionsKey = @"extensions";

#define kPluginObservedKeyPaths [NSArray arrayWithObjects:WCLPluginNameKey, @"command", WCLPluginExtensionsKey, @"type", nil]

@interface WCLPlugin ()
@property (nonatomic, retain) NSData * extensionsData;
@end

@implementation WCLPlugin

static void *WCLPluginContext;

@synthesize defaultNewPlugin = _defaultNewPlugin;
@dynamic command;
@dynamic extensionsData;
@dynamic name;
@dynamic type;
@dynamic identifier;

#pragma mark - Properties

- (void)setExtensions:(NSArray *)extensions
{
    self.extensionsData = [NSKeyedArchiver archivedDataWithRootObject:extensions];
}

- (NSArray *)extensions
{
    if (!self.extensionsData) return nil;
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.extensionsData];
}

- (BOOL)validateExtensions:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    NSArray *extensions;
    if ([*ioValue isKindOfClass:[NSArray class]]) {
        extensions = *ioValue;
    }
    
    BOOL valid = [self extensionsAreValid:extensions];
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

- (void)setDefaultNewPlugin:(BOOL)defaultNewPlugin
{
    if (_defaultNewPlugin != defaultNewPlugin) {
        _defaultNewPlugin = defaultNewPlugin;
    }
}

- (BOOL)isDefaultNewPlugin
{
    BOOL isDefaultNewPlugin = [[WCLPluginManager sharedPluginManager] defaultNewPlugin] == self;

    if (_defaultNewPlugin != isDefaultNewPlugin) {
        _defaultNewPlugin = isDefaultNewPlugin;
    }
    
    return _defaultNewPlugin;
}

#pragma mark - Saving

- (void)awakeFromFetch
{
    [super awakeFromFetch];

    for (NSString *keyPath in kPluginObservedKeyPaths) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew
                  context:&WCLPluginContext];
    }
}

- (void)dealloc
{
    for (NSString *keyPath in kPluginObservedKeyPaths) {
        [self removeObserver:self
                  forKeyPath:keyPath
                     context:&WCLPluginContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context != &WCLPluginContext) {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
        return;
    }
    
    NSError *error;
    NSLog(@"saving, edited keypath = %@", keyPath);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving. %@", error);
    }
}

@end
