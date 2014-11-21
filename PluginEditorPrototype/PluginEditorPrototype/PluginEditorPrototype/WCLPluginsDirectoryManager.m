//
//  WCLPluginDirectoryManager.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/9/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginsDirectoryManager.h"

#import "WCLDirectoryWatcher.h"

@interface WCLPluginsDirectoryManager ()
@property (nonatomic, strong) WCLDirectoryWatcher *directoryWatcher;
@end

@implementation WCLPluginsDirectoryManager

- (id)initWithPluginsDirectoryURL:(NSURL *)pluginsDirectoryURL
{
    self = [super init];
    if (self) {
        _directoryWatcher = [[WCLDirectoryWatcher alloc] initWithURL:pluginsDirectoryURL];
    }
    return self;
}

@end