//
//  WCLEnvironmentViewController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLEnvironmentViewController.h"

NSString * const WCLEnvironmentVariableNameKey = @"name";
NSString * const WCLEnvironmentVariableValueKey = @"value";

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

//- (IBAction)addEnvironmentVariable:(id)sender
//{
//    NSWindow *window = [self.tableView window];
//    BOOL success = [window makeFirstResponder:window];
//    if(!success) return; // First responder did not resign
//
//    NSMutableDictionary *environmentVariableDictionary = [self.arrayController newObject];
//    
//    environmentVariableDictionary[WCLEnvironmentVariableNameKey] = kEnvironmentVariableDefaultName;
//    environmentVariableDictionary[WCLEnvironmentVariableValueKey] = kEnvironmentVariableDefaultValue;
//
//    [self.arrayController addObject:environmentVariableDictionary];
//    
//    NSUInteger rowIndex = [[self.arrayController arrangedObjects] indexOfObject:environmentVariableDictionary];
//
//    NSAssert(rowIndex != NSNotFound, @"The environment variable dictionary should be in the NSArrayController's arranged objects.");
//
////    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:NO];
//    [self.tableView editColumn:0 row:rowIndex withEvent:nil select:YES];
//}


- (void)awakeFromNib
{
//    [_arrayController addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];

//    [_dictionaryController addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{


    
    if ([keyPath isEqualToString:@"selection"]) {
//        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
//        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
//        NSLog(@"oldValue = %@", oldValue);
//        NSLog(@"newValue = %@", newValue);

        NSLog(@"observeValueForKeyPath: [self.arrayController selectedObjects]  = %@", [self.dictionaryController selectedObjects]);
        
    }
}

- (NSDictionaryController *)dictionaryController
{
    return _dictionaryController;
}

- (void)setDictionaryController:(NSDictionaryController *)dictionaryController
{
    if (_dictionaryController != dictionaryController) {
        _dictionaryController = dictionaryController;
        [_dictionaryController addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        [_dictionaryController setInitialKey:kEnvironmentVariableDefaultKey];
        [_dictionaryController setInitialKey:kEnvironmentVariableDefaultValue];
    }
}

@end
