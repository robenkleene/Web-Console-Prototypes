//
//  WCLPluginViewController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginViewController.h"
#import "WCLPluginManager.h"

@interface WCLPluginNameTextField : NSTextField
@end

#warning Move this somewhere where it's accessible to whole app
#define kAppName (NSString *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]
#define kPlugInExtension @"wcplugin"
#define kPluginSelectionNameKey @"name"

@implementation WCLPluginNameTextField
- (void)mouseDown:(NSEvent *)theEvent {
    // Intercept the mouse down event so the whole text field contents becomes selected instead of inserting a cursor.
}
@end

@interface WCLPluginViewController ()
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak) IBOutlet NSArrayController *arrayController;
@property (weak) IBOutlet NSTableView *tableView;

@end

@implementation WCLPluginViewController

@synthesize arrayController = _arrayController;

- (NSManagedObjectContext *)managedObjectContext
{
    return [[WCLPluginManager sharedPluginManager] managedObjectContext];
}

- (IBAction)addPlugin:(id)sender
{
    id newObject = [self.arrayController newObject];
    [self.arrayController addObject:newObject];
    // Simple re-implement of NSDictionaryController add because using the add: method doesn't set the table view's selection right away.

    [self.tableView editColumn:0 row:[self.tableView selectedRow] withEvent:nil select:YES];

    NSError *error;
    NSLog(@"saving after adding plugin %@", newObject);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving.");
    }
}

- (BOOL)becomeFirstResponder
{
    [[self.view window] makeFirstResponder:self.tableView];
    return YES;
}


- (IBAction)removePlugin:(id)sender
{
    NSString *pluginName = [[self.arrayController selection] valueForKey:kPluginSelectionNameKey];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Move to Trash"];
    [alert addButtonWithTitle:@"Cancel"];
    NSString *messageText = [NSString stringWithFormat:@"Do you want to remove the plugin \"%@\" from %@ and move its files to the trash?", pluginName, kAppName];
    [alert setMessageText:messageText];
    NSString *informativeText = [NSString stringWithFormat:@"The \"%@.%@\" package will be moved to the trash and the plugin will be removed from %@. This action cannot be undone.", pluginName, kPlugInExtension, kAppName];
    [alert setInformativeText:informativeText];
    [alert beginSheetModalForWindow:self.view.window
                      modalDelegate:self
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo:NULL];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode != NSAlertFirstButtonReturn) return;

    [self.arrayController remove:nil];

    NSError *error;
    NSLog(@"saving after removing plugin %@", [self.arrayController selection]);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving.");
    }
}


@end
