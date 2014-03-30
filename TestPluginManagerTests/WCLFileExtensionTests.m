//
//  WCLFileExtensionTests.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/24/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "WCLTestPluginManagerTestCase.h"

#import "Web_ConsoleTestsConstants.h"

#import "WCLFileExtensionController.h"
#import "WCLFileExtension.h"
#import "WCLPluginManager.h"
#import "WCLPlugin.h"
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

    NSArray *fileExtensions = [[WCLFileExtensionController sharedFileExtensionController] fileExtensions];
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
    WCLFileExtension *fileExtension = [[WCLFileExtensionController sharedFileExtensionController] fileExtensionForExtension:kTestExtension];
    
    XCTAssertTrue([fileExtension.extension isEqualToString:kTestExtension] , @"The WCLFileExtension's extension should equal the test extension.");
    XCTAssertTrue(fileExtension.isEnabled == kFileExtensionDefaultEnabled, @"The WCLFileExtension's enabled should equal the default enabled.");
    XCTAssertNil(fileExtension.selectedPlugin, @"The file extension's select plugin should be nil.");

    NSArray *plugins = [[WCLPluginManager sharedPluginManager] plugins];
    
    for (WCLPlugin *plugin in plugins) {
        BOOL matches = [[self class] plugin:plugin matchesForFileExtension:fileExtension];
        XCTAssertTrue(matches, @"The plugin should match the file extension.");
    }
}

- (void)testSettingEnabled
{
    WCLFileExtension *fileExtension = [[WCLFileExtensionController sharedFileExtensionController] fileExtensionForExtension:kTestExtension];

    // Test setting the enabled property
    
    // Test key-value observing for the enabled property
    __block BOOL isEnabled = fileExtension.isEnabled;
    [WCLKeyValueObservingTestsHelper observeObject:fileExtension
                                        forKeyPath:kTestFileExtensionEnabledKeyPath
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
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
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
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
    WCLFileExtension *fileExtension = [[WCLFileExtensionController sharedFileExtensionController] fileExtensionForExtension:kTestExtension];
    
    // Test key-value observing for the selected plugin property
    __block BOOL observedChange = NO;
    [WCLKeyValueObservingTestsHelper observeObject:fileExtension
                                        forKeyPath:kTestFileExtensionSelectedPluginKeyPath
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
                                               observedChange = YES;
                                           }];
    WCLPlugin *plugin = fileExtension.plugins[0];
    XCTAssertFalse(observedChange, @"The change should not have been observed.");
    fileExtension.selectedPlugin = plugin;
    XCTAssertTrue(observedChange, @"The key-value observing change should have occurred.");
    XCTAssertEqual(fileExtension.selectedPlugin, plugin, @"The WCLFileExtension's selected plugin should equal the plugin.");
    
    // Test NSUserDefaults is set
    NSDictionary *fileExtensionToPluginDictionary = [WCLFileExtension fileExtensionToPluginDictionary];
    NSDictionary *fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
    NSString *pluginIdentifierInDictionary = [fileExtensionPluginDictionary valueForKey:kFileExtensionPluginIdentifierKey];
    XCTAssertEqual(pluginIdentifierInDictionary, fileExtension.selectedPlugin.identifier, @"The plugin identifier value in the dictionary should match the WCLFileExtension's selected WCLPlugin's identifier.");
    
    // Test changing the selected plugin
    
    // Test key-value observing for the selected plugin property
    WCLPlugin *newPlugin = [self addedPlugin];
    newPlugin.extensions = kTestExtensionsOne;

    observedChange = NO;
    [WCLKeyValueObservingTestsHelper observeObject:fileExtension
                                        forKeyPath:kTestFileExtensionSelectedPluginKeyPath
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
                                               observedChange = YES;
                                           }];
    XCTAssertFalse(observedChange, @"The change should not have been observed.");
    fileExtension.selectedPlugin = newPlugin;
    XCTAssertTrue(observedChange, @"The key-value observing change should have occurred.");
    XCTAssertEqual(fileExtension.selectedPlugin, newPlugin, @"The WCLFileExtension's selected plugin should equal the plugin.");
    
    // Test NSUserDefaults is set
    fileExtensionToPluginDictionary = [WCLFileExtension fileExtensionToPluginDictionary];
    fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
    pluginIdentifierInDictionary = [fileExtensionPluginDictionary valueForKey:kFileExtensionPluginIdentifierKey];
    XCTAssertEqual(pluginIdentifierInDictionary, fileExtension.selectedPlugin.identifier, @"The plugin identifier value in the dictionary should match the WCLFileExtension's selected WCLPlugin's identifier.");

    // Test setting the selected plugin to nil
    
    // Test key-value observing for the selected plugin property
    observedChange = NO;
    [WCLKeyValueObservingTestsHelper observeObject:fileExtension
                                        forKeyPath:kTestFileExtensionSelectedPluginKeyPath
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
                                               observedChange = YES;
                                           }];
    XCTAssertFalse(observedChange, @"The change should not have been observed.");
    fileExtension.selectedPlugin = nil;
    XCTAssertTrue(observedChange, @"The key-value observing change should have occurred.");
    XCTAssertNil(fileExtension.selectedPlugin, @"The WCLFileExtension's selected plugin should be nil.");
    
    // Test key was removed from NSUserDefaults
    fileExtensionToPluginDictionary = [WCLFileExtension fileExtensionToPluginDictionary];
    fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
    pluginIdentifierInDictionary = [fileExtensionPluginDictionary valueForKey:kFileExtensionPluginIdentifierKey];
    XCTAssertNil(pluginIdentifierInDictionary, @"The plugin identifier value in the dictionary should be nil.");
}

