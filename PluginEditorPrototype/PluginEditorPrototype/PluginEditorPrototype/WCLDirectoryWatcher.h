//
//  WCLDirectoryWatcher.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLDirectoryWatcher;

@protocol WCLDirectoryWatcherDelegate <NSObject>
@optional
- (void)directoryWatcher:(WCLDirectoryWatcher *)directoryWatcher directoryWasCreatedOrModifiedAtPath:(NSString *)path;
- (void)directoryWatcher:(WCLDirectoryWatcher *)directoryWatcher fileWasCreatedOrModifiedAtPath:(NSString *)path;
- (void)directoryWatcher:(WCLDirectoryWatcher *)directoryWatcher itemWasRemovedAtPath:(NSString *)path;
@end

@interface WCLDirectoryWatcher : NSObject
- (id)initWithURL:(NSURL *)url;
@property (nonatomic, weak) id<WCLDirectoryWatcherDelegate> delegate;
@end
