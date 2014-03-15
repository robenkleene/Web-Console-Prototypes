//
//  WCLFileExtensionController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/11/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLFileExtensionController.h"

#import "WCLPluginManagerController.h"
#import "WCLPlugin.h"

#define kPluginManagerControllerPluginsKeyPath @"plugins"


#pragma mark - WCLFileExtensionDictionaryManager

@interface WCLFileExtensionDictionaryManager : NSObject
@property (nonatomic, strong, readonly) NSMutableDictionary *fileExtensionToCountDictionary;
- (NSArray *)fileExtensions;
@end

@implementation WCLFileExtensionDictionaryManager

@synthesize fileExtensionToCountDictionary = _fileExtensionToCountDictionary;

- (void)incrementFileExtension:(NSString *)fileExtension
{
    NSNumber *countNumber = self.fileExtensionToCountDictionary[fileExtension];
    if (countNumber) {
        self.fileExtensionToCountDictionary[fileExtension] = [NSNumber numberWithInteger:[countNumber integerValue] + 1];
    } else {
        self.fileExtensionToCountDictionary[fileExtension] = [NSNumber numberWithInteger:1];
    }
}

- (void)decrementFileExtension:(NSString *)fileExtension
{
    NSNumber *countNumber = self.fileExtensionToCountDictionary[fileExtension];
    NSAssert(countNumber, @"Attempted to decrement a file extension that does not exits.");
    NSAssert([countNumber integerValue] > 0, @"Attempted to decrement a file extension with a count of zero.");
    self.fileExtensionToCountDictionary[fileExtension] = [NSNumber numberWithInteger:[countNumber integerValue] - 1];

    if (!([self.fileExtensionToCountDictionary[fileExtension] integerValue] > 0)) {
        [self.fileExtensionToCountDictionary removeObjectForKey:fileExtension];
    }
}

- (NSArray *)fileExtensions
{
    if (!_fileExtensionToCountDictionary) {
        return nil;
    }
    
    return [self.fileExtensionToCountDictionary allKeys];
}

- (NSMutableDictionary *)fileExtensionToCountDictionary
{
    if (_fileExtensionToCountDictionary) {
        return _fileExtensionToCountDictionary;
    }

    _fileExtensionToCountDictionary = [NSMutableDictionary dictionary];
    
    return _fileExtensionToCountDictionary;
}

@end


#pragma mark - WCLFileExtensionController

@interface WCLFileExtensionController ()
@property (nonatomic, strong) WCLFileExtensionDictionaryManager *fileExtensionsDictionaryManager;
@end

@implementation WCLFileExtensionController

static void *WCLFileExtensionControllerContext;

@synthesize fileExtensionsDictionaryManager = _fileExtensionsDictionaryManager;

#pragma mark Interface Builder Compatible Singleton

+ (instancetype)sharedFileExtensionController
{
    static dispatch_once_t pred;
    static WCLFileExtensionController *fileExtensionController = nil;
    
    dispatch_once(&pred, ^{
        fileExtensionController = [[self hiddenAlloc] hiddenInit];
    });
    return fileExtensionController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedFileExtensionController];
}

+ (id)alloc
{
    return [self sharedFileExtensionController];
}

- (id)init
{
    return self;
}

+ (id)hiddenAlloc
{
    return [super allocWithZone:NULL];
}

- (id)hiddenInit
{
    return [super init];
}

- (void)dealloc
{
    if (_fileExtensionsDictionaryManager) {
        NSArray *plugins = [[self pluginManagerController] plugins];
        [[self pluginManagerController] removeObserver:self
                                            forKeyPath:kPluginManagerControllerPluginsKeyPath
                                               context:&WCLFileExtensionControllerContext];
        for (WCLPlugin *plugin in plugins) {
            [self removeFileExtensionsForPlugin:plugin];
        }
    }
}

- (WCLPluginManagerController *)pluginManagerController
{
    return [WCLPluginManagerController sharedPluginManagerController];
}

- (NSArray *)fileExtensions
{
    return [self.fileExtensionsDictionaryManager fileExtensions];
}

#pragma mark Properties

