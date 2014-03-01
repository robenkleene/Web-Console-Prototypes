//
//  AppDelegate.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLAppDelegate.h"

#import "WCLPreferencesWindowController.h"


@interface WCLAppDelegate ()
@property (nonatomic, strong) WCLPreferencesWindowController *preferencesWindowController;
- (IBAction)showPreferencesWindow:(id)sender;
@end


@implementation WCLAppDelegate

- (IBAction)showPreferencesWindow:(id)sender
{
    NSLog(@"showing %@", self.preferencesWindowController);
    [self.preferencesWindowController showWindow:self];
}

- (WCLPreferencesWindowController *)preferencesWindowController
{
    if (_preferencesWindowController) return _preferencesWindowController;
    
    self.preferencesWindowController = [[WCLPreferencesWindowController alloc] initWithWindowNibName:kPreferencesWindowControllerNibName];

    return _preferencesWindowController;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}



//// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
//- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
//{
//    return [[self managedObjectContext] undoManager];
//}


//- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
//{
//    // Save changes in the application's managed object context before the application terminates.
//    
//    if (!_managedObjectContext) {
//        return NSTerminateNow;
//    }
//    
//    if (![[self managedObjectContext] commitEditing]) {
//        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
//        return NSTerminateCancel;
//    }
//    
//    if (![[self managedObjectContext] hasChanges]) {
//        return NSTerminateNow;
//    }
//    
//    NSError *error = nil;
//    if (![[self managedObjectContext] save:&error]) {
//
//        // Customize this code block to include application-specific recovery steps.              
//        BOOL result = [sender presentError:error];
//        if (result) {
//            return NSTerminateCancel;
//        }
//
//        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
//        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
//        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
//        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
//        NSAlert *alert = [[NSAlert alloc] init];
//        [alert setMessageText:question];
//        [alert setInformativeText:info];
//        [alert addButtonWithTitle:quitButton];
//        [alert addButtonWithTitle:cancelButton];
//
//        NSInteger answer = [alert runModal];
//        
//        if (answer == NSAlertAlternateReturn) {
//            return NSTerminateCancel;
//        }
//    }
//
//    return NSTerminateNow;
//}

@end
