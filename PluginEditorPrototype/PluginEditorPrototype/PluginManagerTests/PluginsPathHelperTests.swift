//
//  PluginsPathHelper.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/29/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginsPathHelperTestCase: TemporaryPluginTestCase {
    func isRange(range: NSRange, equalToRange comparisonRange: NSRange) -> Bool {
        return range.location == comparisonRange.location && range.length == comparisonRange.length
    }
    
    // Tests normal paths, that paths with stray slashes behave identical
    func testPathsAndPathsWithSlashes() {
        if let temporaryDirectoryPath = temporaryDirectoryURL?.path {
            if let temporaryPlugin = temporaryPlugin {
                let temporaryPluginPath = temporaryPlugin.bundle.bundlePath as NSString
                
                let testPaths = [temporaryPluginPath as NSString, temporaryPluginPath.stringByAppendingString(testSlashPathComponent) as NSString]
                let testSubpaths = [temporaryDirectoryPath  as NSString, temporaryDirectoryPath.stringByAppendingString(testSlashPathComponent) as NSString]
                
                let testRange = PluginsPathHelper.rangeInPath(testPaths[0], untilSubpath: testSubpaths[0])
                let testPathComponents = PluginsPathHelper.pathComponentsOfPath(testPaths[0], afterSubpath: testSubpaths[0]) as NSArray!
                
                XCTAssertEqual(testPathComponents.count, 1, "The path components count should equal one")
                for testPath: NSString in testPaths {
                    for testSubpath: NSString in testSubpaths {
                        
                        let range = PluginsPathHelper.rangeInPath(testPath, untilSubpath: testSubpath)
                        XCTAssertTrue(range.location != NSNotFound, "The range should have been found")
                        let subpathFromRange = testPath.substringWithRange(range) as NSString
                        XCTAssertEqual(subpathFromRange.stringByStandardizingPath, testSubpath.stringByStandardizingPath, "The standardized paths should be equal")
                        
                        XCTAssertTrue(isRange(range, equalToRange: testRange), "The ranges should be equal")
                        
                        let subpath = PluginsPathHelper.subpathFromPath(testPath, untilSubpath: testSubpath) as NSString!
                        XCTAssertEqual(subpath.stringByStandardizingPath, testSubpath.stringByStandardizingPath, "The subpaths should be equal")
                        XCTAssertTrue(PluginsPathHelper.path(testPath, containsSubpath: testSubpath), "The path should contain the subpath")
                        
                        let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
                        XCTAssertEqual(pathComponents, testPathComponents, "The path components should equal the test path components")
                        XCTAssertEqual(pathComponents[0] as NSString, testPluginPathComponent as NSString, "The path component should equal the temporary plugin path component")
                    }
                }
            }
        }
    }
    
    func testMissingPath() {
        if let temporaryDirectoryPath = temporaryDirectoryURL?.path {
            let testPath = testMissingFilePathComponent as NSString
            let testSubpath = temporaryDirectoryPath.stringByAppendingPathComponent(testMissingFilePathComponent) as NSString
            
            let range = PluginsPathHelper.rangeInPath(testPath, untilSubpath: testSubpath)
            XCTAssertTrue(range.location == NSNotFound, "The range should have been found")
            
            let subpath = PluginsPathHelper.subpathFromPath(testPath, untilSubpath: testSubpath)
            XCTAssertNil(subpath, "The subpath should be nil")
            
            XCTAssertFalse(PluginsPathHelper.path(testPath, containsSubpath: testSubpath), "The path should not contain the subpath")
            
            let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
            XCTAssertNil(pathComponents, "The path components should be nil")
        }
    }
    
    // Missing path components should all behave identical to if the path actually exists because handling deleted info dictionaries will be exactly the same this case
    func testMissingPathComponent() {
        if let temporaryDirectoryPath = temporaryDirectoryURL?.path {
            if let temporaryPlugin = temporaryPlugin {
                let temporaryPluginPath = temporaryPlugin.bundle.bundlePath as NSString
                
                let testPath = temporaryPluginPath.stringByAppendingPathComponent(testMissingFilePathComponent) as NSString
                let testSubpath = temporaryDirectoryPath as NSString
                
                let range = PluginsPathHelper.rangeInPath(testPath, untilSubpath: testSubpath)
                XCTAssertTrue(range.location != NSNotFound, "The range should have been found")
                
                let subpathFromRange = testPath.substringWithRange(range) as NSString
                XCTAssertEqual(subpathFromRange.stringByStandardizingPath, testSubpath.stringByStandardizingPath, "The standardized paths should be equal")
                
                let subpath = PluginsPathHelper.subpathFromPath(testPath, untilSubpath: testSubpath) as NSString!
                XCTAssertEqual(subpath.stringByStandardizingPath, testSubpath.stringByStandardizingPath, "The subpaths should be equal")
                XCTAssertTrue(PluginsPathHelper.path(testPath, containsSubpath: testSubpath), "The path should contain the subpath")
                
                let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
                let testPathComponents = [testPluginPathComponent, testMissingFilePathComponent]
                XCTAssertEqual(pathComponents, testPathComponents, "The path component should equal the temporary plugin path component")
            }
        }
    }
    
    func testMissingSubpath() {
        if let temporaryDirectoryPath = temporaryDirectoryURL?.path {
            if let temporaryPlugin = temporaryPlugin {
                let temporaryPluginPath = temporaryPlugin.bundle.bundlePath as NSString
                
                let testPath = temporaryPluginPath as NSString
                let testSubpath = testMissingFilePathComponent as NSString
                
                let range = PluginsPathHelper.rangeInPath(testPath, untilSubpath: testSubpath)
                XCTAssertTrue(range.location == NSNotFound, "The range should have been found")
                
                let subpath = PluginsPathHelper.subpathFromPath(testPath, untilSubpath: testSubpath)
                XCTAssertNil(subpath, "The subpath should be nil")
                
                XCTAssertFalse(PluginsPathHelper.path(testPath, containsSubpath: testSubpath), "The path should not contain the subpath")
                
                let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
                XCTAssertNil(pathComponents, "The path components should be nil")
                
            }
        }
    }
    
    func testMissingSubpathComponent() {
        if let temporaryDirectoryPath = temporaryDirectoryURL?.path {
            if let temporaryPlugin = temporaryPlugin {
                let temporaryPluginPath = temporaryPlugin.bundle.bundlePath as NSString
                
                let testPath = temporaryPluginPath as NSString
                let testSubpath = temporaryDirectoryPath.stringByAppendingPathComponent(testMissingFilePathComponent) as NSString
                
                let range = PluginsPathHelper.rangeInPath(testPath, untilSubpath: testSubpath)
                XCTAssertTrue(range.location == NSNotFound, "The range should have been found")
                
                let subpath = PluginsPathHelper.subpathFromPath(testPath, untilSubpath: testSubpath)
                XCTAssertNil(subpath, "The subpath should be nil")
                
                XCTAssertFalse(PluginsPathHelper.path(testPath, containsSubpath: testSubpath), "The path should not contain the subpath")
                
                let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
                XCTAssertNil(pathComponents, "The path components should be nil")
            }
        }
    }
    
    func testFullSubpathComponent() {
        if let temporaryDirectoryPath = temporaryDirectoryURL?.path {
            if let temporaryPlugin = temporaryPlugin {
                let temporaryPluginPath = temporaryPlugin.bundle.bundlePath as NSString
                
                let testPath = temporaryPluginPath.stringByAppendingPathComponent(testPluginInfoDictionaryPathComponent) as NSString
                let testSubpath = temporaryDirectoryPath.stringByAppendingPathComponent(testPluginPathComponent) as NSString
                let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
                let pathComponent = NSString.pathWithComponents(pathComponents)
                XCTAssertTrue(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, containsSubpathComponent: pathComponent), "The path component should contain the subpath component")
                XCTAssertTrue(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, isPathComponent: pathComponent), "The path component should be the path component")
                // Inverse should also be true
                XCTAssertTrue(PluginsPathHelper.pathComponent(pathComponent, containsSubpathComponent: testPluginInfoDictionaryPathComponent), "The path component should contain the subpath component")
                XCTAssertTrue(PluginsPathHelper.pathComponent(pathComponent, isPathComponent: testPluginInfoDictionaryPathComponent), "The path component should be the path component")
           }
        }
    }
    
    func testPartialSubpathComponent() {
        if let temporaryDirectoryPath = temporaryDirectoryURL?.path {
            if let temporaryPlugin = temporaryPlugin {
                let temporaryPluginPath = temporaryPlugin.bundle.bundlePath as NSString
                
                let testPath = temporaryPluginPath.stringByAppendingPathComponent("Contents") as NSString
                let testSubpath = temporaryDirectoryPath.stringByAppendingPathComponent(testPluginPathComponent) as NSString
                let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
                let pathComponent = NSString.pathWithComponents(pathComponents)
                XCTAssertTrue(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, containsSubpathComponent: pathComponent), "The path component should contain the subpath component")
                XCTAssertFalse(PluginsPathHelper.pathComponent(pathComponent, isPathComponent: testPluginInfoDictionaryPathComponent), "The path component should not be the path component")
            }
        }
    }
    
    func testEmptySubpathComponent() {
        if let temporaryDirectoryPath = temporaryDirectoryURL?.path {
            if let temporaryPlugin = temporaryPlugin {
                let temporaryPluginPath = temporaryPlugin.bundle.bundlePath as NSString
                
                let testPath = temporaryPluginPath as NSString
                let testSubpath = temporaryDirectoryPath.stringByAppendingPathComponent(testPluginPathComponent) as NSString
                let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
                let pathComponent = NSString.pathWithComponents(pathComponents)
                XCTAssertTrue(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, containsSubpathComponent: pathComponent), "The path component should contain the subpath component")
                XCTAssertFalse(PluginsPathHelper.pathComponent(pathComponent, isPathComponent: testPluginInfoDictionaryPathComponent), "The path component not should be the path component")
            }
        }
    }
    
    func testFailingFullSubpathComponent() {
        if let temporaryDirectoryPath = temporaryDirectoryURL?.path {
            if let temporaryPlugin = temporaryPlugin {
                let temporaryPluginPath = temporaryPlugin.bundle.bundlePath as NSString
                
                let testPath = temporaryPluginPath.stringByAppendingPathComponent("Contents/Resources") as NSString
                let testSubpath = temporaryDirectoryPath.stringByAppendingPathComponent(testPluginPathComponent) as NSString
                let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
                let pathComponent = NSString.pathWithComponents(pathComponents)
                XCTAssertFalse(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, containsSubpathComponent: pathComponent), "The path component should contain the subpath component")
                XCTAssertFalse(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, isPathComponent: pathComponent), "The path component should not be the path component")
            }
        }
    }
    
    func testFailingPartialSubpathComponent() {
        if let temporaryDirectoryPath = temporaryDirectoryURL?.path {
            if let temporaryPlugin = temporaryPlugin {
                let temporaryPluginPath = temporaryPlugin.bundle.bundlePath as NSString
                
                let testPath = temporaryPluginPath.stringByAppendingPathComponent("Resources") as NSString
                let testSubpath = temporaryDirectoryPath.stringByAppendingPathComponent(testPluginPathComponent) as NSString
                let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
                let pathComponent = NSString.pathWithComponents(pathComponents)
                XCTAssertFalse(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, containsSubpathComponent: pathComponent), "The path component should contain the subpath component")
                XCTAssertFalse(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, isPathComponent: pathComponent), "The path component should not be the path component")
            }
        }
    }
}
