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


@interface WCLFileExtension (Test)
+ (NSDictionary *)fileExtensionToPluginDictionary;
+ (void)setfileExtensionToPluginDictionary:(NSDictionary *)fileExtensionToPluginDictionary;
@end

@interface WCLFileExtensionTests : WCLTestPluginManagerTestCase

@end

@implementation WCLFileExtensionTests

- (void)setUp
{
    [super setUp];
    
    // TODO: Assert existing plugin settings in userDefaults are nil? I.e., [WCLFileExtension fileExtensionToPluginDictionary]

    WCLPlugin *plugin = [self addedPlugin];
    
    // Set file extensions to an array of file extensions
    plugin.extensions = kTestExtensionsOne;

    NSArray *fileExtensions = [[self fileExtensionsController] fileExtensions];
    XCTAssertTrue([fileExtensions count] == 1, @"The file extensions count should equal one.");
}

- (void)tearDown
{
    // Delete all file extension settings
    [WCLFileExtension setfileExtensionToPluginDictionary:nil];
    
    [super tearDown];
}

- (void)testNewFileExtensionProperties
{
    WCLFileExtension *fileExtension = [[self fileExtensionsController] fileExtensionForExtension:kTestExtension];
    
    XCTAssertTrue([fileExtension.extension isEqualToString:kTestExtension] , @"The WCLFileExtension's extension should equal the test extension.");
    XCTAssertTrue(fileExtension.isEnabled == kFileExtensionDefaultEnabled, @"The WCLFileExtension's enabled should equal the default enabled.");
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

    // Test setting the enabled property
    
    // Test key-value observing for the enabled property
    __block BOOL isEnabled = fileExtension.isEnabled;
    [WCLKeyValueObservingTestsHelper observeObject:fileExtension
                                        forKeyPath:kTestFileExtensionEnabledKeyPath
                                           options:NSKeyValueObservingOptionNew completionBlock:^(NSDictionary *change) {
                                               isEnabled = fileExtension.isEnabled;
                                           }];
    BOOL inverseEnabled = !fileExtension.isEnabled;
    fileExtension.enabled = inverseEnabled;
    XCTAssertEqual(isEnabled, inverseEnabled, @"The key-value observing change notification for the WCLFileExtensions's enabled property should have occurred.");
    XCTAssertEqual(fileExtension.isEnabled, inverseEnabled, @"The WCLFileExtension's isEnabled should equal the inverse enabled.");
    
    // Test NSUserDefaults is set
    NSDictionary *fileExtensionToPluginDictionary = [WCLFileExtension fileExtensionToPluginDictionary];
    NSDictionary *fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
    BOOL enabledInDictionary = [[fileExtensionPluginDictionary valueForKey:kFileExtensionEnabledKey] boolValue];
    XCTAssertEqual(enabledInDictionary, fileExtension.isEnabled, @"The enabled value in the dictionary should match the WCLFileExtension's enabled property");

    // Test inverting the enabled property

    // Test key-value observing for the enabled property
    isEnabled = fileExtension.isEnabled;
    [WCLKeyValueObservingTestsHelper observeObject:fileExtension
                                        forKeyPath:kTestFileExtensionEnabledKeyPath
                                           options:NSKeyValueObservingOptionNew completionBlock:^(NSDictionary *change) {
                                               isEnabled = fileExtension.isEnabled;
                                           }];
    inverseEnabled = !fileExtension.isEnabled;
    fileExtension.enabled = inverseEnabled;
    XCTAssertEqual(isEnabled, inverseEnabled, @"The key-value observing change notification for the WCLFileExtensions's enabled property should have occurred.");
    XCTAssertEqual(fileExtension.isEnabled, inverseEnabled, @"The WCLFileExtension's isEnabled should equal the inverse enabled.");
    
    // Test NSUserDefaults is set
    fileExtensionToPluginDictionary = [WCLFileExtension fileExtensionToPluginDictionary];
    fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
    enabledInDictionary = [[fileExtensionPluginDictionary valueForKey:kFileExtensionEnabledKey] boolValue];
    XCTAssertEqual(enabledInDictionary, fileExtension.isEnabled, @"The enabled value in the dictionary should match the WCLFileExtension's enabled property");
}

- (void)testSettingSelectedPlugin
{
    WCLFileExtension *fileExtension = [[self fileExtensionsController] fileExtensionForExtension:kTestExtension];
    
    // Test key-value observing for the selected plugin property
    __block WCLPlugin *selectedPlugin = fileExtension.selectedPlugin;
    [WCLKeyValueObservingTestsHelper observeObject:fileExtension
                                        forKeyPath:kTestFileExtensionSelectedPluginKeyPath
                                           options:NSKeyValueObservingOptionNew completionBlock:^(NSDictionary *change) {
                                               selectedPlugin = fileExtension.selectedPlugin;
                                           }];
    WCLPlugin *plugin = fileExtension.plugins[0];
    XCTAssertNotEqual(selectedPlugin, plugin, @"The WCLFileExtension's selected plugin should not equal the plugin.");
    fileExtension.selectedPlugin = plugin;
    XCTAssertEqual(selectedPlugin, plugin, @"The key-value observing change notification for the WCLFileExtensions's selected plugin property should have occurred.");

    // Test NSUserDefaults is set
    NSDictionary *fileExtensionToPluginDictionary = [WCLFileExtension fileExtensionToPluginDictionary];
    NSDictionary *fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
    NSString *pluginIdentifierInDictionary = [fileExtensionPluginDictionary valueForKey:kFileExtensionPluginIdentifierKey];
    XCTAssertEqual(pluginIdentifierInDictionary, fileExtension.selectedPlugin.identifier, @"The plugin identifier value in the dictionary should match the WCLFileExtension's selected WCLPlugin's identifier.");
    
    
    // TODO: Test above when setting the plugin to another plugin
    
    // TODO: Test above when setting the plugin to nil

    // TODO: Test deleting the selected plugin

    // TODO: Test Removing this file extension from the selected plugin
    
    // TODO: Test KVO fires when adding and removing a plugin from this file extensions plugins

    // TODO: Test selectedPlugin validation
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
