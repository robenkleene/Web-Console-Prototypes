//
//  WCLPluginDirectoryManager.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/9/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginsDirectoryManager.h"

void wcl_plugin_directory_event_stream_callback(ConstFSEventStreamRef streamRef,
                                                void *clientCallBackInfo,
                                                size_t numEvents,
                                                void *eventPaths,
                                                const FSEventStreamEventFlags eventFlags[],
                                                const FSEventStreamEventId eventIds[])
{
    int i;
    char **paths = eventPaths;
    
    // printf("Callback called\n");
    for (i=0; i<numEvents; i++) {
        /* flags are unsigned long, IDs are uint64_t */
        printf("Change %llu in %s, flags %u\n", eventIds[i], paths[i], (unsigned int)eventFlags[i]);
    }
}

@interface WCLPluginsDirectoryManager ()
@property (nonatomic, assign) FSEventStreamRef stream;
@end

@implementation WCLPluginsDirectoryManager

- (id)initWithPluginsDirectoryURL:(NSURL *)pluginsDirectoryURL
{
    self = [super init];
    if (self) {
        [self watchURL:pluginsDirectoryURL];
    }
    return self;
}

- (void)watchPath:(NSString *)path
{
    CFStringRef pathRef = (__bridge CFStringRef)path;
    CFArrayRef pathsRef = CFArrayCreate(NULL,
                                        (const void **)&pathRef,
                                        1,
                                        NULL);
    self.stream = FSEventStreamCreate(NULL,
                                      &wcl_plugin_directory_event_stream_callback,
                                      NULL,
                                      pathsRef,
                                      kFSEventStreamEventIdSinceNow,
                                      0,
                                      kFSEventStreamCreateFlagFileEvents);
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