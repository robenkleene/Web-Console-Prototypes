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

@interface WCLPreferencesWindowController ()
- (IBAction)switchView:(id)sender;
+ (NSViewController *)viewControllerForPreferencePane:(WCLPreferencePane)preferencePane;
- (void)setViewController:(NSViewController *)viewController animated:(BOOL)animated;
+ (NSInteger)preferencePaneForViewController:(NSViewController *)viewController;
+ (void)setupConstraintsForView:(NSView *)insertedView inView:(NSView *)containerView;
+ (NSRect)newFrameForNewContentView:(NSView *)view inWindow:(NSWindow *)window;
@property (nonatomic, assign) WCLPreferencePane preferencePane;
@property (nonatomic, strong) NSViewController *viewController;
@end

@implementation WCLPreferencesWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.

#warning This should be retrieved from storing the currently selected preference tab
        _preferencePane = 0;
    }
    return self;
}

-(void)awakeFromNib
{
    self.viewController = [[self class] viewControllerForPreferencePane:self.preferencePane];
    [[[self window] contentView] setWantsLayer:YES];
}

#pragma mark - NSToolbar

- (IBAction)switchView:(id)sender
{
    WCLPreferencePane preferencePane = (WCLPreferencePane)[sender tag];
    NSViewController *viewController = [[self class] viewControllerForPreferencePane:preferencePane ];

    [self setViewController:viewController animated:YES];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)item
{
    return [item tag] != self.preferencePane;
}

#pragma mark - Properties

- (void)setPreferencePane:(WCLPreferencePane)preferencePane
{
    NSViewController *viewController = [[self class] viewControllerForPreferencePane:preferencePane];
    
    [self setViewController:viewController animated:NO];
}

- (void)setViewController:(NSViewController *)viewController
{
    [self setViewController:viewController animated:NO];
}

- (void)setViewController:(NSViewController *)viewController animated:(BOOL)animated;
{
    void (^switchViewBlock)(NSWindow *window, NSView *contentView) = ^void(NSWindow *window, NSView *contentView) {
        NSView *oldView = _viewController.view;
        NSView *view = viewController.view;
        NSRect frame = [[self class] newFrameForNewContentView:viewController.view inWindow:self.window];
        if ([oldView superview]) {
            [[[[self window] contentView] animator] replaceSubview:oldView with:view];
        } else {
            [[[[self window] contentView] animator] addSubview:view];
        }
        
        [[self class] setupConstraintsForView:view inView:[[self window] contentView]];
        
        [[[self window] animator] setFrame:frame display:YES];
        _viewController = viewController;
        _preferencePane = [[self class] preferencePaneForViewController:viewController];
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

#pragma mark - NSViewController Mappings

+ (NSViewController *)viewControllerForPreferencePane:(WCLPreferencePane)prefencePane
{
    NSViewController *viewController;
    
    switch (prefencePane) {
        case WCLPreferencePaneEnvironment:
            viewController = [[WCLEnvironmentViewController alloc] initWithNibName:kEnvironmentViewControllerNibName bundle:nil];
            break;
        case WCLPreferencePanePlugins:
            viewController = [[WCLPluginViewController alloc] initWithNibName:kPluginViewControllerNibName bundle:nil];
            break;
        default:
            NSAssert(NO, @"No NSViewController for WCLPreferencePane. %li", (long)prefencePane);
            break;
    }
    
    return viewController;
}

+ (NSInteger)preferencePaneForViewController:(NSViewController *)viewController
{
    if ([viewController isKindOfClass:[WCLEnvironmentViewController class]]) return WCLPreferencePaneEnvironment;
    if ([viewController isKindOfClass:[WCLPluginViewController class]]) return WCLPreferencePanePlugins;

    NSAssert(NO, @"No WCLPreferencePane for NSViewController. %@", viewController);
    return -1;
}

@end
