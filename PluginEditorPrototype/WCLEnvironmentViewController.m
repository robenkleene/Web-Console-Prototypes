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

@interface WCLEnvironmentView : NSView
@end

@implementation WCLEnvironmentView

- (NSError *)willPresentError:(NSError *)error
{
    if ([[error domain] isEqualToString:NSCocoaErrorDomain]) {
        switch ([error code]) {
            case NSKeyValueValidationError:
                return [WCLEnvironmentView keyValueValidationErrorForError:error];
                break;
            default:
                return [super willPresentError:error];
                break;
        }
    }

    return [super willPresentError:error];
}

+ (NSError *)keyValueValidationErrorForError:(NSError *)error
{
    NSString *localizedFailureReason = [error localizedFailureReason];
    if (localizedFailureReason) {
        NSMutableDictionary *userInfo = [NSMutableDictionary
                                            dictionaryWithCapacity:[[[error userInfo] allKeys] count]];
        [userInfo setDictionary:[error userInfo]];
        NSString *errorMessage = @"The variable is already set.";
        NSString *localizedErrorDescription = NSLocalizedString(errorMessage, nil);
        [userInfo setObject:localizedErrorDescription forKey:NSLocalizedDescriptionKey];
        NSError *newError = [NSError errorWithDomain:[error domain]
                                                code:[error code] userInfo:userInfo];
        return newError;
    }

    return error;
}

@end


@interface WCLEnvironmentViewController ()
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSDictionaryController *environmentDictionaryController;
- (IBAction)addEnvironmentVariable:(id)sender;
@end

@implementation WCLEnvironmentViewController

@synthesize environmentDictionaryController = _environmentDictionaryController;

#pragma mark - IBActions

- (IBAction)addEnvironmentVariable:(id)sender
{
    id newObject = [self.environmentDictionaryController newObject];
    [self.environmentDictionaryController addObject:newObject];
//    [self.dictionaryController add:sender];
// Simple re-implement of NSDictionaryController add because using the add: method doesn't set the table view's selection right away.
    [self.tableView editColumn:0 row:[self.tableView selectedRow] withEvent:nil select:YES];
}

- (BOOL)becomeFirstResponder
{
    [[self.view window] makeFirstResponder:self.tableView];
    return YES;
}

#pragma mark - Properties

- (NSDictionaryController *)environmentDictionaryController
{
    return _environmentDictionaryController;
}

- (void)setEnvironmentDictionaryController:(NSDictionaryController *)environmentDictionaryController
{
    if (_environmentDictionaryController == environmentDictionaryController) return;
    
    [environmentDictionaryController setInitialKey:kEnvironmentVariableDefaultKey];
    [environmentDictionaryController setInitialKey:kEnvironmentVariableDefaultValue];
    _environmentDictionaryController = environmentDictionaryController;
}

@end
