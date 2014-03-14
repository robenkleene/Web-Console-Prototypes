//
//  WCLFileExtensionController.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/11/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCLFileExtensionController : NSObject
+ (id)sharedFileExtensionController;
- (NSArray *)fileExtensions;
@end
