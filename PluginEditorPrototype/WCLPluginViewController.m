
//
//  WCLPluginViewController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginViewController.h"
#import "WCLPluginManager.h"

#warning Remove with swizzling
#import <objc/runtime.h>

#warning Move this somewhere where it's accessible to whole app
#define kAppName (NSString *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]
#define kPlugInExtension @"wcplugin"
#define kPluginNameKey @"name"

//@interface WCLTextFieldCell : NSTextFieldCell
//@end
//@implementation WCLTextFieldCell
//
//- (BOOL)resignFirstResponder
//{
//    NSLog(@"resign first responder");
//    return [super resignFirstResponder];
//}
//@end

@interface NSWindow (Swizzling)
@end


@implementation NSWindow (Swizzling)
- (BOOL)replacementMakeFirstResponder:(NSResponder *)responder
{
    NSLog(@"responder is %@", responder);
    return [self replacementMakeFirstResponder:responder];
}
+ (void)load {
    SEL originalSelector = @selector(makeFirstResponder:);
    SEL overrideSelector = @selector(replacementMakeFirstResponder:);
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method overrideMethod = class_getInstanceMethod(self, overrideSelector);
    if (class_addMethod(self, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(self, overrideSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, overrideMethod);
    }
}
@end


@class WCLPluginNameTextField;

@protocol WCLPluginNameTextFieldDelegate <NSTextFieldDelegate>
@optional
- (void)pluginNameTextFieldWillEndEditing:(WCLPluginNameTextField *)pluginNameTextField;
@end

@interface WCLPluginNameTextField : NSTextField
- (id <WCLPluginNameTextFieldDelegate>)delegate;
- (void)setDelegate:(id< NSTextFieldDelegate>)anObject;
@end

@implementation WCLPluginNameTextField
- (void)mouseDown:(NSEvent *)theEvent {
    // Intercept the mouse down event so the whole text field contents becomes selected instead of inserting a cursor.
}
- (id <WCLPluginNameTextFieldDelegate>)delegate
{
    return (id <WCLPluginNameTextFieldDelegate>)[super delegate];
}
- (void)setDelegate:(id <WCLPluginNameTextFieldDelegate>)anObject
{
    [super setDelegate:anObject];
}
- (BOOL)resignFirstResponder
{
    NSLog(@"resign first responder");
    return [super resignFirstResponder];
}
- (BOOL)textShouldEndEditing:(NSText *)textObject
{
    if ([self.delegate respondsToSelector:@selector(pluginNameTextFieldWillEndEditing:)]) {
        [self.delegate pluginNameTextFieldWillEndEditing:self];
    }
    return [super textShouldEndEditing:textObject];
}
@end


@class WCLPluginArrayController;
@protocol WCLPluginArrayControllerDelegate <NSObject>
@optional
- (void)pluginArrayControllerDidRearrangeObjects:(WCLPluginArrayController *)pluginArrayController;
@end

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
//    [super rearrangeObjects];
//    return;
    
    NSLog(@"Before");
    if ([self.delegate respondsToSelector:@selector(pluginArrayControllerDidRearrangeObjects:)]) {
        [self.delegate pluginArrayControllerDidRearrangeObjects:self];
    }

    
    NSArray *selectedObjects = [self selectedObjects];
    [super rearrangeObjects];
    [self setSelectedObjects:selectedObjects];
    // Need to make the table view first responder?

    NSLog(@"After");
    if ([self.delegate respondsToSelector:@selector(pluginArrayControllerDidRearrangeObjects:)]) {
        [self.delegate pluginArrayControllerDidRearrangeObjects:self];
    }
    
}
@end


@interface WCLPluginViewController () <NSTableViewDelegate, NSTextFieldDelegate>
@property (weak) IBOutlet WCLPluginArrayController *pluginArrayController;
@property (weak) IBOutlet NSTableView *tableView;
@property (assign) BOOL pendingMakeTableViewFirsResponder;
- (void)makeTableViewFirstResponder;
@end

@implementation WCLPluginViewController

@synthesize pluginArrayController = _pluginArrayController;

- (IBAction)addPlugin:(id)sender
{
    id newObject = [self.pluginArrayController newObject];
    [self.pluginArrayController addObject:newObject];
//    [self.pluginArrayController rearrangeObjects];

    // Simple re-implement of NSDictionaryController add because using the add: method waits for the next run loop before updating the table view.
    [self.tableView editColumn:0 row:[self.tableView selectedRow] withEvent:nil select:YES];
}

- (BOOL)becomeFirstResponder
{
    [[self.view window] makeFirstResponder:self.tableView];
    return YES;
}

- (void)awakeFromNib
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowUpdated:) name:NSWindowDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
           selector:@selector(tableViewTextDidEndEditing:)
               name:NSTextDidEndEditingNotification
             object:self.tableView];
}
- (void)tableViewTextDidEndEditing:(NSNotification *)notification
{
    NSLog(@"break");
}
//
//- (void)windowUpdated:(NSNotification *)notification
//{
//    NSLog(@"window updated [self.view.window firstResponder] = %@", [self.view.window firstResponder]);
//
//    if ([self.view.window firstResponder] == self.view.window) {
//        NSLog(@"break");
//    }
//}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    NSLog(@"break");

    [[[self view] window] performSelector:@selector(makeFirstResponder:) withObject:self.tableView afterDelay:0.0];
}

//- (void)controlTextDidChange:(NSNotification *)aNotification
//{
//    NSLog(@"break");
//}
//
//- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
//{
//    NSLog(@"Break");
//}

#pragma mark - WCLPluginNameTextFieldDelegate

- (void)pluginNameTextFieldWillEndEditing:(WCLPluginNameTextField *)pluginNameTextField
{
    if (self.pendingMakeTableViewFirsResponder) return;
    
    self.pendingMakeTableViewFirsResponder = YES;
    [self performSelector:@selector(makeTableViewFirstResponder) withObject:nil afterDelay:0.0];
}

- (void)makeTableViewFirstResponder
{
    [[[self view] window] makeFirstResponder:self.tableView];
    self.pendingMakeTableViewFirsResponder = NO;
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

#pragma mark - WCLPluginArrayControllerDelegate


- (void)pluginArrayControllerDidRearrangeObjects:(WCLPluginArrayController *)pluginArrayController
{
    // This just needs to be dispatched to the table view after editing occurs, probably from the cell itself.
    NSLog(@"[self.view.window firstResponder] = %@", [self.view.window firstResponder]);
//    [[[self view] window] performSelector:@selector(makeFirstResponder:) withObject:self.tableView afterDelay:0.0];

    
//    [[self.view window] makeFirstResponder:self];
//    [[self.view window] makeFirstResponder:[self.tableView rowViewAtRow:[self.tableView selectedRow] makeIfNecessary:NO]];
}

//#pragma mark - NSTextFieldDelegate
//
//- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
//{
//    return YES;
//}

#pragma mark - NSTableViewDelegate

//- (void)tableView:(NSTableView *)tableView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
//{
//    [[self.view window] makeFirstResponder:self.tableView];
//    
//    NSLog(@"break");
//}

#pragma mark - Properties

- (WCLPluginArrayController *)pluginArrayController
{
    return _pluginArrayController;
}

- (void)setPluginArrayController:(WCLPluginArrayController *)pluginArrayController
{
    if (_pluginArrayController == pluginArrayController) return;
    
    pluginArrayController.delegate = self;
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:kPluginNameKey
                                                                       ascending:YES
                                                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
    [pluginArrayController setSortDescriptors:sortDescriptors];
    _pluginArrayController = pluginArrayController;
}
@end
