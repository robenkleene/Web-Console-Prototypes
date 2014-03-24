//
//  WCLFileExtension.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/23/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLFileExtension.h"

@implementation WCLFileExtension

- (id)initWithExtension:(NSString *)extension {
    self = [super init];
    if (self) {
		_extension = extension;
        _plugins = [NSMutableArray array];
    }
    return self;
}

@end
