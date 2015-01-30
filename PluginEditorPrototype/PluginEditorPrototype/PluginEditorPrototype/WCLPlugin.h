//
//  WCLPlugin.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PluginsManager;

@interface WCLPlugin : NSObject
@property (nonatomic, assign, getter = isDefaultNewPlugin) BOOL defaultNewPlugin;
#pragma mark Validation
- (BOOL)validateExtensions:(id *)ioValue error:(NSError * __autoreleasing *)outError;
- (BOOL)validateName:(id *)ioValue error:(NSError * __autoreleasing *)outError;
@end
