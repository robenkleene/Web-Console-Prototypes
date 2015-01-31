
//
//  WCLPluginViewController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginViewController.h"
#import "PluginEditorPrototype-Swift.h"


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
    return [Plugin nameContainsOnlyValidCharacters:partialString];
}

@end


#pragma mark - WCLPluginArrayController

@interface WCLPluginArrayController : NSArrayController
@property (nonatomic, weak) id delegate;
@end

@implementation WCLPluginArrayController

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Plugins"];
    }
    return self;
}

- (BOOL)becomeFirstResponder
{
    [[self.view window] makeFirstResponder:self.tableView];
    return YES;
}

#pragma mark IBActions

- (IBAction)addPlugin:(id)sender
{
    [[PluginsManager sharedInstance] newPlugin:nil];
    
    // TODO: Select the added plugin?
    // Simple re-implement of NSDictionaryController add because using the add: method waits for the next run loop before updating the table view.
//    [self.tableView editColumn:0 row:[self.tableView selectedRow] withEvent:nil select:YES];
}

- (IBAction)duplicatePlugin:(id)sender
{
    NSArray *plugins = [self.pluginArrayController selectedObjects];

    for (Plugin *plugin in plugins) {
        [[PluginsManager sharedInstance] newPluginFromPlugin:plugin handler:nil];
    }

    [self.tableView editColumn:0 row:[self.tableView selectedRow] withEvent:nil select:YES];
}

- (IBAction)makeDefaultPlugin:(id)sender
{
    NSArray *plugins = [self.pluginArrayController selectedObjects];
    for (Plugin *plugin in plugins) {
        [[PluginsManager sharedInstance] setDefaultNewPlugin:plugin];
    }
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

    NSArray *plugins = [self.pluginArrayController selectedObjects];

    for (Plugin *plugin in plugins) {
        [[PluginsManager sharedInstance] movePluginToTrash:plugin];
    }
}

#pragma mark NSTokenFieldDelegate

- (NSArray *)tokenField:(NSTokenField *)tokenField
completionsForSubstring:(NSString *)substring
           indexOfToken:(NSInteger)tokenIndex
    indexOfSelectedItem:(NSInteger *)selectedIndex
{
    NSArray *suffixes = [[FileExtensionsController sharedInstance] suffixes];
    NSArray *matchingSuffixes = [suffixes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@", substring]];
    return matchingSuffixes;
}


- (NSArray *)tokenField:(NSTokenField *)tokenField
       shouldAddObjects:(NSArray *)tokens
                atIndex:(NSUInteger)index
{
    NSArray *validExtensions = [Plugin validExtensionsFromExtensions:tokens];
    
    return validExtensions;
}

#pragma mark Properties

- (WCLPluginArrayController *)pluginArrayController
{
    return _pluginArrayController;
}

- (void)setPluginArrayController:(WCLPluginArrayController *)pluginArrayController
{
    if (_pluginArrayController == pluginArrayController) {
        return;
    }

// TODO: Set these keys
//  NSConditionallySetsEditableBindingOption: yes
//  NSRaisesForNotApplicableKeysBindingOption : @YES
    
    [pluginArrayController bind:@"contentArray" toObject:[PluginsManager sharedInstance] withKeyPath:@"plugins" options:nil];
    
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:kPluginNameKey
                                                                       ascending:YES
                                                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
    [pluginArrayController setSortDescriptors:sortDescriptors];
    _pluginArrayController = pluginArrayController;
}

@end
