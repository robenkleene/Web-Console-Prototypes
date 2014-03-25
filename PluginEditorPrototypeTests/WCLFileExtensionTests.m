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

#import "WCLFileExtension.h"
#import "WCLKeyValueObservingTestsHelper.h"

@interface WCLFileExtensionTests : WCLTestPluginManagerTestCase

@end

@implementation WCLFileExtensionTests

- (void)setUp
{
    [super setUp];
    
    WCLPlugin *plugin = [self addedPlugin];
    
    // Set file extensions to an array of file extensions
    plugin.extensions = kTestExtensionsOne;

    NSArray *fileExtensions = [[self fileExtensionsController] fileExtensions];
    XCTAssertTrue([fileExtensions count] == 1, @"The file extensions count should equal one.");
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
#warning Delete NSUserDefaults here
    NSDictionary *fileExtensionPluginDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:kFileExtensionPluginsKey];

    NSLog(@"fileExtensionPluginDictionary = %@", fileExtensionPluginDictionary);
    
    [super tearDown];
}

- (void)testNewFileExtensionProperties
{
    WCLFileExtension *fileExtension = [[self fileExtensionsController] fileExtensionForExtension:kTestExtension];
    
    XCTAssertTrue([fileExtension.extension isEqualToString:kTestExtension] , @"The file extension's extension should equal the test extension.");
    XCTAssertTrue(fileExtension.isEnabled == kFileExtensionDefaultEnabled, @"The file extension enabled should equal the default enabled.");
    XCTAssertNil(fileExtension.selectedPlugin, @"The file extension's select plugin should be nil.");

    NSArray *plugins = [[self pluginManager] plugins];
    
    for (WCLPlugin *plugin in plugins) {
        BOOL matches = [[self class] plugin:plugin matchesForFileExtension:fileExtension];
        XCTAssertTrue(matches, @"The plugin should match the file extension.");
    }
}

- (void)testSettingEnabled
{
    WCLFileExtension *fileExtension = [[self fileExtensionsController] fileExtensionForExtension:kTestExtension];

    // Test key-value observing fires for the enabled property
    __block BOOL isEnabled = fileExtension.isEnabled;
    [WCLKeyValueObservingTestsHelper observeObject:fileExtension
                                        forKeyPath:kTestFileExtensionEnabledKeyPath
                                           options:NSKeyValueObservingOptionNew completionBlock:^(NSDictionary *change) {
                                               isEnabled = fileExtension.isEnabled;
                                           }];
    BOOL inverseEnabled = !fileExtension.isEnabled;
    fileExtension.enabled = inverseEnabled;
    XCTAssertTrue(isEnabled == inverseEnabled, @"The key-value observing change notification for the WCLFileExtensions's enabled property should have occurred.");
    XCTAssertTrue(fileExtension.isEnabled == inverseEnabled, @"The WCLFileExtension's isEnabled should equal the inverse enabled.");

    
    // Test NSUserDefaults is set
}

- (void)testSettingSelectedPlugin
{
    // Test key-value observing fires
    
    // Test NSUserDefaults is set
}



#pragma mark Helpers

+ (BOOL)plugin:(WCLPlugin *)plugin matchesForFileExtension:(WCLFileExtension *)fileExtension
{
    NSString *extension = fileExtension.extension;

    BOOL containsPlugin = [fileExtension.plugins containsObject:plugin];
    BOOL containsFileExtesion = [plugin.extensions containsObject:extension];
    
    return containsPlugin == containsFileExtesion;
}

@end
