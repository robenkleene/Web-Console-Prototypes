//
//  WCLFileExtensionController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/11/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLFileExtensionToPluginsController.h"

#import "WCLPluginManagerController.h"
#import "WCLPlugin.h"

#define kPluginManagerControllerPluginsKeyPath @"plugins"

#pragma mark - WCLFileExtensionsDictionaryManagerDelegate

@class WCLFileExtensionToPluginsDictionaryManager;

@protocol WCLFileExtensionToPluginsDictionaryManagerDelegate <NSObject>
- (void)fileExtensionsDictionaryManager:(WCLFileExtensionToPluginsDictionaryManager *)fileExtensionDictionaryManager
                    didAddFileExtension:(NSString *)fileExtension;
- (void)fileExtensionsDictionaryManager:(WCLFileExtensionToPluginsDictionaryManager *)fileExtensionDictionaryManager
                    didRemoveFileExtension:(NSString *)fileExtension;
@end

#pragma mark - WCLFileExtensionToPluginsDictionaryManager

@interface WCLFileExtensionToPluginsDictionaryManager : NSObject
@property (nonatomic, weak) id <WCLFileExtensionToPluginsDictionaryManagerDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableDictionary *fileExtensionToCountDictionary;
- (NSArray *)fileExtensions;
@end

@implementation WCLFileExtensionToPluginsDictionaryManager

@synthesize fileExtensionToCountDictionary = _fileExtensionToCountDictionary;

- (void)incrementFileExtension:(NSString *)fileExtension
{
    NSNumber *countNumber = self.fileExtensionToCountDictionary[fileExtension];
    if (countNumber) {
        self.fileExtensionToCountDictionary[fileExtension] = [NSNumber numberWithInteger:[countNumber integerValue] + 1];
    } else {
        [self addFileExtension:fileExtension];
    }
}

- (void)decrementFileExtension:(NSString *)fileExtension
{
    NSNumber *countNumber = self.fileExtensionToCountDictionary[fileExtension];
    NSAssert(countNumber, @"Attempted to decrement a file extension that does not exits.");
    NSAssert([countNumber integerValue] > 0, @"Attempted to decrement a file extension with a count of zero.");
    self.fileExtensionToCountDictionary[fileExtension] = [NSNumber numberWithInteger:[countNumber integerValue] - 1];

    if (!([self.fileExtensionToCountDictionary[fileExtension] integerValue] > 0)) {
        [self removeFileExtension:fileExtension];
    }
}

- (void)addFileExtension:(NSString *)fileExtension
{
    self.fileExtensionToCountDictionary[fileExtension] = [NSNumber numberWithInteger:1];

    if ([self.delegate respondsToSelector:@selector(fileExtensionsDictionaryManager:didAddFileExtension:)]) {
        [self.delegate fileExtensionsDictionaryManager:self didAddFileExtension:fileExtension];
    }
}

- (void)removeFileExtension:(NSString *)fileExtension
{
    [self.fileExtensionToCountDictionary removeObjectForKey:fileExtension];

    if ([self.delegate respondsToSelector:@selector(fileExtensionsDictionaryManager:didRemoveFileExtension:)]) {
        [self.delegate fileExtensionsDictionaryManager:self didRemoveFileExtension:fileExtension];
    }
}

- (NSArray *)fileExtensions
{
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

@interface WCLFileExtensionToPluginsController () <WCLFileExtensionToPluginsDictionaryManagerDelegate>
@property (nonatomic, strong) WCLFileExtensionToPluginsDictionaryManager *fileExtensionsDictionaryManager;
@property (nonatomic, strong) NSMutableArray *mutableFileExtensions;
@end

@implementation WCLFileExtensionToPluginsController

static void *WCLFileExtensionControllerContext;

@synthesize fileExtensionsDictionaryManager = _fileExtensionsDictionaryManager;

#pragma mark Interface Builder Compatible Singleton

+ (instancetype)sharedFileExtensionController
{
    static dispatch_once_t pred;
    static WCLFileExtensionToPluginsController *fileExtensionController = nil;
    
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
            [self processRemovedPlugin:plugin];
        }
    }
}

- (WCLPluginManagerController *)pluginManagerController
{
    return [WCLPluginManagerController sharedPluginManagerController];
}


#pragma mark Properties

