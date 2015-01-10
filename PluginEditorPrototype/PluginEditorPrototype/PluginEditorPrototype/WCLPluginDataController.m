//
//  WCLPluginDataController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginDataController.h"
#import "WCLPlugin+Validation.h"
#import "WCLPlugin.h"

@interface WCLPluginDataController ()
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation WCLPluginDataController

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (WCLPlugin *)newPlugin
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WCLPlugin" inManagedObjectContext:self.managedObjectContext];
    WCLPlugin *plugin = [[WCLPlugin alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];

    plugin.identifier = [[NSUUID UUID] UUIDString];
    [plugin renameWithUniqueName];

    NSError *error;
//    NSLog(@"saving after adding plugin %@", plugin);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving.");
    }
    
    return plugin;
}

- (WCLPlugin *)newPluginFromPlugin:(WCLPlugin *)plugin
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WCLPlugin" inManagedObjectContext:self.managedObjectContext];
    WCLPlugin *newPlugin = [[WCLPlugin alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    
    newPlugin.command = plugin.command;
    newPlugin.extensions = plugin.extensions;

    newPlugin.identifier = [[NSUUID UUID] UUIDString];
    newPlugin.name = [newPlugin uniquePluginNameFromName:plugin.name];
    

    NSError *error;
//    NSLog(@"saving after adding plugin %@", plugin);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving.");
    }
    
    return newPlugin;
}

- (void)deletePlugin:(WCLPlugin *)plugin
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WCLPlugin" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *plugins = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSAssert(!error, @"Error executing fetch request. %@ %@", fetchRequest, error);

    return plugins;
}

#pragma mark Core Data

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.1percenter.PluginEditorPrototype" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.1percenter.PluginEditorPrototype"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PluginEditorPrototype" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
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
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"PluginEditorPrototype.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
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
