//
//  WCLTestPluginManager.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLTestPluginManager.h"

#import "WCLPluginDataController.h"
#import "WCLPlugin+Validation.h"


#define kTestPluginModelName @"WCLTestPluginPrototype"
#define kTestPluginEntityName @"WCLTestPlugin"


#pragma mark - WCLTestPlugin

@implementation WCLTestPlugin

- (WCLTestPluginManager *)pluginManager
{
    return [WCLTestPluginManager sharedPluginManager];
}

@end


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


- (WCLTestPlugin *)newPlugin
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTestPluginEntityName
                                              inManagedObjectContext:self.managedObjectContext];
    WCLTestPlugin *plugin = [[WCLTestPlugin alloc] initWithEntity:entity
                                   insertIntoManagedObjectContext:self.managedObjectContext];
    [plugin renameWithUniqueName];
    plugin.identifier = [[NSUUID UUID] UUIDString];
    
    NSError *error;
    NSLog(@"saving after adding plugin %@", plugin);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving.");
    }
    
    // Adding the plugin to the dictionary must happen after saving, otherwise name validation will fail
    // because this plugin in the dictionary will cause the name to no longer be unique.
    
    return plugin;
}

- (void)deletePlugin:(WCLPlugin *)plugin
{
    [self.managedObjectContext deleteObject:plugin];
    
    NSError *error;
    NSLog(@"saving after removing plugin %@", plugin);
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


#pragma mark - WCLTestPluginManagerController

@implementation WCLTestPluginManagerController

- (WCLPluginManager *)pluginManager
{
    return [WCLTestPluginManager sharedPluginManager];
}

@end


#pragma mark - WCLTestFileExtensionController

@implementation WCLTestFileExtensionController

- (WCLTestPluginManagerController *)pluginManagerController
{
    return [WCLTestPluginManagerController sharedPluginManagerController];
}

@end


#pragma mark - WCLTestPluginManager

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
