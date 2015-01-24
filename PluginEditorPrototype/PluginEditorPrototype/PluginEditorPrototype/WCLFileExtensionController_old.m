//
//  WCLFileExtensionController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/11/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLFileExtensionController_old.h"

#import "WCLPluginManager_old.h"
#import "WCLPlugin_old.h"
#import "WCLFileExtension_old.h"

#define kPluginManagerControllerPluginsKeyPath_old @"plugins"

#pragma mark - WCLFileExtensionsDictionaryManagerDelegate

@class WCLExtensionToFileExtensionDictionaryManager_old;

@protocol WCLExtensionToFileExtensionDictionaryManagerDelegate_old <NSObject>
- (void)fileExtensionsDictionaryManager:(WCLExtensionToFileExtensionDictionaryManager_old *)fileExtensionDictionaryManager
                    didAddFileExtension:(WCLFileExtension_old *)fileExtension;
- (void)fileExtensionsDictionaryManager:(WCLExtensionToFileExtensionDictionaryManager_old *)fileExtensionDictionaryManager
                    didRemoveFileExtension:(WCLFileExtension_old *)fileExtension;
@end

#pragma mark - WCLExtensionToFileExtensionDictionaryManager

@interface WCLExtensionToFileExtensionDictionaryManager_old : NSObject
@property (nonatomic, weak) id <WCLExtensionToFileExtensionDictionaryManagerDelegate_old> delegate;
@property (nonatomic, strong, readonly) NSMutableDictionary *extensionToFileExtensionDictionary;
- (NSArray *)extensions;
- (NSArray *)fileExtensions;
- (WCLFileExtension_old *)fileExtensionForExtension:(NSString *)extension;
@end

@implementation WCLExtensionToFileExtensionDictionaryManager_old

@synthesize extensionToFileExtensionDictionary = _extensionToFileExtensionDictionary;

- (void)addPlugin:(WCLPlugin_old *)plugin forExtension:(NSString *)extension
{    
    WCLFileExtension_old *fileExtension = self.extensionToFileExtensionDictionary[extension];

    if (!fileExtension) {
        fileExtension = [[WCLFileExtension_old alloc] initWithExtension:extension];
        self.extensionToFileExtensionDictionary[extension] = fileExtension;

        if ([self.delegate respondsToSelector:@selector(fileExtensionsDictionaryManager:didAddFileExtension:)]) {
            [self.delegate fileExtensionsDictionaryManager:self didAddFileExtension:fileExtension];
        }
    }

    [fileExtension insertObject:plugin inPluginsAtIndex:0];
}

- (void)removePlugin:(WCLPlugin_old *)plugin forExtension:(NSString *)extension
{
    WCLFileExtension_old *fileExtension = self.extensionToFileExtensionDictionary[extension];

    NSAssert(fileExtension, @"Attempted to remove a plugin for a file extension that does not exist.");
    
    NSUInteger index = [fileExtension.plugins indexOfObject:plugin];
    NSAssert(index != NSNotFound, @"Attempted to remove a plugin from a file extension's plugins that was not found.");
    
    [fileExtension removeObjectFromPluginsAtIndex:index];

    if (![fileExtension.plugins count]) {
        [self.extensionToFileExtensionDictionary removeObjectForKey:extension];
        
        if ([self.delegate respondsToSelector:@selector(fileExtensionsDictionaryManager:didRemoveFileExtension:)]) {
            [self.delegate fileExtensionsDictionaryManager:self didRemoveFileExtension:fileExtension];
        }
    }
}

- (WCLFileExtension_old *)fileExtensionForExtension:(NSString *)extension
{
    return self.extensionToFileExtensionDictionary[extension];
}

- (NSArray *)extensions
{
    return [self.extensionToFileExtensionDictionary allKeys];
}

- (NSArray *)fileExtensions
{
    return [self.extensionToFileExtensionDictionary allValues];
}

#pragma mark Properties

- (NSMutableDictionary *)extensionToFileExtensionDictionary
{
    if (_extensionToFileExtensionDictionary) {
        return _extensionToFileExtensionDictionary;
    }

    _extensionToFileExtensionDictionary = [NSMutableDictionary dictionary];
    
    return _extensionToFileExtensionDictionary;
}

