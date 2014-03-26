//
//  WCLFileExtension.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/23/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLFileExtension.h"

#import "WCLPlugin.h"
#import "WCLPluginManager.h"

#define kFileExtensionObservedKeyPaths [NSArray arrayWithObjects:kFileExtensionEnabledKey, kFileExtensionPluginIdentifierKey, nil]

@interface WCLFileExtension ()
@property (nonatomic, strong, readonly) NSMutableDictionary *fileExtensionPluginDictionary;
@end

@implementation WCLFileExtension

static void *WCLFileExtensionContext;

@synthesize selectedPlugin = _selectedPlugin;
@synthesize fileExtensionPluginDictionary = _fileExtensionPluginDictionary;

- (id)initWithExtension:(NSString *)extension {
    self = [super init];
    if (self) {
		_extension = extension;
        _plugins = [NSMutableArray array];
    }
    return self;
}


#pragma mark Properties

- (BOOL)isEnabled
{
    NSNumber *enabledNumber = [self.fileExtensionPluginDictionary objectForKey:kFileExtensionEnabledKey];

    if (!enabledNumber) {
        enabledNumber = [NSNumber numberWithBool:kFileExtensionDefaultEnabled];
    }

    return [enabledNumber boolValue];
}

- (void)setEnabled:(BOOL)enabled
{
    if (self.isEnabled == enabled) {
        return;
    }

    [self.fileExtensionPluginDictionary setValue:[NSNumber numberWithBool:enabled]
                                          forKey:kFileExtensionEnabledKey];
}

- (WCLPlugin *)selectedPlugin
{
    if (_selectedPlugin) {
        return _selectedPlugin;
    }

    NSString *identifier = [self.fileExtensionPluginDictionary objectForKey:kFileExtensionEnabledKey];

    if (identifier) {
        _selectedPlugin = [[WCLPluginManager sharedPluginManager] pluginWithIdentifier:identifier];
    }
    
    return _selectedPlugin;
}

- (void)setSelectedPlugin:(WCLPlugin *)selectedPlugin
{
    if (self.selectedPlugin == selectedPlugin) {
        return;
    }

    _selectedPlugin = selectedPlugin;

    if (_selectedPlugin) {
        [self.fileExtensionPluginDictionary setValue:selectedPlugin.identifier
                                              forKey:kFileExtensionPluginIdentifierKey];
    } else {
        [self.fileExtensionPluginDictionary removeObjectForKey:kFileExtensionPluginIdentifierKey];
    }
}

- (BOOL)validateSelectedPlugin:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    // TODO: Implement
    
    WCLPlugin *plugin;
    if ([*ioValue isKindOfClass:[WCLPlugin class]]) {
        plugin = *ioValue;
    }

    return plugin ? YES : NO;
    
//    BOOL valid = [self nameIsValid:name];
//    if (!valid && outError) {
//        NSString *errorMessage = @"The plugin name must be unique, and can only contain alphanumeric characters, spaces, hyphens and underscores.";
//        NSString *errorString = NSLocalizedString(errorMessage, @"Invalid plugin name error.");
//        
//        NSDictionary *userInfoDict = @{NSLocalizedDescriptionKey: errorString};
//        *outError = [[NSError alloc] initWithDomain:kErrorDomain
//                                               code:kErrorCodeInvalidPlugin
//                                           userInfo:userInfoDict];
//    }
//    
//    return valid;
}

#pragma mark - NSUserDefaults Dictionary

- (NSMutableDictionary *)fileExtensionPluginDictionary
{
    if (_fileExtensionPluginDictionary) {
        return _fileExtensionPluginDictionary;
    }
    
    NSDictionary *fileExtensionToPluginDictionary = [[self class] fileExtensionToPluginDictionary];
    
    NSMutableDictionary *fileExtensionPluginDictionary = [[fileExtensionToPluginDictionary valueForKey:self.extension] mutableCopy];

    if (!fileExtensionPluginDictionary) {
        fileExtensionPluginDictionary = [NSMutableDictionary dictionary];
    }
    
    _fileExtensionPluginDictionary = fileExtensionPluginDictionary;
    
    for (NSString *keyPath in kFileExtensionObservedKeyPaths) {
        [_fileExtensionPluginDictionary addObserver:self
                                         forKeyPath:keyPath
                                            options:NSKeyValueObservingOptionNew
                                            context:&WCLFileExtensionContext];
    }
    
    return _fileExtensionPluginDictionary;
}

+ (void)setfileExtensionToPluginDictionary:(NSDictionary *)fileExtensionToPluginDictionary
{
    [[NSUserDefaults standardUserDefaults] setValue:fileExtensionToPluginDictionary forKey:kFileExtensionToPluginKey];
}

+ (NSDictionary *)fileExtensionToPluginDictionary
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kFileExtensionToPluginKey];
}

- (void)dealloc
{
    if (_fileExtensionPluginDictionary) {
        for (NSString *keyPath in kFileExtensionObservedKeyPaths) {
            [_fileExtensionPluginDictionary removeObserver:self
                                                forKeyPath:keyPath
                                                   context:&WCLFileExtensionContext];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context != &WCLFileExtensionContext) {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
        return;
    }

    NSMutableDictionary *fileExtensionToPluginDictionary = [[[self class] fileExtensionToPluginDictionary] mutableCopy];
    
    if (!fileExtensionToPluginDictionary) {
        fileExtensionToPluginDictionary = [NSMutableDictionary dictionary];
    }

    [fileExtensionToPluginDictionary setValue:self.fileExtensionPluginDictionary forKey:self.extension];

    [[self class] setfileExtensionToPluginDictionary:fileExtensionToPluginDictionary];
}

@end