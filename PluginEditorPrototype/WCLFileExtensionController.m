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
#import "WCLFileExtension.h"

#define kPluginManagerControllerPluginsKeyPath @"plugins"

#pragma mark - WCLFileExtensionsDictionaryManagerDelegate

@class WCLExtensionToFileExtensionDictionaryManager;

@protocol WCLExtensionToFileExtensionDictionaryManagerDelegate <NSObject>
- (void)fileExtensionsDictionaryManager:(WCLExtensionToFileExtensionDictionaryManager *)fileExtensionDictionaryManager
                    didAddFileExtension:(WCLFileExtension *)fileExtension;
- (void)fileExtensionsDictionaryManager:(WCLExtensionToFileExtensionDictionaryManager *)fileExtensionDictionaryManager
                    didRemoveFileExtension:(WCLFileExtension *)fileExtension;
@end

#pragma mark - WCLExtensionToFileExtensionDictionaryManager

@interface WCLExtensionToFileExtensionDictionaryManager : NSObject
@property (nonatomic, weak) id <WCLExtensionToFileExtensionDictionaryManagerDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableDictionary *extensionToFileExtensionDictionary;
- (NSArray *)extensions;
- (NSArray *)fileExtensions;
@end

@implementation WCLExtensionToFileExtensionDictionaryManager

@synthesize extensionToFileExtensionDictionary = _extensionToFileExtensionDictionary;

- (void)addPlugin:(WCLPlugin *)plugin forExtension:(NSString *)extension
{
    WCLFileExtension *fileExtension = self.extensionToFileExtensionDictionary[extension];

    if (!fileExtension) {
        fileExtension = [[WCLFileExtension alloc] initWithExtension:extension];
        self.extensionToFileExtensionDictionary[extension] = fileExtension;

        if ([self.delegate respondsToSelector:@selector(fileExtensionsDictionaryManager:didAddFileExtension:)]) {
            [self.delegate fileExtensionsDictionaryManager:self didAddFileExtension:fileExtension];
        }
    }

    [fileExtension.plugins addObject:plugin];
}

- (void)removePlugin:(WCLPlugin *)plugin forExtension:(NSString *)extension
{
    WCLFileExtension *fileExtension = self.extensionToFileExtensionDictionary[extension];

    [fileExtension.plugins removeObject:plugin];

    if (![fileExtension.plugins count]) {
        [self.extensionToFileExtensionDictionary removeObjectForKey:extension];
        
        if ([self.delegate respondsToSelector:@selector(fileExtensionsDictionaryManager:didRemoveFileExtension:)]) {
            [self.delegate fileExtensionsDictionaryManager:self didRemoveFileExtension:fileExtension];
        }
    }
}

- (NSArray *)extensions
{
    return [self.extensionToFileExtensionDictionary allKeys];
}

- (NSArray *)fileExtensions
{
    return [self.extensionToFileExtensionDictionary allValues];
}

#pragma mark - Properties

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

@interface WCLFileExtensionController () <WCLExtensionToFileExtensionDictionaryManagerDelegate>
@property (nonatomic, strong) WCLExtensionToFileExtensionDictionaryManager *fileExtensionsDictionaryManager;
@property (nonatomic, strong) NSMutableArray *mutableFileExtensions;
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
            [self processRemovedPlugin:plugin];
        }
    }
}

- (WCLPluginManagerController *)pluginManagerController
{
    return [WCLPluginManagerController sharedPluginManagerController];
}

- (NSArray *)extensions
{
    return [self.fileExtensionsDictionaryManager extensions];
}

#pragma mark Properties

- (WCLExtensionToFileExtensionDictionaryManager *)fileExtensionsDictionaryManager
{
    if (_fileExtensionsDictionaryManager) {
        return _fileExtensionsDictionaryManager;
    }

    _fileExtensionsDictionaryManager = [[WCLExtensionToFileExtensionDictionaryManager alloc] init];

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

- (void)fileExtensionsDictionaryManager:(WCLExtensionToFileExtensionDictionaryManager *)fileExtensionDictionaryManager
                    didAddFileExtension:(WCLFileExtension *)fileExtension
{
    [self insertObject:fileExtension inFileExtensionsAtIndex:0];
}

- (void)fileExtensionsDictionaryManager:(WCLExtensionToFileExtensionDictionaryManager *)fileExtensionDictionaryManager
                 didRemoveFileExtension:(WCLFileExtension *)fileExtension
{
    NSUInteger index = [self.mutableFileExtensions indexOfObject:fileExtension];
    [self removeObjectFromFileExtensionsAtIndex:index];
}


#pragma mark Required Key-Value Coding To-Many Relationship Compliance for fileExtensions

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
        [keyPath isEqualToString:WCLPluginExtensionsKey]) {
        WCLPlugin *plugin = (WCLPlugin *)object;
        
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
        
        [self processExtensionChangesForPlugin:(WCLPlugin *)plugin
                                fromExtensions:oldExtensions
                                  toExtensions:newExtensions];
        return;
    }
}

- (void)processExtensionChangesForPlugin:(WCLPlugin *)plugin
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

- (void)processAddedPlugin:(WCLPlugin *)plugin
{
    NSArray *extensions = plugin.extensions;

    for (NSString *extension in extensions) {
        [self.fileExtensionsDictionaryManager addPlugin:plugin forExtension:extension];
    }

    [plugin addObserver:self
             forKeyPath:WCLPluginExtensionsKey
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                context:&WCLFileExtensionControllerContext];
}

- (void)processRemovedPlugin:(WCLPlugin *)plugin
{
    NSArray *extensions = plugin.extensions;
    
    for (NSString *extension in extensions) {
        [self.fileExtensionsDictionaryManager removePlugin:plugin forExtension:extension];
    }
    
    [plugin removeObserver:self
                forKeyPath:WCLPluginExtensionsKey
                   context:&WCLFileExtensionControllerContext];
}

@end
