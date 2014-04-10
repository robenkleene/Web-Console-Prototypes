//
//  WCLTestPlugin.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 4/7/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCLTestPlugin : NSManagedObject
@property (nonatomic, strong) NSArray * extensions;
@property (nonatomic, retain) NSString * command;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, assign, getter = isDefaultNewPlugin) BOOL defaultNewPlugin;
- (NSString *)uniquePluginNameFromName:(NSString *)name;
- (void)renameWithUniqueName;
@end
