//
//  WCLTestPlugin.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 4/7/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLTestPlugin.h"

#import "WCLPlugin.h"

#import <objc/runtime.h>

#define kTestPluginObservedKeyPaths [NSArray arrayWithObjects:WCLPluginNameKey, @"command", WCLPluginExtensionsKey, @"type", nil]


@interface WCLTestPlugin ()
@property (nonatomic, retain) NSData * extensionsData;
@end

@implementation WCLTestPlugin

static void *WCLTestPluginContext;

@synthesize defaultNewPlugin = _defaultNewPlugin; // malloc_error_break error was caused by this synthesize missing
@dynamic command;
@dynamic extensionsData;
@dynamic name;
@dynamic type;
@dynamic identifier;

#pragma mark Use WCLPlugin's Implementation

- (BOOL)isDefaultNewPlugin
{
    NSAssert(NO, @"WCLPlugin's implementation should be called.");
    return NO;
}

- (void)setDefaultNewPlugin:(BOOL)defaultNewPlugin
{
    NSAssert(NO, @"WCLPlugin's implementation should be called.");
}

- (BOOL)validateName:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    NSAssert(NO, @"WCLPlugin's implementation should be called.");
    return NO;
}

- (BOOL)validateExtensions:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    NSAssert(NO, @"WCLPlugin's implementation should be called.");
    return NO;
}

- (BOOL)extensionsAreValid:(NSArray *)extensions
{
    NSAssert(NO, @"WCLPlugin's implementation should be called.");
    return NO;
}

- (BOOL)nameIsValid:(NSString *)name
{
    NSAssert(NO, @"WCLPlugin's implementation should be called.");
    return NO;
}

- (NSString *)uniquePluginNameFromName:(NSString *)name
{
    NSAssert(NO, @"WCLPlugin's implementation should be called.");
    return nil;
}

- (void)renameWithUniqueName
{
    NSAssert(NO, @"WCLPlugin's implementation should be called.");
}

- (BOOL)isUniqueName:(NSString *)name
{
    NSAssert(NO, @"WCLPlugin's implementation should be called.");
    return NO;
}

- (NSString *)uniquePluginNameFromName:(NSString *)name index:(NSUInteger)index
{
    NSAssert(NO, @"WCLPlugin's implementation should be called.");
    return nil;
}

#pragma mark Swizzling

+ (void)load {
    [self usePluginImplementationForSelector:@selector(isDefaultNewPlugin)];
    [self usePluginImplementationForSelector:@selector(setDefaultNewPlugin:)];
    [self usePluginImplementationForSelector:@selector(extensionsAreValid:)];
    [self usePluginImplementationForSelector:@selector(nameIsValid:)];
    [self usePluginImplementationForSelector:@selector(validateExtensions:error:)];
    [self usePluginImplementationForSelector:@selector(validateName:error:)];
    [self usePluginImplementationForSelector:@selector(uniquePluginNameFromName:)];
    [self usePluginImplementationForSelector:@selector(renameWithUniqueName)];
    [self usePluginImplementationForSelector:@selector(isUniqueName:)];
    [self usePluginImplementationForSelector:@selector(uniquePluginNameFromName:index:)];
}

+ (void)usePluginImplementationForSelector:(SEL)selector
{
    Method testPluginMethod = class_getInstanceMethod(self, selector);
    Method pluginMethod = class_getInstanceMethod([WCLPlugin class], selector);
    method_exchangeImplementations(testPluginMethod, pluginMethod);
}

- (BOOL)isKindOfClass:(Class)aClass
{
    if (aClass == [WCLPlugin class]) {
        return YES;
    }

    return [super isKindOfClass:aClass];
}

#pragma mark Properties

- (void)setExtensions:(NSArray *)extensions
{
    self.extensionsData = [NSKeyedArchiver archivedDataWithRootObject:extensions];
}

- (NSArray *)extensions
{
    if (!self.extensionsData) {
        return nil;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.extensionsData];
}

#pragma mark Saving

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    for (NSString *keyPath in kTestPluginObservedKeyPaths) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew
                  context:&WCLTestPluginContext];
    }
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    for (NSString *keyPath in kTestPluginObservedKeyPaths) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew
                  context:&WCLTestPluginContext];
    }
}

- (void)dealloc
{
    for (NSString *keyPath in kTestPluginObservedKeyPaths) {
        [self removeObserver:self
                  forKeyPath:keyPath
                     context:&WCLTestPluginContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context != &WCLTestPluginContext) {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
        return;
    }
    
    if (!self.identifier) {
        // Don't automatically save until the identifier is set, otherwise the setters in newPlugin will
        // cause saves to happen before all the plugins properties are initialized to valid values.
        return;
    }
    
    NSError *error;
    NSLog(@"saving, edited keypath = %@, plugin = %@", keyPath, self);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving. %@", error);
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, fileExtensions = %@", [super description], self.extensions];
}

@end