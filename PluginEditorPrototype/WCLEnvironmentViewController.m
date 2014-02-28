//
//  WCLEnvironmentViewController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLEnvironmentViewController.h"

@interface WCLEnvironmentViewController () <NSTableViewDelegate>
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSArrayController *arrayController;
@end

@implementation WCLEnvironmentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)loadView
{
    [super loadView];

//    [[resultsTableView window] makeFirstResponder:resultsTableView];
    NSLog(@"self.tableView = %@", self.tableView);
}

//- (BOOL)becomeFirstResponder
//{
//    NSLog(@"Got here");
//    
//    [[self.view window] makeFirstResponder:self.tableView];
//    
//    return YES;
//}

#pragma mark - IBActions

- (IBAction)addEnvironmentVariable:(id)sender
{
    NSWindow *window = [self.tableView window];
    BOOL success = [window makeFirstResponder:window];
    if(!success) return; // First responder did not resign

    NSMutableDictionary *environmentVariableDictionary = [self.arrayController newObject];
    
    environmentVariableDictionary[@"name"] = @"test name";
    environmentVariableDictionary[@"value"] = @"test value";
    NSLog(@"environmentVariableDictionary = %@", environmentVariableDictionary);

    [self.arrayController addObject:environmentVariableDictionary];

    [self.arrayController rearrangeObjects];
    
//    NSUInteger row = [[self.arrayController arrangedObjects] indexOfObjectIdenticalTo:environmentVariableDictionary];
    NSUInteger row = [[self.arrayController arrangedObjects] indexOfObject:environmentVariableDictionary];
    
    NSLog(@"self.arrayController arrangedObjects = %@", [self.arrayController arrangedObjects]);
    
    
    NSAssert(row != NSNotFound, @"The environment variable dictionary should be in the NSArrayController's arranged objects.");
    
    [self.tableView editColumn:0 row:row withEvent:nil select:YES];
}

#pragma mark - NSTableViewDelegate

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    NSLog(@"Got here");
}


@end
