//
//  WCLEnvironmentViewController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLEnvironmentViewController.h"

@interface WCLEnvironmentViewController ()
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSArrayController *arrayController;
- (IBAction)addEnvironmentVariable:(id)sender;
@end

@implementation WCLEnvironmentViewController

#pragma mark - IBActions

- (IBAction)addEnvironmentVariable:(id)sender
{
    NSWindow *window = [self.tableView window];
    BOOL success = [window makeFirstResponder:window];
    if(!success) return; // First responder did not resign

    NSMutableDictionary *environmentVariableDictionary = [self.arrayController newObject];
    
    environmentVariableDictionary[@"name"] = @"test name";
    environmentVariableDictionary[@"value"] = @"test value";

    [self.arrayController addObject:environmentVariableDictionary];
    
    NSUInteger rowIndex = [[self.arrayController arrangedObjects] indexOfObject:environmentVariableDictionary];

    NSAssert(rowIndex != NSNotFound, @"The environment variable dictionary should be in the NSArrayController's arranged objects.");

    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:NO];
    [self.tableView editColumn:0 row:rowIndex withEvent:nil select:YES];
}
@end
