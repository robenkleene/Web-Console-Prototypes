//
//  WCLFileExtensionsControllerTests.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WCLTestPluginManagerTestCase.h"
#import "WCLTestPluginManager.h"
#import "Web_ConsoleTestsConstants.h"

@interface WCLFileExtensionsControllerTests : WCLTestPluginManagerTestCase
@end

@implementation WCLFileExtensionsControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddingPluginAndChangingFileExtensions
{    
    // Hitting file extensions early makes sure that the singletons are instantiated and observers are in place.
    XCTAssertFalse([[[self fileExtensionsController] fileExtensions] count] > 0, @"There should not be any file extensions before adding a plugin.");
    
    WCLPlugin *plugin = [[self pluginManager] newPlugin];
    [[self pluginManagerController] insertObject:plugin inPluginsAtIndex:0];

    // Set file extensions to an array of file extensions
    plugin.fileExtensions = kTestFileExtensions;

    NSArray *fileExtensions = [[self fileExtensionsController] fileExtensions];
    BOOL fileExtensionsMatch = [[self class] fileExtensions:fileExtensions matchFileExtensions:kTestFileExtensions];
    XCTAssertTrue(fileExtensionsMatch, @"The file extensions should match the test file extensions.");


    // Set file extensions to an empty array
    plugin.fileExtensions = kTestFileExtensionsEmpty;

    fileExtensions = [[self fileExtensionsController] fileExtensions];
    fileExtensionsMatch = [[self class] fileExtensions:fileExtensions matchFileExtensions:kTestFileExtensionsEmpty];
    XCTAssertTrue(fileExtensionsMatch, @"The file extensions should match the empty test file extensions.");


    // Set file extensions to nil
    plugin.fileExtensions = nil;
    
    fileExtensions = [[self fileExtensionsController] fileExtensions];
    fileExtensionsMatch = [[self class] fileExtensions:fileExtensions matchFileExtensions:kTestFileExtensionsEmpty];
    XCTAssertTrue(fileExtensionsMatch, @"The file extensions should match the empty test file extensions.");
}

#pragma mark Helpers

+ (BOOL)fileExtensions:(NSArray *)fileExtensions1 matchFileExtensions:(NSArray *)fileExtensions2
{
    NSArray *sortedFileExtensions1 = [fileExtensions1 sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedFileExtensions2 = [fileExtensions2 sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return [sortedFileExtensions1 isEqualToArray:sortedFileExtensions2];
}

@end