@end


#pragma mark - WCLFileExtensionController

@interface WCLFileExtensionController_old () <WCLExtensionToFileExtensionDictionaryManagerDelegate_old>
@property (nonatomic, strong) WCLExtensionToFileExtensionDictionaryManager_old *fileExtensionsDictionaryManager;
@property (nonatomic, strong) NSMutableArray *mutableFileExtensions;
@end

@implementation WCLFileExtensionController_old

static void *WCLFileExtensionControllerContext_old;

@synthesize fileExtensionsDictionaryManager = _fileExtensionsDictionaryManager;

#pragma mark Interface Builder Compatible Singleton

+ (instancetype)sharedFileExtensionController
{
    static dispatch_once_t pred;
    static WCLFileExtensionController_old *fileExtensionController = nil;
    
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
        NSArray *plugins = [[WCLPluginManager_old sharedPluginManager] plugins];
        [[WCLPluginManager_old sharedPluginManager] removeObserver:self
                                                        forKeyPath:kPluginManagerControllerPluginsKeyPath_old
                                                           context:&WCLFileExtensionControllerContext_old];
        for (WCLPlugin_old *plugin in plugins) {
            [self processRemovedPlugin:plugin];
        }
    }
}

- (NSArray *)extensions
{
    return [self.fileExtensionsDictionaryManager extensions];
}

- (WCLFileExtension_old *)fileExtensionForExtension:(NSString *)extension
{
    return [self.fileExtensionsDictionaryManager fileExtensionForExtension:extension];
}

#pragma mark WCLFileExtensionsDictionaryManagerDelegate

- (void)fileExtensionsDictionaryManager:(WCLExtensionToFileExtensionDictionaryManager_old *)fileExtensionDictionaryManager
                    didAddFileExtension:(WCLFileExtension_old *)fileExtension
{
    [self insertObject:fileExtension inFileExtensionsAtIndex:0];
}

- (void)fileExtensionsDictionaryManager:(WCLExtensionToFileExtensionDictionaryManager_old *)fileExtensionDictionaryManager
                 didRemoveFileExtension:(WCLFileExtension_old *)fileExtension
{
    NSUInteger index = [self.mutableFileExtensions indexOfObject:fileExtension];
    [self removeObjectFromFileExtensionsAtIndex:index];
}


#pragma mark Properties

