//
//  WCLKeyValueObservingTestsHelper.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/17/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCLKeyValueObservingTestsHelper : NSObject
+ (void)observeObject:(id)object
           forKeyPath:(NSString *)keyPath
              options:(NSKeyValueObservingOptions)options
      completionBlock:(void (^)(NSDictionary *change))completionBlock;
@end
