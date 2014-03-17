//
//  WCLPlugin.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/16/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const WCLPluginNameKey;
extern NSString * const WCLPluginFileExtensionsKey;

@interface WCLPlugin : NSManagedObject

@property (nonatomic, strong) NSArray * fileExtensions;
@property (nonatomic, retain) NSString * command;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, assign, getter = isDefaultNewPlugin) BOOL defaultNewPlugin;
@end
