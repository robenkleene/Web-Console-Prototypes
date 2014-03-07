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
#define kPluginNameKey @"name"

@implementation WCLPluginNameTextField
- (void)mouseDown:(NSEvent *)theEvent {
    // Intercept the mouse down event so the whole text field contents becomes selected instead of inserting a cursor.
}
@end


@interface WCLPluginArrayController : NSArrayController
@end

@implementation WCLPluginArrayController
- (id)newObject
{
    return [[WCLPluginManager sharedPluginManager] newPlugin];
}
@end


@interface WCLPluginViewController ()
@property (weak) IBOutlet WCLPluginArrayController *pluginArrayController;
@property (weak) IBOutlet NSTableView *tableView;
@end

@implementation WCLPluginViewController

@synthesize pluginArrayController = _pluginArrayController;

- (IBAction)addPlugin:(id)sender
{
    id newObject = [self.pluginArrayController newObject];
    [self.pluginArrayController addObject:newObject];
    [self.pluginArrayController rearrangeObjects];

    // Simple re-implement of NSDictionaryController add because using the add: method waits for the next run loop before updating the table view.
    [self.tableView editColumn:0 row:[self.tableView selectedRow] withEvent:nil select:YES];
}

- (BOOL)becomeFirstResponder
{
    [[self.view window] makeFirstResponder:self.tableView];
    return YES;
}


- (IBAction)removePlugin:(id)sender
{
    NSString *pluginName = [[self.pluginArrayController selection] valueForKey:kPluginNameKey];
    
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

    [self.pluginArrayController remove:nil];
}

#pragma mark - Properties

- (WCLPluginArrayController *)pluginArrayController
{
    return _pluginArrayController;
}

- (void)setPluginArrayController:(WCLPluginArrayController *)pluginArrayController
{
    if (_pluginArrayController == pluginArrayController) return;
    
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:kPluginNameKey
                                                                       ascending:YES
                                                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
    [pluginArrayController setSortDescriptors:sortDescriptors];
    _pluginArrayController = pluginArrayController;
}
@end
