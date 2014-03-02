//
//  WCLPluginViewController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginViewController.h"

#define kArrayControllerSelectionKeyPath @"selection"

@interface WCLPluginViewController ()
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak) IBOutlet NSArrayController *arrayController;
@property (weak) IBOutlet NSTableView *tableView;
- (IBAction)saveAction:(id)sender;
@end



@implementation WCLPluginViewController

static void *WCLPluginViewControllerContext;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;


@synthesize arrayController = _arrayController;

- (IBAction)addPlugin:(id)sender
{
    id newObject = [self.arrayController newObject];
    [self.arrayController addObject:newObject];
    // Simple re-implement of NSDictionaryController add because using the add: method doesn't set the table view's selection right away.

    [self.tableView editColumn:0 row:[self.tableView selectedRow] withEvent:nil select:YES];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &WCLPluginViewControllerContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if ([keyPath isEqualToString:kArrayControllerSelectionKeyPath]) {
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];

        NSLog(@"oldValue = %@", oldValue);
        NSLog(@"newValue = %@", newValue);

        NSLog(@"observeValueForKeyPath: [self.arrayController selectedObjects]  = %@", [self.arrayController selectedObjects]);
    }
}

- (NSArrayController *)arrayController
{
    return _arrayController;
}

- (void)setArrayController:(NSArrayController *)arrayController
{
    if (_arrayController != arrayController) {
        _arrayController = arrayController;
        [_arrayController addObserver:self forKeyPath:kArrayControllerSelectionKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&WCLPluginViewControllerContext];
    }
}

- (void)dealloc
{
    if (_arrayController) {
        [_arrayController removeObserver:self forKeyPath:kArrayControllerSelectionKeyPath context:&WCLPluginViewControllerContext];
    }
}

#warning Code for save confirmation
//-(void)remove:(id)sender {
//    NSAlert *alert = [[NSAlert alloc] init];
//    [alert addButtonWithTitle:@"Delete"];
//    [alert addButtonWithTitle:@"Cancel"];
//    [alert setMessageText:@"Do you really want to delete this scary bug?"];
//    [alert setInformativeText:@"Deleting a scary bug cannot be undone."];
//    [alert setAlertStyle:NSWarningAlertStyle];
//    [alert setDelegate:self];
//    [alert respondsToSelector:@selector(doRemove)];
//    [alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
//}
//
//-(void)alertDidEnd:(NSAlert*)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
//    if (returnCode ==  NSAlertFirstButtonReturn) {
//        // We want to remove the saved image along with the bug
//        Bug *bug = [[self selectedObjects] objectAtIndex:0];
//        NSString *name = [bug valueForKey:@"name"];
//        if (!([name isEqualToString:@"Centipede"] || [name isEqualToString:@"Potato Bug"] || [name isEqualToString:@"Wolf Spider"] || [name isEqualToString:@"Lady Bug"])) {
//            NSError *error = nil;
//            NSFileManager *manager = [[NSFileManager alloc] init];
//            [manager removeItemAtURL:[NSURL URLWithString:bug.imagePath] error:&error];
//            
//        }
//        [super remove:self];
//    }
//}


#pragma mark - Core Data Stack

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

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