- (WCLExtensionToFileExtensionDictionaryManager_old *)fileExtensionsDictionaryManager
{
    if (_fileExtensionsDictionaryManager) {
        return _fileExtensionsDictionaryManager;
    }
    
    _fileExtensionsDictionaryManager = [[WCLExtensionToFileExtensionDictionaryManager_old alloc] init];
    
    NSArray *plugins = [[WCLPluginManager_old sharedPluginManager] plugins];
    
    for (WCLPlugin_old *plugin in plugins) {
        [self processAddedPlugin:plugin];
    }
    
    [[WCLPluginManager_old sharedPluginManager] addObserver:self
                                                 forKeyPath:kPluginManagerControllerPluginsKeyPath_old
                                                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                                    context:&WCLFileExtensionControllerContext_old];
    
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


#pragma mark Required Key-Value Coding To-Many Relationship Compliance for fileExtensions

// All accessors do nothing if _mutableFileExtensions is nil because we don't
// care about key-value observing until the plugins array is being observed.

- (NSArray *)fileExtensions
{
    return [NSArray arrayWithArray:self.mutableFileExtensions];
}

- (void)insertObject:(NSString *)fileExtension inFileExtensionsAtIndex:(NSUInteger)index
{
    if (_mutableFileExtensions) {
        [self.mutableFileExtensions insertObject:fileExtension atIndex:index];
    }
}

- (void)insertFileExtensions:(NSArray *)fileExtensionsArray atIndexes:(NSIndexSet *)indexes
{
    if (_mutableFileExtensions) {
        [self.mutableFileExtensions insertObjects:fileExtensionsArray atIndexes:indexes];
    }
}

- (void)removeObjectFromFileExtensionsAtIndex:(NSUInteger)index
{
    if (_mutableFileExtensions) {
        [self.mutableFileExtensions removeObjectAtIndex:index];
    }
}

- (void)removeFileExtensionsAtIndexes:(NSIndexSet *)indexes
{
    if (_mutableFileExtensions) {
        [self.mutableFileExtensions removeObjectsAtIndexes:indexes];
    }
}



#pragma mark Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context != &WCLFileExtensionControllerContext_old) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if ([object isKindOfClass:[[WCLPluginManager_old sharedPluginManager] class]] &&
        [keyPath isEqualToString:kPluginManagerControllerPluginsKeyPath_old]) {
        
        NSKeyValueChange keyValueChange = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
        switch (keyValueChange) {
            case NSKeyValueChangeInsertion: {
                NSArray *plugins = change[NSKeyValueChangeNewKey];
                for (WCLPlugin_old *plugin in plugins) {
                    [self processAddedPlugin:plugin];
                }
                break;
            }
            case NSKeyValueChangeRemoval: {
                NSArray *plugins = change[NSKeyValueChangeOldKey];
                for (WCLPlugin_old *plugin in plugins) {
                    [self processRemovedPlugin:plugin];
                }
                break;
            }
            default:
                NSAssert(NO, @"The NSKeyValueChangeKindKey is unhandled.");
                break;
        }

        return;
    }

    if ([object isKindOfClass:[WCLPlugin_old class]] &&
        [keyPath isEqualToString:WCLPluginExtensionsKey]) {

        WCLPlugin_old *plugin = (WCLPlugin_old *)object;

        NSKeyValueChange keyValueChange = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
        if (keyValueChange != NSKeyValueChangeSetting) {
            return;
        }

        NSArray *oldExtensions;
        if (change[NSKeyValueChangeOldKey] != [NSNull null]) {
            oldExtensions = change[NSKeyValueChangeOldKey];
        }

        NSArray *newExtensions;
        if (change[NSKeyValueChangeNewKey] != [NSNull null]) {
            newExtensions = change[NSKeyValueChangeNewKey];
        }
        
        [self processExtensionChangesForPlugin:(WCLPlugin_old *)plugin
                                fromExtensions:oldExtensions
                                  toExtensions:newExtensions];
        return;
    }
}

- (void)processExtensionChangesForPlugin:(WCLPlugin_old *)plugin
                          fromExtensions:(NSArray *)oldExtensions
                            toExtensions:(NSArray *)newExtensions
{
    NSSet *oldExtensionsSet = [NSSet setWithArray:oldExtensions];
    NSSet *newExtensionsSet = [NSSet setWithArray:newExtensions];
    
    // New file extensions minus old file extensions are added file extensions.
    NSMutableSet *addedExtensionsSet = [newExtensionsSet mutableCopy];
    [addedExtensionsSet minusSet:oldExtensionsSet];
    for (NSString *extension in addedExtensionsSet) {
        [self.fileExtensionsDictionaryManager addPlugin:plugin forExtension:extension];
    }

    // Old file extensions minus new file extensions are removed file extensions.
    NSMutableSet *removedExtensionsSet = [oldExtensionsSet mutableCopy];
    [removedExtensionsSet minusSet:newExtensionsSet];
    for (NSString *extension in removedExtensionsSet) {
        [self.fileExtensionsDictionaryManager removePlugin:plugin forExtension:extension];
    }
}

- (void)processAddedPlugin:(WCLPlugin_old *)plugin
{
    NSArray *extensions = plugin.extensions;

    for (NSString *extension in extensions) {
        [self.fileExtensionsDictionaryManager addPlugin:plugin forExtension:extension];
    }

    [plugin addObserver:self
             forKeyPath:WCLPluginExtensionsKey
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                context:&WCLFileExtensionControllerContext_old];
}

- (void)processRemovedPlugin:(WCLPlugin_old *)plugin
{
    NSArray *extensions = plugin.extensions;
    
    for (NSString *extension in extensions) {
        [self.fileExtensionsDictionaryManager removePlugin:plugin forExtension:extension];
    }
    
    [plugin removeObserver:self
                forKeyPath:WCLPluginExtensionsKey
                   context:&WCLFileExtensionControllerContext_old];
}

@end
