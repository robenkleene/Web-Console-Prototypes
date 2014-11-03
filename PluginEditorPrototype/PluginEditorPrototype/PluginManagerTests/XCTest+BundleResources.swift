//
//  XCTest+BundleResources.swift
//  FileSystem
//
//  Created by Roben Kleene on 10/1/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation
import XCTest

extension XCTest {
    func pathForResource(name: String?, ofType ext: String?, inDirectory bundlePath: String) -> String? {
        return NSBundle(forClass:self.dynamicType).pathForResource(name, ofType:ext, inDirectory:bundlePath)
    }

    func URLForResource(name: String, withExtension ext: String?) -> NSURL? {
        return NSBundle(forClass:self.dynamicType).URLForResource(name, withExtension:ext)
    }
    
    func URLForResource(name: String, withExtension ext: String?, subdirectory subpath: String?) -> NSURL? {
        return NSBundle(forClass:self.dynamicType).URLForResource(name, withExtension:ext, subdirectory:subpath)
    }
}