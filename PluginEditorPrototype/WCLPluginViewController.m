
//
//  WCLPluginViewController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginViewController.h"
#import "WCLPluginManager.h"

#import "WCLPlugin+Validation.h"
#import "WCLPlugin.h"

#import "WCLFileExtensionController.h"

#pragma mark - WCLPluginNameTextField

@interface WCLPluginNameTextField : NSTextField
@end

@implementation WCLPluginNameTextField

- (void)mouseDown:(NSEvent *)theEvent {
    // Intercept the mouse down event so the whole text field contents becomes selected instead of inserting a cursor.
}

@end


#pragma mark - WCLPluginNameFormatter

@interface WCLPluginNameFormatter : NSFormatter
@end

@implementation WCLPluginNameFormatter

- (NSString *)stringForObjectValue:(id)obj
{
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    
    return nil;
}

- (BOOL)getObjectValue:(out __autoreleasing id *)obj
             forString:(NSString *)string
      errorDescription:(out NSString *__autoreleasing *)error
{
    *obj = string;
    
    return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partialString
            newEditingString:(NSString *__autoreleasing *)newString
            errorDescription:(NSString *__autoreleasing *)error
{
    return [WCLPlugin nameContainsOnlyValidCharacters:partialString];
}

@end


#pragma mark - WCLPluginArrayController

@interface WCLPluginArrayController : NSArrayController
@property (nonatomic, weak) id delegate;
@end

@implementation WCLPluginArrayController

- (id)newObject
{
    return [[WCLPluginManager sharedPluginManager] newPlugin];
}

- (void)rearrangeObjects
{
    NSArray *selectedObjects = [self selectedObjects];
    [super rearrangeObjects];
    [self setSelectedObjects:selectedObjects];
}

@end


#pragma mark - WCLPluginViewController

@interface WCLPluginViewController () <NSTableViewDelegate, NSTokenFieldDelegate>
@property (weak) IBOutlet WCLPluginArrayController *pluginArrayController;
@property (weak) IBOutlet NSTableView *tableView;
- (IBAction)addPlugin:(id)sender;
- (IBAction)removePlugin:(id)sender;
@end

@implementation WCLPluginViewController

@synthesize pluginArrayController = _pluginArrayController;

- (IBAction)addPlugin:(id)sender
{
    id newObject = [self.pluginArrayController newObject];
    [self.pluginArrayController addObject:newObject];

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
    NSString *pluginName = [[self.pluginArrayController selection] valueForKey:WCLPluginNameKey];
    
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

    NSArray *plugins = [self.pluginArrayController selectedObjects];
    
    [self.pluginArrayController remove:nil];

    for (WCLPlugin *plugin in plugins) {
        [[WCLPluginManager sharedPluginManager] deletePlugin:plugin];
    }
}


#pragma mark NSTokenFieldDelegate

- (NSArray *)tokenField:(NSTokenField *)tokenField
completionsForSubstring:(NSString *)substring
           indexOfToken:(NSInteger)tokenIndex
    indexOfSelectedItem:(NSInteger *)selectedIndex
{
    NSArray *fileExtensions = [[WCLFileExtensionController sharedFileExtensionController] fileExtensions];
    NSArray *matchingFileExtensions = [fileExtensions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@", substring]];
    return matchingFileExtensions;
}


- (NSArray *)tokenField:(NSTokenField *)tokenField
       shouldAddObjects:(NSArray *)tokens
                atIndex:(NSUInteger)index
{
    NSArray *validFileExtensions = [WCLPlugin validFileExtensionsFromFileExtensions:tokens];
    
    return validFileExtensions;
}

#pragma mark Properties

- (WCLPluginArrayController *)pluginArrayController
{
    return _pluginArrayController;
}

- (void)setPluginArrayController:(WCLPluginArrayController *)pluginArrayController
{
    if (_pluginArrayController == pluginArrayController) return;

    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:WCLPluginNameKey
                                                                       ascending:YES
                                                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
    [pluginArrayController setSortDescriptors:sortDescriptors];
    _pluginArrayController = pluginArrayController;
}

@end
