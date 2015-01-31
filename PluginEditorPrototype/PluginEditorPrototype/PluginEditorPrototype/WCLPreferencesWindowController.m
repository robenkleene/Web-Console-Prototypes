//
//  WCLPreferencesWindowController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPreferencesWindowController.h"

#import "WCLEnvironmentViewController.h"
#import "WCLPluginsViewController.h"
#import "WCLFilesViewController.h"

NSString * const WCLPreferencesWindowFrameName = @"WCLPreferences";

@interface WCLPreferencesWindowController () <NSWindowDelegate>
#pragma mark NSToolbar
- (IBAction)switchView:(id)sender;
#pragma mark Properties
@property (nonatomic, assign) WCLPreferencePane preferencePane;
- (void)setPreferencePane:(WCLPreferencePane)preferencePane animated:(BOOL)animated;
@property (nonatomic, strong) NSViewController *viewController;
- (void)setViewController:(NSViewController *)viewController animated:(BOOL)animated;
+ (void)setupConstraintsForView:(NSView *)insertedView inView:(NSView *)containerView;
+ (NSRect)newFrameForNewContentView:(NSView *)view inWindow:(NSWindow *)window;
#pragma mark NSViewController Mappings
- (NSViewController *)viewControllerForPreferencePane:(WCLPreferencePane)prefencePane;
+ (NSInteger)preferencePaneForViewController:(NSViewController *)viewController;
@property (nonatomic, strong) WCLEnvironmentViewController *environmentViewController;
@property (nonatomic, strong) WCLPluginsViewController *pluginsViewController;
@property (nonatomic, strong) WCLFilesViewController *filesViewController;
@end

@implementation WCLPreferencesWindowController

#pragma mark Life Cycle

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [self setShouldCascadeWindows:NO];
        _preferencePane = [[NSUserDefaults standardUserDefaults] integerForKey:kDefaultPreferencesSelectedTabKey];;
    }
    return self;
}

- (void)awakeFromNib
{
    NSString *itemIdentifier = [self toolbarItemIdentifierForPreferencePane:self.preferencePane];
    if (itemIdentifier) {
        [[[self window] toolbar] setSelectedItemIdentifier:itemIdentifier];
    }


    // This only ends up being used to set the origin because when setViewController gets called the size for the view will be set.
    [self.window setFrameUsingName:WCLPreferencesWindowFrameName];

    self.viewController = [self viewControllerForPreferencePane:self.preferencePane];
    
    // TODO: `setWantsLayer:YES` is required for subview animations, but it causes a display bug
    // on NSToolbarItem's selectable state
    //    [[[self window] contentView] setWantsLayer:YES];
}


#pragma mark NSWindowDelegate

- (void)windowDidMove:(NSNotification *)notification
{
    if (![self.window isVisible]) {
        return;
    }

    [self.window saveFrameUsingName:WCLPreferencesWindowFrameName];
}

- (void)windowDidResize:(NSNotification *)notification
{
    if (![self.window isVisible]) {
        return;
    }
  
    // TODO: It would be nice to not save the frames when an animation is occurring, i.e., so frames are only saved in response to user interaction
    
    [self.window saveFrameUsingName:WCLPreferencesWindowFrameName];
    [self saveViewSize];
}

#pragma mark - Save & Restore Window Frame

- (void)saveViewSize
{
    NSRect viewFrame = [[self.window contentView] frame];
    NSSize viewSize = viewFrame.size;

    NSString *viewSizeName = [[self class] viewSizeNameForViewController:self.viewController];

    [[NSUserDefaults standardUserDefaults] setObject:NSStringFromSize(viewSize)
                                              forKey:viewSizeName];
}

+ (NSSize)savedViewSizeForViewController:(NSViewController *)viewController
{
    NSString *viewSizeName = [[self class] viewSizeNameForViewController:viewController];
    NSString *viewSizeString = [[NSUserDefaults standardUserDefaults] objectForKey:viewSizeName];
    return NSSizeFromString(viewSizeString);
}

+ (NSString *)viewSizeNameForViewController:(NSViewController *)viewController
{
    NSString *title = viewController.title;
    if (!title) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%@ %@", WCLPreferencesWindowFrameName, title];
}

#pragma mark NSToolbar

- (IBAction)switchView:(id)sender
{
    WCLPreferencePane preferencePane = (WCLPreferencePane)[sender tag];
    [self setPreferencePane:preferencePane animated:YES];
}

- (NSString *)toolbarItemIdentifierForPreferencePane:(WCLPreferencePane)preferencePane
{
    NSArray *toolbarItems = [[[self window] toolbar] items];
    for (NSToolbarItem *toolbarItem in toolbarItems) {
        if (toolbarItem.tag == preferencePane) {
            return [toolbarItem itemIdentifier];
        }
    }
    
    return nil;
}

#pragma mark Properties

- (void)setPreferencePane:(WCLPreferencePane)preferencePane
{
    [self setPreferencePane:preferencePane animated:NO];
}

