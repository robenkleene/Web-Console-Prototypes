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

#define kEnvironmentVariableDefaultName @"VARIABLE"
#define kEnvironmentVariableDefaultValue @"VALUE"

@interface WCLEnvironmentViewController ()
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSArrayController *arrayController;
- (IBAction)addEnvironmentVariable:(id)sender;
@end

@implementation WCLEnvironmentViewController

@synthesize arrayController = _arrayController;

#pragma mark - IBActions

- (IBAction)addEnvironmentVariable:(id)sender
{
    NSLog(@"Before add [self.arrayController selectedObjects]  = %@", [self.arrayController selectedObjects]);
    
//    [self.arrayController add:sender];

//    NSWindow *window = [self.tableView window];
//    BOOL success = [window makeFirstResponder:window];
//    if(!success) return; // First responder did not resign

    NSMutableDictionary *environmentVariableDictionary = [self.arrayController newObject];

    environmentVariableDictionary[WCLEnvironmentVariableNameKey] = kEnvironmentVariableDefaultName;
    environmentVariableDictionary[WCLEnvironmentVariableValueKey] = kEnvironmentVariableDefaultValue;

    [self.arrayController addObject:environmentVariableDictionary];

#warning Bug with NSArrayController and using "Handles Content as Compound Value"
    [self.arrayController setSelectedObjects:@[environmentVariableDictionary]]; // Only reason this isn't working is because the object is not unique, I probably want this to be unique
    [self.view.window makeFirstResponder:self.tableView];
    
//    NSUInteger rowIndex = [[self.arrayController arrangedObjects] indexOfObject:environmentVariableDictionary];
//
//    NSAssert(rowIndex != NSNotFound, @"The environment variable dictionary should be in the NSArrayController's arranged objects.");
//
////    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:NO];
//    [self.tableView editColumn:0 row:rowIndex withEvent:nil select:YES];

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

    [_arrayController addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{


    
    if ([keyPath isEqualToString:@"selectionIndexes"]) {
//        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
//        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
//        NSLog(@"oldValue = %@", oldValue);
//        NSLog(@"newValue = %@", newValue);

        NSLog(@"observeValueForKeyPath: [self.arrayController selectedObjects]  = %@", [self.arrayController selectedObjects]);
        
    }
}

//- (NSArrayController *)arrayController
//{
//    return _arrayController;
//}
//
//- (void)setArrayController:(NSArrayController *)arrayController
//{
//    if (_arrayController != arrayController) {
//        _arrayController = arrayController;
//        [_arrayController addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
//    }
//}

@end
