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
@property (nonatomic, strong, readonly) NSMutableDictionary *fileExtensionToPluginsDictionary;
- (NSArray *)fileExtensions;
@end

@implementation WCLFileExtensionToPluginsDictionaryManager

@synthesize fileExtensionToPluginsDictionary = _fileExtensionToPluginsDictionary;

- (void)addPlugin:(WCLPlugin *)plugin forFileExtension:(NSString *)fileExtension
{
    NSMutableArray *plugins = self.fileExtensionToPluginsDictionary[fileExtension];
    if (plugins) {
        [plugins addObject:plugin];
#warning Is this necessary?
        self.fileExtensionToPluginsDictionary[fileExtension] = plugins;
    } else {
        self.fileExtensionToPluginsDictionary[fileExtension] = [NSMutableArray arrayWithObject:plugin];
        
        if ([self.delegate respondsToSelector:@selector(fileExtensionsDictionaryManager:didAddFileExtension:)]) {
            [self.delegate fileExtensionsDictionaryManager:self didAddFileExtension:fileExtension];
        }
    }
}

- (void)removePlugin:(WCLPlugin *)plugin forFileExtension:(NSString *)fileExtension
{
    NSMutableArray *plugins = self.fileExtensionToPluginsDictionary[fileExtension];

    [plugins removeObject:plugin];

    if ([plugins count]) {
#warning Is this necessary?
        self.fileExtensionToPluginsDictionary[fileExtension] = plugins;
    } else {
        [self.fileExtensionToPluginsDictionary removeObjectForKey:fileExtension];
        
        if ([self.delegate respondsToSelector:@selector(fileExtensionsDictionaryManager:didRemoveFileExtension:)]) {
            [self.delegate fileExtensionsDictionaryManager:self didRemoveFileExtension:fileExtension];
        }
    }
}

- (NSArray *)fileExtensions
{
    return [self.fileExtensionToPluginsDictionary allKeys];
}

- (NSMutableDictionary *)fileExtensionToPluginsDictionary
{
    if (_fileExtensionToPluginsDictionary) {
        return _fileExtensionToPluginsDictionary;
    }

    _fileExtensionToPluginsDictionary = [NSMutableDictionary dictionary];
    
    return _fileExtensionToPluginsDictionary;
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
        WCLPlugin *plugin = (WCLPlugin *)object;
        
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
        
        [self processFileExtensionChangesForPlugin:(WCLPlugin *)plugin
                                fromFileExtensions:oldFileExtensions
                                  toFileExtensions:newFileExtensions];
        return;
    }
}

- (void)processFileExtensionChangesForPlugin:(WCLPlugin *)plugin
                          fromFileExtensions:(NSArray *)oldFileExtensions
                            toFileExtensions:(NSArray *)newFileExtensions
{
    NSSet *oldFileExtensionsSet = [NSSet setWithArray:oldFileExtensions];
    NSSet *newFileExtensionsSet = [NSSet setWithArray:newFileExtensions];
    
    // New file extensions minus old file extensions are added file extensions.
    NSMutableSet *addedFileExtensionsSet = [newFileExtensionsSet mutableCopy];
    [addedFileExtensionsSet minusSet:oldFileExtensionsSet];
    for (NSString *fileExtension in addedFileExtensionsSet) {
        [self.fileExtensionsDictionaryManager addPlugin:plugin forFileExtension:fileExtension];
    }

    // Old file extensions minus new file extensions are removed file extensions.
    NSMutableSet *removedFileExtensionsSet = [oldFileExtensionsSet mutableCopy];
    [removedFileExtensionsSet minusSet:newFileExtensionsSet];
    for (NSString *fileExtension in removedFileExtensionsSet) {
        [self.fileExtensionsDictionaryManager removePlugin:plugin forFileExtension:fileExtension];
    }
}

- (void)processAddedPlugin:(WCLPlugin *)plugin
{
    NSArray *fileExtensions = plugin.fileExtensions;

    for (NSString *fileExtension in fileExtensions) {
        [self.fileExtensionsDictionaryManager addPlugin:plugin forFileExtension:fileExtension];
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
        [self.fileExtensionsDictionaryManager removePlugin:plugin forFileExtension:fileExtension];
    }
    
    [plugin removeObserver:self
                forKeyPath:WCLPluginFileExtensionsKey
                   context:&WCLFileExtensionControllerContext];
}

@end
