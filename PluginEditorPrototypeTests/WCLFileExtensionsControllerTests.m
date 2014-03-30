//
//  WCLFileExtensionsControllerTests.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WCLTestPluginManagerTestCase.h"

#import "Web_ConsoleTestsConstants.h"

#import "WCLFileExtensionController.h"

#import "WCLPlugin.h"

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
    XCTAssertFalse([[[WCLFileExtensionController sharedFileExtensionController] extensions] count] > 0, @"There should not be any file extensions before adding a plugin.");
    
    WCLPlugin *plugin = [self addedPlugin];
    
    // Set file extensions to an array of file extensions
    plugin.extensions = kTestExtensions;

    NSArray *extensions = [[WCLFileExtensionController sharedFileExtensionController] extensions];
    BOOL extensionsMatch = [[self class] extensions:extensions matchExtensions:kTestExtensions];
    XCTAssertTrue(extensionsMatch, @"The file extensions should match the test file extensions.");


    // Set file extensions to an empty array
    plugin.extensions = kTestExtensionsEmpty;

    extensions = [[WCLFileExtensionController sharedFileExtensionController] extensions];
    extensionsMatch = [[self class] extensions:extensions matchExtensions:kTestExtensionsEmpty];
    XCTAssertTrue(extensionsMatch, @"The file extensions should match the empty test file extensions.");


    // Set file extensions to nil
    plugin.extensions = nil;
    
    extensions = [[WCLFileExtensionController sharedFileExtensionController] extensions];
    extensionsMatch = [[self class] extensions:extensions matchExtensions:kTestExtensionsEmpty];
    XCTAssertTrue(extensionsMatch, @"The file extensions should match the empty test file extensions.");
}

#pragma mark Helpers

+ (BOOL)extensions:(NSArray *)extensions1 matchExtensions:(NSArray *)extensions2
{
    NSArray *sortedExtensions1 = [extensions1 sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedExtensions2 = [extensions2 sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return [sortedExtensions1 isEqualToArray:sortedExtensions2];
}

@end
