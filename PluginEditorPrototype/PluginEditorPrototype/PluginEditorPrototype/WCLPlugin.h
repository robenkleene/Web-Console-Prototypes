//
//  WCLPlugin.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCLPlugin : NSObject
@property (nonatomic, assign, getter = isDefaultNewPlugin) BOOL defaultNewPlugin;
- (BOOL)isPluginManagerDefaultNewPlugin;
@end
