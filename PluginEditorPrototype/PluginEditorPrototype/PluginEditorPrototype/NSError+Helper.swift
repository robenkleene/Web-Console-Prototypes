//
//  NSError+Helper.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/28/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

class ErrorHelper {
    // TODO: EXTENSION BEGIN NSError+Helper
    class func errorWithDescription(description: String, code: Int) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: errorDomain, code: code, userInfo: userInfo)
    }
    // TODO: EXTENSION END NSError+Helper
}
