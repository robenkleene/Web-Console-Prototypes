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


#define kEnvironmentViewTag 0
#define kPluginViewTag 1
#warning Replace above with enums
//enum	// popup tag choices
//{
//	kProjectView = 0,
//	kClientView = 1,
//};


#define kEnvironmentViewControllerNibName @"WCLEnvironmentViewController"
#define kPluginViewControllerNibName @"WCLPluginViewController"

@interface WCLPreferencesWindowController ()
- (IBAction)switchView:(id)sender;
+ (NSViewController *)viewControllerForTag:(NSInteger)tag;
+ (NSInteger)tagForViewController:(NSViewController *)viewController;
- (void)setViewController:(NSViewController *)viewController animated:(BOOL)animated;
+ (void)setupConstraintsForView:(NSView *)insertedView inView:(NSView *)containerView;
+ (NSRect)newFrameForNewContentView:(NSView *)view inWindow:(NSWindow *)window;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) NSViewController *viewController;
@end

@implementation WCLPreferencesWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.

#warning This should be retrieved from storing the currently selected preference tab
        _tag = 0;
    }
    return self;
}

-(void)awakeFromNib
{
    self.viewController = [[self class] viewControllerForTag:self.tag];
    [[[self window] contentView] setWantsLayer:YES];
}

#pragma mark - NSToolbar

- (IBAction)switchView:(id)sender
{
    NSInteger tag = [sender tag];
    NSViewController *viewController = [[self class] viewControllerForTag:tag];

    [self setViewController:viewController animated:YES];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)item
{
    return [item tag] != self.tag;
}

#pragma mark - Properties

- (void)setTag:(NSInteger)tag
{
    NSViewController *viewController = [[self class] viewControllerForTag:tag];
    
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
        _tag = [[self class] tagForViewController:viewController];
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

+ (NSViewController *)viewControllerForTag:(NSInteger)tag
{
    NSViewController *viewController;
    
    switch (tag) {
        case kEnvironmentViewTag:
            viewController = [[WCLEnvironmentViewController alloc] initWithNibName:kEnvironmentViewControllerNibName bundle:nil];
            break;
        case kPluginViewTag:
            viewController = [[WCLPluginViewController alloc] initWithNibName:kPluginViewControllerNibName bundle:nil];
            break;
        default:
            NSAssert(NO, @"No NSViewController for tag. %li", (long)tag);
            break;
    }
    
    return viewController;
}

+ (NSInteger)tagForViewController:(NSViewController *)viewController
{
    if ([viewController isKindOfClass:[WCLEnvironmentViewController class]]) return kEnvironmentViewTag;
    if ([viewController isKindOfClass:[WCLPluginViewController class]]) return kPluginViewTag;

    NSAssert(NO, @"No tag for NSViewController. %@", viewController);
    return -1;
}

@end
