//
//  WCLFileSystemEvent.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCLFileSystemEvent : NSObject
+ (instancetype)fileSystemEventWithPath:(NSString *)path eventFlags:(FSEventStreamEventFlags)eventFlags;
@end
