//
//  WCLPreferencesWindowController.m
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPreferencesWindowController.h"

#import "WCLEnvironmentViewController.h"
#import "WCLPluginViewController.h"
#import "WCLFilesViewController.h"

#define kEnvironmentViewControllerNibName @"WCLEnvironmentViewController"
#define kPluginViewControllerNibName @"WCLPluginViewController"
#define kFilesViewControllerNibName @"WCLFilesViewController"

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
@property (nonatomic, strong) WCLPluginViewController *pluginViewController;
@property (nonatomic, strong) WCLFilesViewController *filesViewController;
@end

@implementation WCLPreferencesWindowController

#pragma mark Life Cycle

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {        
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

    self.viewController = [self viewControllerForPreferencePane:self.preferencePane];

    [[[self window] contentView] setWantsLayer:YES];
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
    NSRect frame = [[self class] newFrameForNewContentView:viewController.view inWindow:self.window];

    void (^switchViewBlock)(NSWindow *window, NSView *contentView) = ^void(NSWindow *window, NSView *contentView) {
        if ([oldView superview]) {
            [[[[self window] contentView] animator] replaceSubview:oldView with:view];
        } else {
            [[[[self window] contentView] animator] addSubview:view];
        }
        
        [[self class] setupConstraintsForView:view inView:[[self window] contentView]];
        
        [[[self window] animator] setFrame:frame display:YES];
        _viewController = viewController;
        WCLPreferencePane preferencePane = [[self class] preferencePaneForViewController:viewController];
        _preferencePane = preferencePane;

        [[self window] setTitle:[viewController title]];
        
        [self.window makeFirstResponder:viewController];
    };
    
    if (animated) {
        [NSAnimationContext beginGrouping];
        switchViewBlock([self.window animator], [self.window.contentView animator]);
        [NSAnimationContext endGrouping];
    } else {
        switchViewBlock(self.window, [self.window.contentView animator]);
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

    if ([viewController isKindOfClass:[WCLPluginViewController class]]) {
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
            viewController = self.pluginViewController;
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
    
    _filesViewController = [[WCLFilesViewController alloc] initWithNibName:kFilesViewControllerNibName bundle:nil];
    
    return _filesViewController;
}

- (WCLEnvironmentViewController *)environmentViewController
{
    if (_environmentViewController) return _environmentViewController;
    
    _environmentViewController = [[WCLEnvironmentViewController alloc] initWithNibName:kEnvironmentViewControllerNibName bundle:nil];
    
    return _environmentViewController;
}

- (WCLPluginViewController *)pluginViewController
{
    if (_pluginViewController) return _pluginViewController;
    
    _pluginViewController = [[WCLPluginViewController alloc] initWithNibName:kPluginViewControllerNibName bundle:nil];
    
    return _pluginViewController;
}

@end
