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
@property (weak) IBOutlet NSArrayController *fileExtensionsArrayController;
@property (weak) IBOutlet NSArrayController *pluginArrayController;
@property (weak) IBOutlet NSTableView *tableView;
@end

@implementation WCLFilesViewController

@synthesize fileExtensionsArrayController = _fileExtensionsArrayController;
@synthesize pluginArrayController = _pluginArrayController;

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

- (NSArrayController *)pluginArrayController
{
    return _pluginArrayController;
}

- (void)setPluginArrayController:(NSArrayController *)pluginArrayController
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