- (WCLFileExtensionToPluginsDictionaryManager *)fileExtensionsDictionaryManager
{
    if (_fileExtensionsDictionaryManager) {
        return _fileExtensionsDictionaryManager;
    }

    _fileExtensionsDictionaryManager = [[WCLFileExtensionToPluginsDictionaryManager alloc] init];

    NSArray *plugins = [[self pluginManagerController] plugins];
    
    for (WCLPlugin *plugin in plugins) {
        [self processAddedPlugin:plugin];
    }
    
    [[self pluginManagerController] addObserver:self
                                     forKeyPath:kPluginManagerControllerPluginsKeyPath
                                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                        context:&WCLFileExtensionControllerContext];

    return _fileExtensionsDictionaryManager;
}

- (NSMutableArray *)mutableFileExtensions
{
    if (_mutableFileExtensions) {
        return _mutableFileExtensions;
    }
    
    _mutableFileExtensions = [[self.fileExtensionsDictionaryManager fileExtensions] mutableCopy];
    self.fileExtensionsDictionaryManager.delegate = self;
    
    
    return _mutableFileExtensions;
}

#pragma mark WCLFileExtensionsDictionaryManagerDelegate

- (void)fileExtensionsDictionaryManager:(WCLFileExtensionToPluginsDictionaryManager *)fileExtensionDictionaryManager
                    didAddFileExtension:(NSString *)fileExtension
{
    [self insertObject:fileExtension inFileExtensionsAtIndex:0];
}

- (void)fileExtensionsDictionaryManager:(WCLFileExtensionToPluginsDictionaryManager *)fileExtensionDictionaryManager
                 didRemoveFileExtension:(NSString *)fileExtension
{
    NSUInteger index = [self.mutableFileExtensions indexOfObject:fileExtension];
    [self removeObjectFromFileExtensionsAtIndex:index];
}

#pragma mark Required Key-Value Coding To-Many Relationship Compliance

- (NSArray *)fileExtensions
{
    return [NSArray arrayWithArray:self.mutableFileExtensions];
}

- (void)insertObject:(NSString *)fileExtension inFileExtensionsAtIndex:(NSUInteger)index
{
    [self.mutableFileExtensions insertObject:fileExtension atIndex:index];
}

- (void)insertFileExtensions:(NSArray *)fileExtensionsArray atIndexes:(NSIndexSet *)indexes
{
    [self.mutableFileExtensions insertObjects:fileExtensionsArray atIndexes:indexes];
}

- (void)removeObjectFromFileExtensionsAtIndex:(NSUInteger)index
{
    [self.mutableFileExtensions removeObjectAtIndex:index];
}

- (void)removeFileExtensionsAtIndexes:(NSIndexSet *)indexes
{
    [self.mutableFileExtensions removeObjectsAtIndexes:indexes];
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



        NSKeyValueChange keyValueChange = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
        switch (keyValueChange) {
            case NSKeyValueChangeInsertion: {
                NSArray *plugins = change[NSKeyValueChangeNewKey];
                for (WCLPlugin *plugin in plugins) {
                    [self processAddedPlugin:plugin];
                }
                break;
            }
            case NSKeyValueChangeRemoval: {
                NSArray *plugins = change[NSKeyValueChangeOldKey];
                for (WCLPlugin *plugin in plugins) {
                    [self processRemovedPlugin:plugin];
                }
                break;
            }
            default:
#warning Figure out case for NSKeyValueChangeReplacement?
                NSAssert(NO, @"The NSKeyValueChangeKindKey is unhandled.");
                break;
        }

        return;
    }

    if ([object isKindOfClass:[WCLPlugin class]] &&
        [keyPath isEqualToString:WCLPluginFileExtensionsKey]) {

        NSKeyValueChange keyValueChange = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
        if (keyValueChange != NSKeyValueChangeSetting) {
            return;
        }

        NSArray *oldFileExtensions;
        if (change[NSKeyValueChangeOldKey] != [NSNull null]) {
            oldFileExtensions = change[NSKeyValueChangeOldKey];
        }

        NSArray *newFileExtensions;
        if (change[NSKeyValueChangeNewKey] != [NSNull null]) {
            newFileExtensions = change[NSKeyValueChangeNewKey];
        }
        
        [self processFileExtensionChangesForPluginFromOldFileExtensions:oldFileExtensions
                                                    toNewFileExtensions:newFileExtensions];

        return;
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

- (void)processAddedPlugin:(WCLPlugin *)plugin
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

- (void)processRemovedPlugin:(WCLPlugin *)plugin
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
