//
//  TestPluginManagerTests.m
//  TestPluginManagerTests
//
//  Created by Roben Kleene on 2/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Cocoa/Cocoa.h>

#import "Web_ConsoleTestsConstants.h"
#import "WCLAppDelegate.h"
#import "WCLPreferencesWindowController.h"

@interface WCLAppDelegate ()
@property (nonatomic, strong) WCLPreferencesWindowController *preferencesWindowController;
- (IBAction)showPreferencesWindow:(id)sender;
@end

@interface WCLPreferencesWindowController ()
@property (nonatomic, assign) NSInteger preferencePane;
@property (nonatomic, strong) NSViewController *viewController;
@end

@interface WCLPreferencesWindowControllerTests : XCTestCase
@property (nonatomic, strong, readonly) WCLAppDelegate *appDelegate;
@property (nonatomic, strong, readonly) WCLPreferencesWindowController *preferencesWindowController;
@property (nonatomic, assign) WCLPreferencePane preferencePane;
@end

#warning Cut & paste job, remove these after merging into Web Console project

NS_INLINE BOOL NSSizeEqualToSize (NSSize size1, NSSize size2)
{
    return (size1.height == size2.height) && (size1.width == size2.width);
}

NS_INLINE BOOL NSPointEqualToPoint (NSPoint point1, NSPoint point2)
{
    return (point1.x == point2.x) && (point1.y == point2.y);
}

NS_INLINE BOOL NSRectEqualToRect (NSRect rect1, NSRect rect2)
{
    return NSPointEqualToPoint(rect1.origin, rect2.origin) && NSSizeEqualToSize(rect1.size, rect2.size);
}


@implementation WCLPreferencesWindowControllerTests

#pragma mark Setup & Teardown

- (void)setUp
{
    [super setUp];
    
    [[self class] clearPreferencesWindowSavedFrame];
    NSRect savedPreferencesWindowFrame = [[self class] savedFrameForPreferencesWindow];
    XCTAssertTrue(NSRectEqualToRect(savedPreferencesWindowFrame, NSZeroRect), @"The saved preferences window frame should equal NSZeroRect.");

    [self.appDelegate showPreferencesWindow:nil];
    XCTAssertTrue([self.preferencesWindowController.window isVisible], @"The WCLPreferncesWindowController's NSWindow should be visible");
    
    self.preferencesWindowController.preferencePane = 0; // Always start with the first preference view visible
}

- (void)tearDown
{
    [self.appDelegate.preferencesWindowController.window performClose:nil];
    XCTAssertFalse([self.preferencesWindowController.window isVisible], @"The WCLPreferncesWindowController's NSWindow should not visible");

    [[self class] clearPreferencesWindowSavedFrame];
    
    [super tearDown];
}

#pragma mark Properties

- (WCLPreferencesWindowController *)preferencesWindowController
{
    return self.appDelegate.preferencesWindowController;
}

- (WCLAppDelegate *)appDelegate
{
    return (WCLAppDelegate *)[NSApp delegate];
}

#pragma mark Tests

- (void)testSwitchingPreferencesViewsByPreferencePane
{
    WCLPreferencePane firstPreferencePane = self.preferencesWindowController.preferencePane;
    NSViewController *firstViewController = self.preferencesWindowController.viewController;
    NSArray *firstSubviews = [self.preferencesWindowController.window.contentView subviews];
    XCTAssertEqual([firstSubviews count], (NSUInteger)1, @"The WCLPreferencesViewController's contentView should have one subview");
    NSView *firstSubview = firstSubviews[0];
    XCTAssertEqualObjects(firstSubview, firstViewController.view, @"The first subview should equal the first NSViewController's NSView.");
    XCTAssertEqual(self.preferencesWindowController.window.title, firstViewController.title, @"The WCLPreferenceWindowController's window should equal the first NSViewController's title.");
    
    self.preferencesWindowController.preferencePane++;
    
    WCLPreferencePane secondPreferencePane = self.preferencesWindowController.preferencePane;
    NSViewController *secondViewController = self.preferencesWindowController.viewController;
    NSArray *secondSubviews = [self.preferencesWindowController.window.contentView subviews];
    XCTAssertEqual([secondSubviews count], (NSUInteger)1, @"The WCLPreferencesViewController's contentView should have one subview");
    NSView *secondSubview = secondSubviews[0];
    XCTAssertEqualObjects(secondSubview, secondViewController.view, @"The second subview should equal the second NSViewController's NSView.");
    XCTAssertEqual(self.preferencesWindowController.window.title, secondViewController.title, @"The WCLPreferenceWindowController's window should equal the second NSViewController's title.");

    XCTAssertNotEqualObjects(firstSubview, secondSubview, @"The first subview should not equal the second subview.");
    XCTAssertNotEqual(firstPreferencePane, secondPreferencePane, @"The first WCLPreferencePane should not equal the second WCLPreferencePane.");
    XCTAssertNotEqualObjects([firstViewController class], [secondViewController class], @"The first NSViewController should not equal the second NSViewController.");
}

