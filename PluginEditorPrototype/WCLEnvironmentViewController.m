//
//  WCLEnvironmentViewController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLEnvironmentViewController.h"

#define kEnvironmentVariableDefaultKey @"VARIABLE"
#define kEnvironmentVariableDefaultValue @"VALUE"

@interface WCLEnvironmentViewController ()
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSDictionaryController *dictionaryController;
- (IBAction)addEnvironmentVariable:(id)sender;
@end

@implementation WCLEnvironmentViewController

@synthesize dictionaryController = _dictionaryController;

#pragma mark - IBActions

- (IBAction)addEnvironmentVariable:(id)sender
{
    id newObject = [self.dictionaryController newObject];
    [self.dictionaryController addObject:newObject];
//    [self.dictionaryController add:sender];
// Simple re-implement of NSDictionaryController add because using the add: method doesn't set the table view's selection right away.
    [self.tableView editColumn:0 row:[self.tableView selectedRow] withEvent:nil select:YES];
}

- (NSDictionaryController *)dictionaryController
{
    return _dictionaryController;
}

- (void)setDictionaryController:(NSDictionaryController *)dictionaryController
{
    if (_dictionaryController != dictionaryController) {
        [dictionaryController setInitialKey:kEnvironmentVariableDefaultKey];
        [dictionaryController setInitialKey:kEnvironmentVariableDefaultValue];
        _dictionaryController = dictionaryController;
    }
}

@end
