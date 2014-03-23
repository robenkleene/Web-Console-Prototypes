//
//  WCLTestPluginManager.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#import "WCLPluginManager.h"

#import "WCLFileExtensionToPluginsController.h"

#warning When merging into main project, I'll need to cut and paste the implementation for this into WCLTestPlugin and make the WCLTestPlugin an NSManagedObject subclass
#import "WCLPlugin.h"

#import "WCLPluginManagerController.h"

@class WCLTestPluginDataController;

@interface WCLTestPluginManagerController : WCLPluginManagerController
@end

@interface WCLTestPlugin : WCLPlugin
@end

@interface WCLTestFileExtensionController : WCLFileExtensionToPluginsController
@end

@interface WCLTestPluginManager : WCLPluginManager
@property (nonatomic, strong, readonly) WCLTestPluginDataController *pluginDataController;
@end

