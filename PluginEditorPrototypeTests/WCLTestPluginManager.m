//
//  WCLTestPluginManager.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLTestPluginManager.h"

#import "WCLPluginDataController.h"


#pragma mark - WCLTestPluginDataController

@interface WCLTestPluginDataController : WCLPluginDataController
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@interface WCLTestPluginDataController (Tests)
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end



#pragma mark - WCLTestPluginDataController

@implementation WCLTestPluginDataController

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

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

@end


#pragma mark - WCLTestFileExtensionController

@implementation WCLTestFileExtensionController

- (WCLTestPluginManagerController *)pluginManagerController
{
    return [WCLTestPluginManagerController sharedPluginManagerController];
}

@end


#pragma mark - WCLTestPluginManagerController

@implementation WCLTestPluginManagerController

- (WCLPluginManager *)pluginManager
{
    return [WCLTestPluginManager sharedPluginManager];
}

@end


#pragma mark - WCLTestPluginManager

@implementation WCLTestPluginManager

@end
