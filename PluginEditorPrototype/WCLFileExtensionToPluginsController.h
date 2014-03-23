//
//  WCLFileExtensionController.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/11/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCLFileExtensionToPluginsController : NSObject
+ (instancetype)sharedFileExtensionController;
- (NSArray *)fileExtensions;
- (void)insertObject:(NSString *)fileExtension inFileExtensionsAtIndex:(NSUInteger)index;
- (void)insertFileExtensions:(NSArray *)fileExtensionsArray atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectFromFileExtensionsAtIndex:(NSUInteger)index;
- (void)removeFileExtensionsAtIndexes:(NSIndexSet *)indexes;
@end
