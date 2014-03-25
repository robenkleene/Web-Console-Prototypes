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
@property (nonatomic, strong, readonly) NSMutableDictionary *userDefaultsDictionary;
@end

@implementation WCLFileExtension

static void *WCLFileExtensionContext;

@synthesize selectedPlugin = _selectedPlugin;
@synthesize userDefaultsDictionary = _userDefaultsDictionary;

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
    NSNumber *enabledNumber = [self.userDefaultsDictionary objectForKey:kFileExtensionEnabledKey];

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

    [self.userDefaultsDictionary setValue:[NSNumber numberWithBool:enabled]
                                   forKey:kFileExtensionEnabledKey];
}

- (WCLPlugin *)selectedPlugin
{
    if (_selectedPlugin) {
        return _selectedPlugin;
    }

    NSString *identifier = [self.userDefaultsDictionary objectForKey:kFileExtensionEnabledKey];

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
        [self.userDefaultsDictionary setValue:selectedPlugin.identifier
                                       forKey:kFileExtensionPluginIdentifierKey];
    }
}


#pragma mark - NSUserDefaults Dictionary

- (NSMutableDictionary *)userDefaultsDictionary
{
    if (_userDefaultsDictionary) {
        return _userDefaultsDictionary;
    }
    
    NSDictionary *fileExtensionPluginDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:kFileExtensionPluginsKey];
    
    NSMutableDictionary *userDefaultsDictionary = [[fileExtensionPluginDictionary valueForKey:self.extension] mutableCopy];

    if (!userDefaultsDictionary) {
        userDefaultsDictionary = [NSMutableDictionary dictionary];
    }
    
    _userDefaultsDictionary = userDefaultsDictionary;
    
    for (NSString *keyPath in kFileExtensionObservedKeyPaths) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew
                  context:&WCLFileExtensionContext];
    }

    
    return _userDefaultsDictionary;
}

- (void)dealloc
{
    if (_userDefaultsDictionary) {
        for (NSString *keyPath in kFileExtensionObservedKeyPaths) {
            [self removeObserver:self
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

    NSLog(@"A change happened");
}

@end