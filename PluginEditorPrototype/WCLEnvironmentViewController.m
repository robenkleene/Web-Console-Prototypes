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

#pragma mark - NSTableViewDelegate

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    NSLog(@"Got here");
}


@end