- (void)testSwitchingPreferencesViewsHaveCorrectFrames
{
    NSViewController *firstViewController = self.preferencesWindowController.viewController;
    NSRect firstFrame = firstViewController.view.frame;
    
    // Switch to another view and back again, then test that the frames are equal
    self.preferencesWindowController.preferencePane++;
    self.preferencesWindowController.preferencePane--;

    NSViewController *secondViewController = self.preferencesWindowController.viewController;
    NSRect secondFrame = secondViewController.view.frame;
    
    XCTAssertTrue([NSStringFromRect(firstFrame) isEqualToString:NSStringFromRect(secondFrame)], @"The first frame should equal the second frame.");
}

- (void)testResizingPreferencesWindow
{

    NSRect savedFrame = [[self class] savedFrameForPreferencesWindow];
    NSRect windowFrame = [self.preferencesWindowController.window frame];

    if (!NSRectEqualToRect(savedFrame, NSZeroRect)) {
        // Only test if the first rect is equal if we've already stored a frame for this plugin
        // This is still necessary even though we clear the saved frame in setup because showing the preference window
        // saves the frame again.
        BOOL framesMatch = [[self class] windowFrameWithToolbar:windowFrame matchesWindowFrameWithoutToolbar:savedFrame];
        XCTAssertTrue(framesMatch, @"The NSWindow's frame should equal the saved frame.");
    }
    
    // Do the whole destination frame dance here
    NSRect destinationFrame = NSRectEqualToRect(windowFrame, kTestWindowFrame) ? kTestWindowFrameTwo : kTestWindowFrame;
    XCTAssertFalse(NSRectEqualToRect(windowFrame, destinationFrame), @"The NSWindow's frame should not equal the destination frame.");

    // Set the NSWindow's frame to the destination frame
    [self.preferencesWindowController.window setFrame:destinationFrame display:NO];
    
    // Test that the saved frame now equals the destination frame
    savedFrame = [[self class] savedFrameForPreferencesWindow];
    BOOL framesMatch = [[self class] windowFrameWithToolbar:destinationFrame matchesWindowFrameWithoutToolbar:savedFrame];
    XCTAssertTrue(framesMatch, @"The saved frame should equal the destination frame.");
    
    // Close Preferences window
    [self.preferencesWindowController.window performClose:nil];
    self.appDelegate.preferencesWindowController = nil;

    [self.appDelegate showPreferencesWindow:nil];
    windowFrame = self.preferencesWindowController.window.frame;

    framesMatch = [[self class] windowFrameWithToolbar:windowFrame matchesWindowFrameWithoutToolbar:savedFrame];
    XCTAssertTrue(framesMatch, @"The NSWindow's frame should equal the saved frame.");
}

// Test correct prefence pane is restored

+ (BOOL)windowFrameWithToolbar:(NSRect)windowFrameWithToolbar matchesWindowFrameWithoutToolbar:(NSRect)windowFrameWithoutToolbar
{
    // NSWindow's setFrameUsingName: and saveFrameUsingName: methods adjust for the toolbar

    static NSInteger toolbarHeight = 56;
    NSRect comparisonRect = NSMakeRect(windowFrameWithoutToolbar.origin.x,
                                       windowFrameWithoutToolbar.origin.y - toolbarHeight,
                                       windowFrameWithoutToolbar.size.width,
                                       windowFrameWithoutToolbar.size.height + toolbarHeight);
    return NSRectEqualToRect(comparisonRect, windowFrameWithToolbar);
}

#pragma mark - Helpers

+ (NSString *)prefrencesWindowSavedFrameKey
{
    static dispatch_once_t onceToken;
    static NSString *windowFrameKey = nil;
    dispatch_once(&onceToken, ^{
        windowFrameKey = [NSString stringWithFormat:@"NSWindow Frame %@", WCLPreferencesWindowFrameName];
    });

    return windowFrameKey;
}

+ (NSRect)savedFrameForPreferencesWindow
{
    NSString *windowFrameKey = [[self class] prefrencesWindowSavedFrameKey];
    NSString *frameString = [[NSUserDefaults standardUserDefaults] stringForKey:windowFrameKey];
    return NSRectFromString(frameString); // If frame string is nil, returns NSZeroRect
}

+ (void)clearPreferencesWindowSavedFrame
{
    NSString *windowFrameKey = [[self class] prefrencesWindowSavedFrameKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:windowFrameKey];
}

@end
