//
//  WCLFileExtensionTests.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/24/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WCLTestPluginManagerTestCase.h"
#import "WCLTestPluginManager.h"
#import "Web_ConsoleTestsConstants.h"

@interface WCLFileExtensionTests : WCLTestPluginManagerTestCase

@end

@implementation WCLFileExtensionTests

- (void)setUp
{
    [super setUp];
    
    WCLPlugin *plugin = [self addedPlugin];
    
    // Set file extensions to an array of file extensions
    plugin.extensions = kTestExtensions;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    NSLog(@"[[self fileExtensionsController] fileExtensions] = %@", [[self fileExtensionsController] fileExtensions]);
    
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
