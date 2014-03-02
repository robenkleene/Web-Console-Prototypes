//
//  WCLPlugin.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/16/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPlugin.h"

#define kObservedSelectionKeyPaths [NSArray arrayWithObjects:@"name", @"command", @"fileExtensions", @"type", nil]

@implementation WCLPlugin

static void *WCLPlugiContext;


@dynamic command;
@dynamic fileExtensions;
@dynamic name;
@dynamic type;

- (void)awakeFromFetch
{
    [super awakeFromFetch];

    for (NSString *keyPath in kObservedSelectionKeyPaths) {
        [self addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew
                  context:&WCLPlugiContext];
    }
}

- (void)dealloc
{
    for (NSString *keyPath in kObservedSelectionKeyPaths) {
        [self removeObserver:self
                  forKeyPath:keyPath
                     context:&WCLPlugiContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &WCLPlugiContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    NSError *error;
    NSLog(@"saving, edited keypath = %@", keyPath);
    if (![[self managedObjectContext] save:&error]) {
        NSAssert(NO, @"Error saving.");
    }
}

@end
