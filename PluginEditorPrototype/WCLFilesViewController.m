//
//  WCLFilesViewController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/19/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLFilesViewController.h"

@interface WCLFilesViewController ()
@property (weak) IBOutlet NSArrayController *fileExtensionsArrayController;
@property (weak) IBOutlet NSTableView *tableView;
@end

@implementation WCLFilesViewController

@synthesize fileExtensionsArrayController = _fileExtensionsArrayController;

- (BOOL)becomeFirstResponder
{
    [[self.view window] makeFirstResponder:self.tableView];
    return YES;
}

#pragma mark Properties

- (NSArrayController *)fileExtensionsArrayController
{
    return _fileExtensionsArrayController;
}

- (void)setFileExtensionsArrayController:(NSArrayController *)fileExtensionsArrayController
{
    if (_fileExtensionsArrayController == fileExtensionsArrayController) {
        return;
    }
    
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"self"
                                                                       ascending:YES
                                                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
    [fileExtensionsArrayController setSortDescriptors:sortDescriptors];
    _fileExtensionsArrayController = fileExtensionsArrayController;
}



@end
