//
//  WCLFilesViewController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/19/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLFilesViewController.h"
#import "WCLPlugin.h"
#import "WCLPluginManager.h"
#import "WCLFileExtension.h"

@interface WCLPluginsToPluginNamesValueTransformer : NSValueTransformer
@end

@implementation WCLPluginsToPluginNamesValueTransformer

+ (BOOL)allowsReverseTransformation {
    return YES;
}

-(id)transformedArray:(NSArray *)array
{
    NSMutableArray *transformedArray = [NSMutableArray array];

    for (id value in array) {
        [transformedArray addObject:[self transformedValue:value]];
    }

    return transformedArray;
}

- (id)transformedValue:(id)value
{
    if ([value isKindOfClass:[NSArray class]]) {
        return [self transformedArray:value];
    }
    
    if ([value isKindOfClass:[WCLPlugin class]]) {
        WCLPlugin *plugin = (WCLPlugin *)value;
        return plugin.name;
    }
    
    return nil;
}

-(id)reverseTransformedArray:(NSArray *)array
{
    NSMutableArray *transformedArray = [NSMutableArray array];
    
    for (id value in array) {
        [transformedArray addObject:[self reverseTransformedValue:value]];
    }
    
    return transformedArray;
}

- (id)reverseTransformedValue:(id)value
{
    if ([value isKindOfClass:[NSArray class]]) {
        return [self reverseTransformedValue:value];
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        NSString *pluginName = (NSString *)value;
        return [[WCLPluginManager sharedPluginManager] pluginWithName:pluginName];
    }

    return nil;
}

@end

@interface WCLFilesViewController ()
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSArrayController *fileExtensionsArrayController;
@end

@implementation WCLFilesViewController

@synthesize fileExtensionsArrayController = _fileExtensionsArrayController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Files"];
    }
    return self;
}

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
    
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:WCLFileExtensionExtensionKey
                                                                       ascending:YES
                                                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:nameSortDescriptor, nil];
    [fileExtensionsArrayController setSortDescriptors:sortDescriptors];
    _fileExtensionsArrayController = fileExtensionsArrayController;
}


@end
