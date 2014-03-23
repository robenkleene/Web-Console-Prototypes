//
//  WCLFileExtensionController.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/11/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLFileExtension;

@interface WCLFileExtensionController : NSObject
+ (instancetype)sharedFileExtensionController;
- (NSArray *)extensions;
- (NSArray *)fileExtensions;
- (void)insertObject:(WCLFileExtension *)fileExtension inFileExtensionsAtIndex:(NSUInteger)index;
- (void)insertFileExtensions:(NSArray *)fileExtensionsArray atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectFromFileExtensionsAtIndex:(NSUInteger)index;
- (void)removeFileExtensionsAtIndexes:(NSIndexSet *)indexes;
@end
