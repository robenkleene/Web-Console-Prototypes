//
//  WCLFileExtensionController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/11/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLFileExtensionsController.h"

#import "WCLFileExtension.h"
#import "PluginEditorPrototype-Swift.h"


#define kPluginSuffixesKey @"suffixes"

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
@property (nonatomic, strong, readonly) NSMutableDictionary *suffixToFileExtensionDictionary;
- (NSArray *)suffixes;
- (NSArray *)fileExtensions;
- (WCLFileExtension *)fileExtensionForSuffix:(NSString *)extension;
@end

@implementation WCLExtensionToFileExtensionDictionaryManager

@synthesize suffixToFileExtensionDictionary = _suffixToFileExtensionDictionary;

- (void)addPlugin:(Plugin *)plugin forSuffix:(NSString *)suffix
{    
    WCLFileExtension *fileExtension = self.suffixToFileExtensionDictionary[suffix];

    if (!fileExtension) {
        fileExtension = [[WCLFileExtension alloc] initWithSuffix:suffix];
        self.suffixToFileExtensionDictionary[suffix] = fileExtension;

        if ([self.delegate respondsToSelector:@selector(fileExtensionsDictionaryManager:didAddFileExtension:)]) {
            [self.delegate fileExtensionsDictionaryManager:self didAddFileExtension:fileExtension];
        }
    }

    [fileExtension insertObject:plugin inPluginsAtIndex:0];
}

- (void)removePlugin:(Plugin *)plugin forSuffix:(NSString *)extension
{
    WCLFileExtension *fileExtension = self.suffixToFileExtensionDictionary[extension];

    NSAssert(fileExtension, @"Attempted to remove a plugin for a file extension that does not exist.");
    
    NSUInteger index = [fileExtension.plugins indexOfObject:plugin];
    NSAssert(index != NSNotFound, @"Attempted to remove a plugin from a file extension's plugins that was not found.");
    
    [fileExtension removeObjectFromPluginsAtIndex:index];

    if (![fileExtension.plugins count]) {
        [self.suffixToFileExtensionDictionary removeObjectForKey:extension];
        
        if ([self.delegate respondsToSelector:@selector(fileExtensionsDictionaryManager:didRemoveFileExtension:)]) {
            [self.delegate fileExtensionsDictionaryManager:self didRemoveFileExtension:fileExtension];
        }
    }
}

- (WCLFileExtension *)fileExtensionForSuffix:(NSString *)extension
{
    return self.suffixToFileExtensionDictionary[extension];
}

- (NSArray *)suffixes
{
    return [self.suffixToFileExtensionDictionary allKeys];
}

- (NSArray *)fileExtensions
{
    return [self.suffixToFileExtensionDictionary allValues];
}

#pragma mark Properties

- (NSMutableDictionary *)suffixToFileExtensionDictionary
{
    if (_suffixToFileExtensionDictionary) {
        return _suffixToFileExtensionDictionary;
    }

    _suffixToFileExtensionDictionary = [NSMutableDictionary dictionary];
    
    return _suffixToFileExtensionDictionary;
}

@end


#pragma mark - WCLFileExtensionController

@interface WCLFileExtensionsController () <WCLExtensionToFileExtensionDictionaryManagerDelegate>
@property (nonatomic, strong) WCLExtensionToFileExtensionDictionaryManager *fileExtensionsDictionaryManager;
@property (nonatomic, strong) NSMutableArray *mutableFileExtensions;
@end

@implementation WCLFileExtensionsController

static void *WCLFileExtensionControllerContext;

@synthesize fileExtensionsDictionaryManager = _fileExtensionsDictionaryManager;

- (instancetype)initWithPluginsManager:(PluginsManager *)pluginsManager
{
    self = [super init];
    if (self) {
        _pluginsManager = pluginsManager;
    }
    return self;
}

- (void)dealloc
{
    if (_fileExtensionsDictionaryManager) {
        NSArray *plugins = [self.pluginsManager plugins];
        [self.pluginsManager removeObserver:self
                                   forKeyPath:kPluginsManagerPluginsKeyPath
                                      context:&WCLFileExtensionControllerContext];
        for (Plugin *plugin in plugins) {
            [self processRemovedPlugin:plugin];
        }
    }
}

- (NSArray *)suffixes
{
    return [self.fileExtensionsDictionaryManager suffixes];
}

- (WCLFileExtension *)fileExtensionForSuffix:(NSString *)suffix
{
    return [self.fileExtensionsDictionaryManager fileExtensionForSuffix:suffix];
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
    
    NSArray *plugins = [self.pluginsManager plugins];
    
    for (Plugin *plugin in plugins) {
        [self processAddedPlugin:plugin];
    }

    [self.pluginsManager addObserver:self
                            forKeyPath:kPluginsManagerPluginsKeyPath
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
    
    if ([object isKindOfClass:[self.pluginsManager class]] &&
        [keyPath isEqualToString:kPluginsManagerPluginsKeyPath]) {
        
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

    // TODO: Removing the `isKindOfClass` test because of the conflict created between the swift `Plugin` class being added to test targets
    // This means the `isKindOfClass` test fails because there are really two compiled `Plugin` classes one for each target
//    if ([object isKindOfClass:[Plugin class]] &&
//        [keyPath isEqualToString:kPluginSuffixesKey]) {
    if ([keyPath isEqualToString:kPluginSuffixesKey]) {

    
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
        [self.fileExtensionsDictionaryManager addPlugin:plugin forSuffix:extension];
    }

    // Old file extensions minus new file extensions are removed file extensions.
    NSMutableSet *removedExtensionsSet = [oldExtensionsSet mutableCopy];
    [removedExtensionsSet minusSet:newExtensionsSet];
    for (NSString *extension in removedExtensionsSet) {
        [self.fileExtensionsDictionaryManager removePlugin:plugin forSuffix:extension];
    }
}

- (void)processAddedPlugin:(Plugin *)plugin
{
    NSArray *suffixes = plugin.suffixes;

    for (NSString *fileSuffix in suffixes) {
        [self.fileExtensionsDictionaryManager addPlugin:plugin forSuffix:fileSuffix];
    }

    [plugin addObserver:self
             forKeyPath:kPluginSuffixesKey
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                context:&WCLFileExtensionControllerContext];
}

- (void)processRemovedPlugin:(Plugin *)plugin
{
    NSArray *suffixes = plugin.suffixes;
    
    for (NSString *fileSuffix in suffixes) {
        [self.fileExtensionsDictionaryManager removePlugin:plugin forSuffix:fileSuffix];
    }
    
    [plugin removeObserver:self
                forKeyPath:kPluginSuffixesKey
                   context:&WCLFileExtensionControllerContext];
}

@end
