//
//  PluginEditorPrototypeTests.m
//  PluginEditorPrototypeTests
//
//  Created by Roben Kleene on 2/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Cocoa/Cocoa.h>

#import "WCLAppDelegate.h"
#import "WCLPreferencesWindowController.h"

@interface WCLAppDelegate ()
@property (nonatomic, strong) WCLPreferencesWindowController *preferencesWindowController;
- (IBAction)showPreferencesWindow:(id)sender;
@end

@interface WCLPreferencesWindowController ()
- (IBAction)switchView:(id)sender;
+ (NSViewController *)viewControllerForTag:(NSInteger)tag;
+ (NSInteger)tagForViewController:(NSViewController *)viewController;
- (void)setViewController:(NSViewController *)viewController animated:(BOOL)animated;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) NSViewController *viewController;
@end

@interface WCLPreferencesWindowControllerTests : XCTestCase
@property (nonatomic, strong, readonly) WCLAppDelegate *appDelegate;
@property (nonatomic, strong, readonly) WCLPreferencesWindowController *preferencesWindowController;
@end

@implementation WCLPreferencesWindowControllerTests

#pragma mark - Setup & Teardown

- (void)setUp
{
    [super setUp];

    [self.appDelegate showPreferencesWindow:nil];
    XCTAssertTrue([self.preferencesWindowController.window isVisible], @"The WCLPreferncesWindowController's NSWindow should be visible");
}

- (void)tearDown
{
    [self.appDelegate.preferencesWindowController.window performClose:nil];
    XCTAssertFalse([self.preferencesWindowController.window isVisible], @"The WCLPreferncesWindowController's NSWindow should not visible");

    [super tearDown];
}

#pragma mark - Properties

- (WCLPreferencesWindowController *)preferencesWindowController
{
    return self.appDelegate.preferencesWindowController;
}

- (WCLAppDelegate *)appDelegate
{
    return (WCLAppDelegate *)[NSApp delegate];
}

#pragma mark - Tests

- (void)testSwitchingPreferencesViewsByTag
{
    
    NSInteger firstTag = self.preferencesWindowController.tag;
    NSViewController *firstViewController = self.preferencesWindowController.viewController;
    NSArray *firstSubviews = [self.preferencesWindowController.window.contentView subviews];
    XCTAssertEqual([firstSubviews count], (NSUInteger)1, @"The WCLPreferencesViewController's contentView should have one subview");
    NSView *firstSubview = firstSubviews[0];
    XCTAssertEqualObjects(firstSubview, firstViewController.view, @"The first subview should equal the first NSViewController's NSView.");
    

    self.preferencesWindowController.tag++;
    
    NSInteger secondTag = self.preferencesWindowController.tag;
    NSViewController *secondViewController = self.preferencesWindowController.viewController;
    NSArray *secondSubviews = [self.preferencesWindowController.window.contentView subviews];
    XCTAssertEqual([secondSubviews count], (NSUInteger)1, @"The WCLPreferencesViewController's contentView should have one subview");
    NSView *secondSubview = secondSubviews[0];
    XCTAssertEqualObjects(secondSubview, secondViewController.view, @"The second subview should equal the second NSViewController's NSView.");
    
    XCTAssertNotEqualObjects(firstSubview, secondSubview, @"The first subview should not equal the second subview.");
    XCTAssertNotEqual(firstTag, secondTag, @"The first tag should not equal the second tag.");
    XCTAssertNotEqualObjects([firstViewController class], [secondViewController class], @"The first NSViewController should not equal the second NSViewController.");
}

- (void)testSwitchingPreferencesViews
{
    
    
    
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
