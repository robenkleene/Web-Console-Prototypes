//
//  WCLPlugin.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/16/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPlugin.h"
#import "WCLPlugin+Validation.h"

#define kObservedSelectionKeyPaths [NSArray arrayWithObjects:@"name", @"command", @"fileExtensions", @"type", nil]

NSString * const WCLPluginNameKey = @"name";
NSString * const WCLPluginFileExtensionsKey = @"fileExtensions";

@interface WCLPlugin ()
@property (nonatomic, retain) NSData * fileExtensionsData;
@end

@implementation WCLPlugin

static void *WCLPluginContext;


@dynamic command;
@dynamic fileExtensionsData;
@dynamic name;
@dynamic type;

#pragma mark - Properties

- (void)setFileExtensions:(NSArray *)fileExtensions
{
    self.fileExtensionsData = [NSKeyedArchiver archivedDataWithRootObject:fileExtensions];
}

- (NSArray *)fileExtensions
{
    if (!self.fileExtensionsData) return nil;
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.fileExtensionsData];
}

- (BOOL)validateName:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    NSString *name;
    if ([*ioValue isKindOfClass:[NSString class]]) {
        name = *ioValue;
    }

    BOOL valid = [self nameIsValid:name];
    if (!valid && outError) {
        NSString *errorMessage = @"The plugin name must be unique, and can only contain alphanumeric characters, spaces, hyphens and underscores.";
        NSString *errorString = NSLocalizedString(errorMessage, @"Invalid plugin name error.");

        NSDictionary *userInfoDict = @{NSLocalizedDescriptionKey: errorString};
        *outError = [[NSError alloc] initWithDomain:kErrorDomain
                                               code:kErrorCodeInvalidePluginName
                                           userInfo:userInfoDict];
    }

    return valid;
}

#pragma mark - Saving

- (void)awakeFromFetch
{
    [super awakeFromFetch];

    for (NSString *keyPath in kObservedSelectionKeyPaths) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew
                  context:&WCLPluginContext];
    }
}

- (void)dealloc
{
    for (NSString *keyPath in kObservedSelectionKeyPaths) {
        [self removeObserver:self
                  forKeyPath:keyPath
                     context:&WCLPluginContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &WCLPluginContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    NSError *error;
    NSLog(@"saving, edited keypath = %@", keyPath);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving. %@", error);
    }
}

@end
