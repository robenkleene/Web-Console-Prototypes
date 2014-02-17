//
//  WCLPlugin.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/16/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WCLPlugin : NSManagedObject

@property (nonatomic, retain) NSString * command;
@property (nonatomic, retain) NSData * fileExtensions;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;

@end