- (void)testChangingPluginsFileExtensions
{
    WCLFileExtension *fileExtension = [[WCLFileExtensionController sharedFileExtensionController] fileExtensionForExtension:kTestExtension];
    WCLPlugin *newPlugin = [self addedPlugin];
    XCTAssertFalse([fileExtension.plugins containsObject:newPlugin], @"The WCLFileExtension's WCLPlugins should not contain the new plugin.");

    // Test key-value observing for the plugins property
    __block NSArray *plugins = [fileExtension.plugins copy];
    [WCLKeyValueObservingTestsHelper observeObject:fileExtension
                                        forKeyPath:WCLFileExtensionPluginsKey
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
                                               plugins = [fileExtension.plugins copy];
                                           }];
    XCTAssertFalse([plugins containsObject:newPlugin], @"The plugins should not contain the new plugin.");
    newPlugin.extensions = kTestExtensionsOne;
    XCTAssertTrue([plugins containsObject:newPlugin], @"The key-value observing change notification for the WCLFileExtensions's plugins property should have occurred.");
    XCTAssertTrue([fileExtension.plugins containsObject:newPlugin], @"The WCLFileExtension's WCLPlugins should contain the new plugin.");

    // Test removing the file extension

    // Test key-value observing for the plugins property
    [WCLKeyValueObservingTestsHelper observeObject:fileExtension
                                        forKeyPath:WCLFileExtensionPluginsKey
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
                                               plugins = [fileExtension.plugins copy];
                                           }];

    // Test key-value observing for the selected plugin property
    fileExtension.selectedPlugin = newPlugin;
    __block BOOL observedChange = NO;
    [WCLKeyValueObservingTestsHelper observeObject:fileExtension
                                        forKeyPath:kTestFileExtensionSelectedPluginKeyPath
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
                                               observedChange = YES;
                                           }];
    XCTAssertFalse(observedChange, @"The change should not have been observed.");
    
    newPlugin.extensions = kTestExtensionsEmpty;

    // Test the file extensions plugins property changed
    XCTAssertFalse([plugins containsObject:newPlugin], @"The key-value observing change notification for the WCLFileExtensions's plugins property should have occurred.");
    XCTAssertFalse([fileExtension.plugins containsObject:newPlugin], @"The WCLFileExtension's WCLPlugins should not contain the new plugin.");
    
    // Test the file extensions selected plugin property changed
    XCTAssertTrue(observedChange, @"The key-value observing change should have occurred.");
    XCTAssertNil(fileExtension.selectedPlugin, @"The WCLFileExtension's selected plugin should be nil.");

    // Test key was removed from NSUserDefaults
    NSDictionary *fileExtensionToPluginDictionary = [WCLFileExtension fileExtensionToPluginDictionary];
    NSDictionary *fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
    NSString *pluginIdentifierInDictionary = [fileExtensionPluginDictionary valueForKey:kFileExtensionPluginIdentifierKey];
    XCTAssertNil(pluginIdentifierInDictionary, @"The plugin identifier value in the dictionary should be nil.");
}

