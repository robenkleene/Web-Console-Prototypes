//
//  WCLPluginManagerTests.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 4/5/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WCLTestPluginManagerTestCase.h"

#import "Web_ConsoleTestsConstants.h"

#import "WCLPluginManager.h"
#import "WCLPlugin.h"

@interface WCLPlugin (Tests)
- (BOOL)validateName:(id *)ioValue error:(NSError * __autoreleasing *)outError;
@end

@interface WCLPluginManagerTests : WCLTestPluginManagerTestCase
@end

@implementation WCLPluginManagerTests

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

- (void)testNameValidation
{
    WCLPlugin *plugin = [self addedPlugin];
    plugin.name = kTestPluginName;

    // Test that the name is valid for this plugin
    NSError *error;
    id name = kTestPluginName;
    BOOL valid = [plugin validateName:&name error:&error];
    XCTAssertTrue(valid, @"The name should be valid");
    XCTAssertNil(error, @"The error should be nil");
    
    
    // Make a new plugin
    WCLPlugin *pluginTwo = [self addedPlugin];

    // Test that the name is not valid for another plugin
    error = nil;
    name = kTestPluginName;
    valid = [pluginTwo validateName:&name error:&error];
    XCTAssertFalse(valid, @"The name should not be valid");
    XCTAssertNotNil(error, @"The error should not be nil.");


    // Change the first plugins name
    plugin.name = kTestDefaultNewPluginName;
    
    // Test that the name is now valid for the second plugin
    error = nil;
    name = kTestPluginName;
    valid = [pluginTwo validateName:&name error:&error];
    XCTAssertTrue(valid, @"The name should not be valid");
    XCTAssertNil(error, @"The error should not be nil.");


    // Test that the new name is now invalid
    error = nil;
    name = kTestDefaultNewPluginName;
    valid = [pluginTwo validateName:&name error:&error];
    XCTAssertFalse(valid, @"The name should not be valid");
    XCTAssertNotNil(error, @"The error should not be nil.");

    // Delete the plugin
    [self deletePlugin:plugin];

    // Test that the new name is now valid
    error = nil;
    name = kTestDefaultNewPluginName;
    valid = [pluginTwo validateName:&name error:&error];
    XCTAssertTrue(valid, @"The name should be valid");
    XCTAssertNil(error, @"The error should be nil.");    
}

- (void)testPluginNames
{
    for (NSUInteger i = 0; i < 105; i++) {
        WCLPlugin *plugin = [self addedPlugin];
 
        if (i == 0) {
            XCTAssertTrue([plugin.name isEqualToString:kTestDefaultNewPluginName], @"The WCLPlugin's name equal the default new plugin name.");
            continue;
        }
        
        NSUInteger suffixCount = i + 1;
        if (suffixCount > 99) {
            XCTAssertTrue([plugin.name isEqualToString:plugin.identifier], @"The WCLPlugin's name should equal its identifier.");
            continue;
        }

        
        XCTAssertTrue([plugin.name hasPrefix:kTestDefaultNewPluginName], @"The WCLPlugin's name should start with the default new plugin name.");
        NSString *suffix = [NSString stringWithFormat:@"%lu", (unsigned long)suffixCount];
        XCTAssertTrue([plugin.name hasSuffix:suffix], @"The WCLPlugin's name should end with the suffix.");
    }
}

@end
