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

#define kEnvironmentViewControllerNibName @"WCLEnvironmentViewController"
#define kPluginViewControllerNibName @"WCLPluginViewController"

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
    self.viewController = [self viewControllerForPreferencePane:self.preferencePane];
    [[[self window] contentView] setWantsLayer:YES];
}


#pragma mark NSToolbar

- (IBAction)switchView:(id)sender
{
    WCLPreferencePane preferencePane = (WCLPreferencePane)[sender tag];
    [self setPreferencePane:preferencePane animated:YES];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)item
{
    return [item tag] != self.preferencePane;
}

#pragma mark Properties

- (void)setPreferencePane:(WCLPreferencePane)preferencePane
{
    [self setPreferencePane:preferencePane animated:NO];
}

- (void)setPreferencePane:(WCLPreferencePane)preferencePane animated:(BOOL)animated
{
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
        _preferencePane = [[self class] preferencePaneForViewController:viewController];

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

- (NSViewController *)viewControllerForPreferencePane:(WCLPreferencePane)prefencePane
{
    NSViewController *viewController;
    
    switch (prefencePane) {
        case WCLPreferencePaneEnvironment:
            viewController = self.environmentViewController;
            break;
        case WCLPreferencePanePlugins:
            viewController = self.pluginViewController;
            break;
        default:
            NSAssert(NO, @"No NSViewController for WCLPreferencePane. %li", (long)prefencePane);
            break;
    }
    
    return viewController;
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

+ (NSInteger)preferencePaneForViewController:(NSViewController *)viewController
{
    if ([viewController isKindOfClass:[WCLEnvironmentViewController class]]) return WCLPreferencePaneEnvironment;
    if ([viewController isKindOfClass:[WCLPluginViewController class]]) return WCLPreferencePanePlugins;

    NSAssert(NO, @"No WCLPreferencePane for NSViewController. %@", viewController);
    return -1;
}

@end
