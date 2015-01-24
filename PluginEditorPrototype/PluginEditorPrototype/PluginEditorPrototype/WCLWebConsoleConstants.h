//
//  WCLWebConsoleConstants.h
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 3/9/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

#define kAppName (NSString *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]

#define kPlugInExtension @"wcplugin"
#define kErrorDomain @"com.1percenter.Web-Console"

#define kErrorCodeInvalidPlugin -42

#pragma mark - Plugin Keys

#define kPluginNameKey @"name"

#pragma mark - NSUserDefaults

#define kDefaultNewPluginIdentifierKey @"WCLDefaultNewPluginIdentifier"
#define kDefaultPreferencesSelectedTabKey @"WCLPreferencesSelectedTab"

#pragma mark Defaults

#define kFileExtensionDefaultEnabled NO
#define kFileExtensionToPluginKey @"WCLFileExtensionToPlugin"
#define kFileExtensionEnabledKey @"enabled"
#define kFileExtensionPluginIdentifierKey @"pluginIdentifier"
