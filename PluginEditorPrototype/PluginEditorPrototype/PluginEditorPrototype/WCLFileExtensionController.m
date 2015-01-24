//
//  WCLFileExtensionController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/11/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLFileExtensionController.h"

#import "WCLFileExtension.h"
#import "PluginEditorPrototype-Swift.h"

#define kPluginManagerControllerPluginsKeyPath @"plugins"
#define kPluginExtensionsKey @"extensions"

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
- (WCLFileExtension *)fileExtensionForExtension:(NSString *)extension;
@end

@implementation WCLExtensionToFileExtensionDictionaryManager

@synthesize extensionToFileExtensionDictionary = _extensionToFileExtensionDictionary;

- (void)addPlugin:(Plugin *)plugin forExtension:(NSString *)extension
{    
    WCLFileExtension *fileExtension = self.extensionToFileExtensionDictionary[extension];

    if (!fileExtension) {
        fileExtension = [[WCLFileExtension alloc] initWithExtension:extension];
        self.extensionToFileExtensionDictionary[extension] = fileExtension;

        if ([self.delegate respondsToSelector:@selector(fileExtensionsDictionaryManager:didAddFileExtension:)]) {
            [self.delegate fileExtensionsDictionaryManager:self didAddFileExtension:fileExtension];
        }
    }

    [fileExtension insertObject:plugin inPluginsAtIndex:0];
}

- (void)removePlugin:(Plugin *)plugin forExtension:(NSString *)extension
{
    WCLFileExtension *fileExtension = self.extensionToFileExtensionDictionary[extension];

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

- (WCLFileExtension *)fileExtensionForExtension:(NSString *)extension
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
        NSArray *plugins = [[PluginsManager sharedInstance] plugins];
        [[PluginsManager sharedInstance] removeObserver:self
                                                 forKeyPath:kPluginManagerControllerPluginsKeyPath
                                                    context:&WCLFileExtensionControllerContext];
        for (Plugin *plugin in plugins) {
            [self processRemovedPlugin:plugin];
        }
    }
}

- (NSArray *)extensions
{
    return [self.fileExtensionsDictionaryManager extensions];
}

- (WCLFileExtension *)fileExtensionForExtension:(NSString *)extension
{
    return [self.fileExtensionsDictionaryManager fileExtensionForExtension:extension];
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


#pragma mark Properties

- (WCLExtensionToFileExtensionDictionaryManager *)fileExtensionsDictionaryManager
{
    if (_fileExtensionsDictionaryManager) {
        return _fileExtensionsDictionaryManager;
    }
    
    _fileExtensionsDictionaryManager = [[WCLExtensionToFileExtensionDictionaryManager alloc] init];
    
    NSArray *plugins = [[PluginsManager sharedInstance] plugins];
    
    for (Plugin *plugin in plugins) {
        [self processAddedPlugin:plugin];
    }
    
    [[PluginsManager sharedInstance] addObserver:self
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
    if (context != &WCLFileExtensionControllerContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if ([object isKindOfClass:[[PluginsManager sharedInstance] class]] &&
        [keyPath isEqualToString:kPluginManagerControllerPluginsKeyPath]) {
        
        NSKeyValueChange keyValueChange = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
        switch (keyValueChange) {
            case NSKeyValueChangeInsertion: {
                NSArray *plugins = change[NSKeyValueChangeNewKey];
                for (Plugin *plugin in plugins) {
                    [self processAddedPlugin:plugin];
                }
                break;
            }
            case NSKeyValueChangeRemoval: {
                NSArray *plugins = change[NSKeyValueChangeOldKey];
                for (Plugin *plugin in plugins) {
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

    if ([object isKindOfClass:[Plugin class]] &&
        [keyPath isEqualToString:kPluginExtensionsKey]) {

        Plugin *plugin = (Plugin *)object;

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
        
        [self processExtensionChangesForPlugin:(Plugin *)plugin
                                fromExtensions:oldExtensions
                                  toExtensions:newExtensions];
        return;
    }
}

- (void)processExtensionChangesForPlugin:(Plugin *)plugin
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

- (void)processAddedPlugin:(Plugin *)plugin
{
    NSArray *extensions = plugin.extensions;

    for (NSString *extension in extensions) {
        [self.fileExtensionsDictionaryManager addPlugin:plugin forExtension:extension];
    }

    [plugin addObserver:self
             forKeyPath:kPluginExtensionsKey
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                context:&WCLFileExtensionControllerContext];
}

- (void)processRemovedPlugin:(Plugin *)plugin
{
    NSArray *extensions = plugin.extensions;
    
    for (NSString *extension in extensions) {
        [self.fileExtensionsDictionaryManager removePlugin:plugin forExtension:extension];
    }
    
    [plugin removeObserver:self
                forKeyPath:kPluginExtensionsKey
                   context:&WCLFileExtensionControllerContext];
}

@end
