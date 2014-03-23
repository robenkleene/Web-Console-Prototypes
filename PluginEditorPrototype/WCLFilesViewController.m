//
//  WCLFilesViewController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/19/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLFilesViewController.h"
#import "WCLPlugin.h"

@interface WCLFilesViewController ()
@property (weak) IBOutlet NSTableView *tableView;
@end

@implementation WCLFilesViewController

- (BOOL)becomeFirstResponder
{
    [[self.view window] makeFirstResponder:self.tableView];
    return YES;
}

@end