- (void)testDeletingSelectedPlugin
{
    WCLFileExtension *fileExtension = [[WCLFileExtensionController sharedFileExtensionController] fileExtensionForExtension:kTestExtension];
    WCLPlugin *newPlugin = [self addedPlugin];
    newPlugin.extensions = kTestExtensionsOne;

    fileExtension.selectedPlugin = newPlugin;

    // Test key-value observing for the plugins property
    __block NSArray *plugins = [fileExtension.plugins copy];
    [WCLKeyValueObservingTestsHelper observeObject:fileExtension
                                        forKeyPath:WCLFileExtensionPluginsKey
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
                                       plugins = [fileExtension.plugins copy];
                                   }];
    
    // Test key-value observing for the selected plugin property
    fileExtension.selectedPlugin = newPlugin;
    __block BOOL observedChange = NO;
    [WCLKeyValueObservingTestsHelper observeObject:fileExtension
                                        forKeyPath:kTestFileExtensionSelectedPluginKeyPath
                                           options:NSKeyValueObservingOptionNew
                                   completionBlock:^(NSDictionary *change) {
                                       observedChange = YES;
                                   }];
    XCTAssertFalse(observedChange, @"The change should not have been observed.");
    
    [self deletePlugin:newPlugin];
    
    // Test the file extensions plugins property changed
    XCTAssertFalse([plugins containsObject:newPlugin], @"The key-value observing change notification for the WCLFileExtensions's plugins property should have occurred.");
    XCTAssertFalse([fileExtension.plugins containsObject:newPlugin], @"The WCLFileExtension's WCLPlugins should not contain the new plugin.");
    
    // Test the file extensions selected plugin property changed
    XCTAssertTrue(observedChange, @"The key-value observing change should have occurred.");
    XCTAssertNil(fileExtension.selectedPlugin, @"The WCLFileExtension's selected plugin should be nil.");
    
    // Test key was removed from NSUserDefaults
    NSDictionary *fileExtensionToPluginDictionary = [WCLFileExtension fileExtensionToPluginDictionary];
    NSDictionary *fileExtensionPluginDictionary = [fileExtensionToPluginDictionary valueForKey:fileExtension.extension];
    NSString *pluginIdentifierInDictionary = [fileExtensionPluginDictionary valueForKey:kFileExtensionPluginIdentifierKey];
    XCTAssertNil(pluginIdentifierInDictionary, @"The plugin identifier value in the dictionary should be nil.");
}

// TODO: Test selectedPlugin validation

#pragma mark Helpers

+ (BOOL)plugin:(WCLPlugin *)plugin matchesForFileExtension:(WCLFileExtension *)fileExtension
{
    NSString *extension = fileExtension.extension;

    BOOL containsPlugin = [fileExtension.plugins containsObject:plugin];
    BOOL containsFileExtesion = [plugin.extensions containsObject:extension];
    
    return containsPlugin == containsFileExtesion;
}


@end
