//
//  WCLFileExtensionController.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/11/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCLFileExtension_old;

@interface WCLFileExtensionController_old : NSObject
+ (instancetype)sharedFileExtensionController;
- (NSArray *)extensions;
- (WCLFileExtension_old *)fileExtensionForExtension:(NSString *)extension;

#pragma mark Required Key-Value Coding To-Many Relationship Compliance
- (NSArray *)fileExtensions;
- (void)insertObject:(WCLFileExtension_old *)fileExtension inFileExtensionsAtIndex:(NSUInteger)index;
- (void)insertFileExtensions:(NSArray *)fileExtensionsArray atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectFromFileExtensionsAtIndex:(NSUInteger)index;
- (void)removeFileExtensionsAtIndexes:(NSIndexSet *)indexes;
@end
