//
//  WCLFileSystemEvent.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCLFileSystemEvent : NSObject
+ (instancetype)fileSystemEventWithPath:(NSString *)path
                             eventFlags:(FSEventStreamEventFlags)eventFlags
                                eventId:(FSEventStreamEventId)eventId;
@property (nonatomic, strong) NSString *path;
- (BOOL)fileWasCreated;
- (BOOL)fileWasModified;
- (BOOL)fileWasRemoved;
- (BOOL)fileWasRenamed;
@end
