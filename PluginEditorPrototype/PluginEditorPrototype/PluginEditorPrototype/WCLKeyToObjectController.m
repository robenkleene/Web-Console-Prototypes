//
//  WCLNameToPluginController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLKeyToObjectController.h"

@interface WCLKeyToObjectController ()
@property (nonatomic, strong, readonly) NSMutableDictionary *keyToObjectDictionary;
@property (nonatomic, strong, readonly) NSString *key;
@end

@implementation WCLKeyToObjectController

static void *WCLKeyToObjectControllerContext;

@synthesize keyToObjectDictionary = _keyToObjectDictionary;

- (instancetype)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _key = key;
    }
    return self;
}

- (instancetype)initWithKey:(NSString *)key objects:(NSArray *)objects
{
    self = [self initWithKey:key];
    if (self) {
        [self addObjectsFromArray:objects];
    }
    return self;
}

- (id)addObject:(id)object
{
    NSString *value = [object valueForKey:self.key];

    id existingObject = self.keyToObjectDictionary[value];
    
    if (existingObject) {
        [self removeObject:existingObject];
    }

    self.keyToObjectDictionary[value] = object;
    [object addObserver:self
             forKeyPath:self.key
                options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                context:&WCLKeyToObjectControllerContext];

    return existingObject;
}

- (void)removeObject:(id)object
{
    NSString *key = [object valueForKey:self.key];

    if (self.keyToObjectDictionary[key] == object) {
        [self.keyToObjectDictionary removeObjectForKey:key];
        [object removeObserver:self
                    forKeyPath:self.key
                       context:&WCLKeyToObjectControllerContext];
    }
}

- (void)dealloc
{
    NSArray *objects = [self allObjects];
    for (id object in objects) {
        [self removeObject:object];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context != &WCLKeyToObjectControllerContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    NSKeyValueChange keyValueChange = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if (keyValueChange != NSKeyValueChangeSetting) {
        return;
    }
    
    if (![keyPath isEqualToString:self.key]) {
        return;
    }

    NSString *oldValue = change[NSKeyValueChangeOldKey];
    NSString *newValue = change[NSKeyValueChangeNewKey];
    
    [self.keyToObjectDictionary removeObjectForKey:oldValue];
    self.keyToObjectDictionary[newValue] = object;
}



#pragma mark Convienence Methods

- (NSArray *)addObjectsFromArray:(NSArray *)objects
{
    NSMutableArray *removedObjects = [NSMutableArray array];
    for (id object in objects) {
        id removedObject = [self addObject:object];
        if (removedObject) {
            [removedObjects addObject:removedObject];
        }
    }
    return removedObjects;
}

- (void)removeObjectsFromArray:(NSArray *)objects
{
    for (id object in objects) {
        [self removeObject:object];
    }
}


#pragma mark Accessing Plugins

- (id)objectWithKey:(NSString *)key
{
    return self.keyToObjectDictionary[key];
}

- (NSArray *)allObjects
{
    return [self.keyToObjectDictionary allValues];
}


#pragma mark Properties

- (NSMutableDictionary *)keyToObjectDictionary
{
    if (_keyToObjectDictionary) {
        return _keyToObjectDictionary;
    }

    _keyToObjectDictionary = [NSMutableDictionary dictionary];

    return _keyToObjectDictionary;
}

@end
