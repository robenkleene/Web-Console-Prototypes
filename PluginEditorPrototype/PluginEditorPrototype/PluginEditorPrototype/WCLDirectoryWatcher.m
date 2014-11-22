//
//  WCLDirectoryWatcher.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/12/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLDirectoryWatcher.h"
#import "WCLFileSystemEvent.h"

#pragma mark - WCLDirectoryWatcher Class Extension

@interface WCLDirectoryWatcher ()
@property (nonatomic, assign) FSEventStreamRef stream;
- (void)handleFileSystemEvent:(WCLFileSystemEvent *)fileSystemEvent;
@end


#pragma mark - C

void wcl_plugin_directory_event_stream_callback(ConstFSEventStreamRef streamRef,
                                                void *clientCallBackInfo,
                                                size_t numEvents,
                                                void *eventPaths,
                                                const FSEventStreamEventFlags eventFlags[],
                                                const FSEventStreamEventId eventIds[])
{
    WCLDirectoryWatcher *directoryWatcher = (__bridge WCLDirectoryWatcher *)clientCallBackInfo;
    int i;
    char **paths = eventPaths;
    for (i = 0; i < numEvents; i++) {
        NSString *path = [NSString stringWithFormat:@"%s", paths[i]];
        
//        printf("Change %llu in %s, flags %u\n", eventIds[i], paths[i], (unsigned int)eventFlags[i]);
        
        //        WCLFileSystemEvent *fileSystemEvent =
        WCLFileSystemEvent *fileSystemEvent = [WCLFileSystemEvent fileSystemEventWithPath:path
                                                                               eventFlags:eventFlags[i]
                                                                                  eventId:eventIds[i]];
        [directoryWatcher handleFileSystemEvent:fileSystemEvent];
    }
}


#pragma mark - WCLDirectoryWatcher Implementation

@implementation WCLDirectoryWatcher

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        [self watchURL:url];
    }
    return self;
}

- (void)handleFileSystemEvent:(WCLFileSystemEvent *)fileSystemEvent
{
    NSLog(@"fileSystemEvent = %@", fileSystemEvent);
}

- (void)watchPath:(NSString *)path
{
    CFStringRef pathRef = (__bridge CFStringRef)path;
    CFArrayRef pathsRef = CFArrayCreate(NULL,
                                        (const void **)&pathRef,
                                        1,
                                        NULL);
    FSEventStreamContext callbackInfo;
    callbackInfo.version = 0;
    callbackInfo.info = (__bridge void *)self;
    callbackInfo.retain = NULL;
    callbackInfo.release = NULL;
    callbackInfo.copyDescription = NULL;
    
    self.stream = FSEventStreamCreate(NULL,
                                      &wcl_plugin_directory_event_stream_callback,
                                      &callbackInfo,
                                      pathsRef,
                                      kFSEventStreamEventIdSinceNow,
                                      0,
                                      kFSEventStreamCreateFlagIgnoreSelf | kFSEventStreamCreateFlagFileEvents);
    FSEventStreamScheduleWithRunLoop(self.stream,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    FSEventStreamStart(self.stream);
}

- (void)watchURL:(NSURL *)url
{
    [self watchPath:[url path]];
}

- (void)dealloc
{
    FSEventStreamStop(self.stream);
    FSEventStreamInvalidate(self.stream);
}

@end
