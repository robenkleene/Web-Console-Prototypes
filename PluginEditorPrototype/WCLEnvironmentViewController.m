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


#pragma mark - WCLEnvironmentView

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


#pragma mark - WCLEnvironmentVariableFormatter

@interface WCLEnvironmentVariableFormatter : NSFormatter
@end

@implementation WCLEnvironmentVariableFormatter

- (NSString *)stringForObjectValue:(id)obj
{
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }

    return nil;
}

- (BOOL)getObjectValue:(out __autoreleasing id *)obj forString:(NSString *)string errorDescription:(out NSString *__autoreleasing *)error
{
    *obj = string;
    
    return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString *__autoreleasing *)newString errorDescription:(NSString *__autoreleasing *)error
{
    NSMutableCharacterSet *allowedCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"_"];
    [allowedCharacterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
    
    NSCharacterSet *disallowedCharacterSet = [allowedCharacterSet invertedSet];

    NSRange disallowedRange = [partialString rangeOfCharacterFromSet:disallowedCharacterSet];
    BOOL foundDisallowedCharacter = !(NSNotFound == disallowedRange.location);
    
    return !foundDisallowedCharacter;
}

@end


#pragma mark - WCLEnvironmentViewController

@interface WCLEnvironmentViewController ()
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSDictionaryController *environmentDictionaryController;
- (IBAction)addEnvironmentVariable:(id)sender;
@end

@implementation WCLEnvironmentViewController

@synthesize environmentDictionaryController = _environmentDictionaryController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Environment"];
    }
    return self;
}

#pragma mark IBActions

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

#pragma mark Properties

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
