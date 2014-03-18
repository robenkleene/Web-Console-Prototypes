//
//  WCLKeyValueObservingTestsHelper.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLKeyValueObservingTestsHelper.h"

@interface WCLKeyValueObserver : NSObject
@property (nonatomic, copy) void (^completionBlock)(NSDictionary *change);
@end

@implementation WCLKeyValueObserver

- (id)initWithObject:(id)object
             keyPath:(NSString *)keyPath
             options:(NSKeyValueObservingOptions)options
     completionBlock:(void (^)(NSDictionary *change))completionBlock
{
    self = [super init];
    if (self) {
        _completionBlock = completionBlock;
        [object addObserver:self forKeyPath:keyPath options:options context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [object removeObserver:self forKeyPath:keyPath];
    self.completionBlock(change);
}

@end


@interface WCLKeyValueObservingTestsHelper ()
@property (nonatomic, strong) NSMutableArray *observers;
@end

@implementation WCLKeyValueObservingTestsHelper

+ (void)observeObject:(id)object
           forKeyPath:(NSString *)keyPath
              options:(NSKeyValueObservingOptions)options
      completionBlock:(void (^)(NSDictionary *change))completionBlock
{
    [[WCLKeyValueObservingTestsHelper shareKeyValueObservingTestsHelper] observeObject:object
                                                                            forKeyPath:keyPath
                                                                               options:options
                                                                       completionBlock:completionBlock];
}

#pragma mark Private

+ (instancetype)shareKeyValueObservingTestsHelper
{
    static dispatch_once_t pred;
    static WCLKeyValueObservingTestsHelper *keyValueObservingTestsHelper = nil;
    
    dispatch_once(&pred, ^{
        keyValueObservingTestsHelper = [[self alloc] init];
    });

    return keyValueObservingTestsHelper;
}

- (NSMutableArray *)observers
{
    if (_observers) {
        return _observers;
    }

    _observers = [NSMutableArray array];

    return _observers;
}

- (void)observeObject:(id)object
           forKeyPath:(NSString *)keyPath
              options:(NSKeyValueObservingOptions)options
      completionBlock:(void (^)(NSDictionary *change))completionBlock
{
    __block WCLKeyValueObserver *observer;
    observer = [[WCLKeyValueObserver alloc] initWithObject:object
                                                   keyPath:keyPath
                                                   options:options
                                           completionBlock:^void (NSDictionary *change) {
                                               [self.observers removeObject:observer];
                                               completionBlock(change);
                                           }];
    [self.observers addObject:observer];
}

@end
