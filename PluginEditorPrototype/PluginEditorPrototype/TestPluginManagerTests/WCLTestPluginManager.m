//
//  WCLTestPluginManager.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLTestPluginManager.h"

#import "WCLPluginDataController.h"

#import "WCLTestPlugin.h"

#import <objc/runtime.h>


#define kTestPluginModelName @"WCLTestPluginPrototype"
#define kTestPluginEntityName @"WCLTestPlugin"


#pragma mark - WCLTestPluginDataController

@interface WCLTestPluginDataController : NSObject
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation WCLTestPluginDataController

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;


- (WCLPlugin_old *)newPlugin
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTestPluginEntityName
                                              inManagedObjectContext:self.managedObjectContext];
    WCLTestPlugin *plugin = [[WCLTestPlugin alloc] initWithEntity:entity
                                   insertIntoManagedObjectContext:self.managedObjectContext];

    plugin.identifier = [[NSUUID UUID] UUIDString];
    [plugin renameWithUniqueName];

    
    NSError *error;
//    NSLog(@"saving after adding plugin %@", plugin);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving.");
    }
    
    return (WCLPlugin_old *)plugin;
}

- (WCLPlugin_old *)newPluginFromPlugin:(WCLTestPlugin *)plugin
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTestPluginEntityName
                                              inManagedObjectContext:self.managedObjectContext];
    WCLTestPlugin *newPlugin = [[WCLTestPlugin alloc] initWithEntity:entity
                                      insertIntoManagedObjectContext:self.managedObjectContext];
    
    newPlugin.command = plugin.command;
    newPlugin.extensions = plugin.extensions;

    newPlugin.identifier = [[NSUUID UUID] UUIDString];
    newPlugin.name = [newPlugin uniquePluginNameFromName:plugin.name];


    NSError *error;
//    NSLog(@"saving after adding plugin %@", plugin);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving.");
    }
    
    return (WCLPlugin_old *)newPlugin;
}

- (void)deletePlugin:(WCLTestPlugin *)plugin
{
    [self.managedObjectContext deleteObject:plugin];
    
    NSError *error;
//    NSLog(@"saving after removing plugin %@", plugin);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving.");
    }
}

- (NSArray *)existingPlugins
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTestPluginEntityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *plugins = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSAssert(!error, @"Error executing fetch request. %@ %@", fetchRequest, error);
    
    return plugins;
}

#pragma mark Core Data

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:kTestPluginModelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSError *error = nil;
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

@end


#pragma mark - WCLPluginManager

void WCLSwizzleClassMethod(Class class,
                           SEL originalSelector,
                           SEL overrideSelector)
{
    
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method overrideMethod = class_getClassMethod(class, overrideSelector);
    
    class = object_getClass((id)class);
    
    if(class_addMethod(class, originalSelector,
                       method_getImplementation(overrideMethod),
                       method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(class, overrideSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, overrideMethod);
    }
}


@interface WCLPluginManager_old (TestPluginManager)
@end


@implementation WCLPluginManager_old (TestPluginManager)

+ (instancetype)overrideSharedPluginManager
{
    static dispatch_once_t pred;
    static WCLTestPluginManager *pluginManager = nil;
    
    dispatch_once(&pred, ^{
        pluginManager = [[WCLTestPluginManager alloc] init];
    });
    
    return pluginManager;
}

+ (void)load
{
    WCLSwizzleClassMethod([WCLPluginManager_old class],
                          @selector(sharedPluginManager),
                          @selector(overrideSharedPluginManager));
}

@end


#pragma mark - WCLTestPluginManager

@interface WCLTestPluginManager ()
@property (nonatomic, strong, readonly) WCLTestPluginDataController *pluginDataController;
@end

@implementation WCLTestPluginManager

@synthesize pluginDataController = _pluginDataController;

- (WCLTestPluginDataController *)pluginDataController
{
    if (_pluginDataController) {
        return _pluginDataController;
    }
    
    _pluginDataController = [[WCLTestPluginDataController alloc] init];
    
    return _pluginDataController;
}


@end
