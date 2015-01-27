//
//  WCLPlugin.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

#import "WCLPlugin.h"
#import "WCLPlugin+Validation.h"
#import "PluginEditorPrototype-Swift.h"

@implementation WCLPlugin

@synthesize defaultNewPlugin = _defaultNewPlugin;

- (void)setDefaultNewPlugin:(BOOL)defaultNewPlugin
{
#warning It's problematic that using this setter without going through the plugin manager, will set the flag to true without it actually being the default new plugin
    
    if (_defaultNewPlugin != defaultNewPlugin) {
        _defaultNewPlugin = defaultNewPlugin;
    }
}

- (BOOL)isDefaultNewPlugin
{    
    BOOL isDefaultNewPlugin = (self.pluginsManager.defaultNewPlugin == self);

    if (_defaultNewPlugin != isDefaultNewPlugin) {
        _defaultNewPlugin = isDefaultNewPlugin;
    }
    
    return _defaultNewPlugin;
}

#pragma mark Validation

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

@end
