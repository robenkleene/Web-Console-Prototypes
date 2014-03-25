//
//  WCLFileExtension.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/23/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLPlugin;

@interface WCLFileExtension : NSObject
- (id)initWithExtension:(NSString *)extension;
@property (nonatomic, strong, readonly) NSString *extension;
@property (nonatomic, strong, readonly) NSMutableArray *plugins;
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;
@property (nonatomic, strong) WCLPlugin *selectedPlugin;

@end