- (void)setPreferencePane:(WCLPreferencePane)preferencePane animated:(BOOL)animated
{
    if (_preferencePane == preferencePane) {
        return;
    }
    
    NSViewController *viewController = [self viewControllerForPreferencePane:preferencePane];
    
    [self setViewController:viewController animated:animated];

    [[NSUserDefaults standardUserDefaults] setInteger:preferencePane forKey:kDefaultPreferencesSelectedTabKey];
}

- (void)setViewController:(NSViewController *)viewController
{
    [self setViewController:viewController animated:NO];
}

- (void)setViewController:(NSViewController *)viewController animated:(BOOL)animated;
{
    NSView *oldView = _viewController.view;
    NSView *view = viewController.view;

    void (^switchViewBlock)(NSWindow *window, NSView *contentView) = ^void(NSWindow *window, NSView *contentView) {

        // Set properties
        _viewController = viewController;
        _preferencePane = [[self class] preferencePaneForViewController:viewController];
        
        // Setup the subview transition
        if ([oldView superview]) {
            [contentView replaceSubview:oldView with:view];
        } else {
            [contentView addSubview:view];
        }

        // Configure the view
        [[self class] setupConstraintsForView:view inView:contentView];
        
        // Restore the frame for the view from NSUserDefaults
        NSSize viewSize = [[self class] savedViewSizeForViewController:viewController];
        if (viewSize.height != 0 &&
            viewSize.width != 0) {
            [viewController.view setFrameSize:viewSize];
        }

        // Setup the frame transition
        NSRect frame = [[self class] newFrameForNewContentView:viewController.view inWindow:window];
        [window setFrame:frame display:YES];

        // Other tweaks
        [window setTitle:[viewController title]];
        [window makeFirstResponder:viewController];
    };
    
    if (animated) {
        [NSAnimationContext beginGrouping];
        switchViewBlock([self.window animator], [self.window.contentView animator]);
        [NSAnimationContext endGrouping];
    } else {
        switchViewBlock(self.window, self.window.contentView);
    }
}

+ (void)setupConstraintsForView:(NSView *)insertedView inView:(NSView *)containerView
{
    [insertedView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *insertedViewVariableBindingsDictionary = NSDictionaryOfVariableBindings(insertedView);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[insertedView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:insertedViewVariableBindingsDictionary];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[insertedView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(insertedView)];
    [containerView addConstraints:horizontalConstraints];
    [containerView addConstraints:verticalConstraints];
}

+ (NSRect)newFrameForNewContentView:(NSView *)view inWindow:(NSWindow *)window
{
    NSRect viewFrame = [window frameRectForContentRect:[view frame]];
    NSRect windowFrame = [window frame];
    NSSize viewSize = viewFrame.size;
    NSSize windowSize = windowFrame.size;
    
    windowFrame.size = viewSize;
    windowFrame.origin.y -= (viewSize.height - windowSize.height); // Preserve the placement of the window
    
    return windowFrame;
}

#pragma mark NSViewController Mappings

+ (NSInteger)preferencePaneForViewController:(NSViewController *)viewController
{
    if ([viewController isKindOfClass:[WCLEnvironmentViewController class]]) {
        return WCLPreferencePaneEnvironment;
    }

    if ([viewController isKindOfClass:[WCLPluginsViewController class]]) {
        return WCLPreferencePanePlugins;
    }

    if ([viewController isKindOfClass:[WCLFilesViewController class]]) {
        return WCLPreferencePaneFiles;
    }
    
    NSAssert(NO, @"No WCLPreferencePane for NSViewController. %@", viewController);
    return -1;
}

- (NSViewController *)viewControllerForPreferencePane:(WCLPreferencePane)preferencePane
{
    NSViewController *viewController;
    
    switch (preferencePane) {
        case WCLPreferencePaneEnvironment:
            viewController = self.environmentViewController;
            break;
        case WCLPreferencePanePlugins:
            viewController = self.pluginsViewController;
            break;
        case WCLPreferencePaneFiles:
            viewController = self.filesViewController;
            break;
        default:
            NSAssert(NO, @"No NSViewController for WCLPreferencePane. %li", (long)preferencePane);
            break;
    }
    
    return viewController;
}

- (WCLFilesViewController *)filesViewController
{
    if (_filesViewController) return _filesViewController;

    _filesViewController = [[WCLFilesViewController alloc] init];
    
    return _filesViewController;
}

- (WCLEnvironmentViewController *)environmentViewController
{
    if (_environmentViewController) return _environmentViewController;

    _environmentViewController = [[WCLEnvironmentViewController alloc] init];
    
    return _environmentViewController;
}

- (WCLPluginsViewController *)pluginsViewController
{
    if (_pluginsViewController) return _pluginsViewController;

    _pluginsViewController = [[WCLPluginsViewController alloc] init];
    
    return _pluginsViewController;
}

@end