- (WCLFileExtensionDictionaryManager *)fileExtensionsDictionaryManager
{
    if (_fileExtensionsDictionaryManager) {
        return _fileExtensionsDictionaryManager;
    }

    _fileExtensionsDictionaryManager = [[WCLFileExtensionDictionaryManager alloc] init];

    NSArray *plugins = [[self pluginManagerController] plugins];
    
    for (WCLPlugin *plugin in plugins) {
        [self addFileExtensionsForPlugin:plugin];
    }
    
    [[self pluginManagerController] addObserver:self
                                     forKeyPath:kPluginManagerControllerPluginsKeyPath
                                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                        context:&WCLFileExtensionControllerContext];
    return _fileExtensionsDictionaryManager;
}

#pragma mark Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context != &WCLFileExtensionControllerContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if ([object isKindOfClass:[[self pluginManagerController] class]] &&
        [keyPath isEqualToString:kPluginManagerControllerPluginsKeyPath]) {

        
        NSLog(@"Break a plugin was added or removed");
        
        // NSKeyValueChangeInsertion
        // NSKeyValueChangeRemoval
        // NSKeyValueChangeReplacement
#warning Figure out test for NSKeyValueChangeReplacement
#warning Observe each new plugins fileExtensions property here
        return;
    }

    if ([object isKindOfClass:[WCLPlugin class]] &&
        [keyPath isEqualToString:WCLPluginFileExtensionsKey]) {

        NSKeyValueChange keyValueChange = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
        if (keyValueChange != NSKeyValueChangeSetting) {
            return;
        }

#warning Setup tests before doing these tests
        NSArray *oldFileExtensions;
//        if (change[NSKeyValueChangeOldKey] != [NSNull null]) {
            oldFileExtensions = change[NSKeyValueChangeOldKey];
//        }

        NSArray *newFileExtensions;
//        if (change[NSKeyValueChangeNewKey] != [NSNull null]) {
            newFileExtensions = change[NSKeyValueChangeNewKey];
//        }
        
        [self processFileExtensionChangesForPluginFromOldFileExtensions:oldFileExtensions
                                                    toNewFileExtensions:newFileExtensions];
    }
}

- (void)processFileExtensionChangesForPluginFromOldFileExtensions:(NSArray *)oldFileExtensions
                                              toNewFileExtensions:(NSArray *)newFileExtensions
{
    NSSet *oldFileExtensionsSet = [NSSet setWithArray:oldFileExtensions];
    NSSet *newFileExtensionsSet = [NSSet setWithArray:newFileExtensions];
    
    // New file extensions minus old file extensions are added file extensions.
    NSMutableSet *addedFileExtensionsSet = [newFileExtensionsSet mutableCopy];
    [addedFileExtensionsSet minusSet:oldFileExtensionsSet];
    for (NSString *fileExtension in addedFileExtensionsSet) {
        [self.fileExtensionsDictionaryManager incrementFileExtension:fileExtension];
    }

    // Old file extensions minus new file extensions are removed file extensions.
    NSMutableSet *removedFileExtensionsSet = [oldFileExtensionsSet mutableCopy];
    [removedFileExtensionsSet minusSet:newFileExtensionsSet];
    for (NSString *fileExtension in removedFileExtensionsSet) {
        [self.fileExtensionsDictionaryManager decrementFileExtension:fileExtension];
    }
}

- (void)addFileExtensionsForPlugin:(WCLPlugin *)plugin
{
    NSArray *fileExtensions = plugin.fileExtensions;

    for (NSString *fileExtension in fileExtensions) {
        [self.fileExtensionsDictionaryManager incrementFileExtension:fileExtension];
    }

    [plugin addObserver:self
             forKeyPath:WCLPluginFileExtensionsKey
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                context:&WCLFileExtensionControllerContext];
}

- (void)removeFileExtensionsForPlugin:(WCLPlugin *)plugin
{
    NSArray *fileExtensions = plugin.fileExtensions;
    
    for (NSString *fileExtension in fileExtensions) {
        [self.fileExtensionsDictionaryManager decrementFileExtension:fileExtension];
    }
    
    [plugin removeObserver:self
                forKeyPath:WCLPluginFileExtensionsKey
                   context:&WCLFileExtensionControllerContext];
}

@end
