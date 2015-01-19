//
//  PluginsPathHelper.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/29/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginsPathHelperTestCase: TemporaryPluginsTestCase {
    func isRange(range: NSRange, equalToRange comparisonRange: NSRange) -> Bool {
        return range.location == comparisonRange.location && range.length == comparisonRange.length
    }
    
    // Tests normal paths, that paths with stray slashes behave identical
    func testPathsAndPathsWithSlashes() {
        
        let testPaths = [pluginPath as NSString, pluginPath.stringByAppendingString(testSlashPathComponent) as NSString]
        let testSubpaths = [pluginsDirectoryPath as NSString, pluginsDirectoryPath.stringByAppendingString(testSlashPathComponent) as NSString]
        
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
    
    func testMissingPath() {
        let testPath = testMissingFilePathComponent as NSString
        let testSubpath = pluginsDirectoryPath.stringByAppendingPathComponent(testMissingFilePathComponent) as NSString
        
        let range = PluginsPathHelper.rangeInPath(testPath, untilSubpath: testSubpath)
        XCTAssertTrue(range.location == NSNotFound, "The range should have been found")
        
        let subpath = PluginsPathHelper.subpathFromPath(testPath, untilSubpath: testSubpath)
        XCTAssertNil(subpath, "The subpath should be nil")
        
        XCTAssertFalse(PluginsPathHelper.path(testPath, containsSubpath: testSubpath), "The path should not contain the subpath")
        
        let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
        XCTAssertNil(pathComponents, "The path components should be nil")
    }
    
    // Missing path components should all behave identical to if the path actually exists because handling deleted info dictionaries will be exactly the same this case
    func testMissingPathComponent() {
        
        let testPath = pluginPath.stringByAppendingPathComponent(testMissingFilePathComponent) as NSString
        let testSubpath = pluginsDirectoryPath
        
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
    
    func testMissingSubpath() {
        
        let testPath = pluginPath
        let testSubpath = testMissingFilePathComponent as NSString
        
        let range = PluginsPathHelper.rangeInPath(testPath, untilSubpath: testSubpath)
        XCTAssertTrue(range.location == NSNotFound, "The range should have been found")
        
        let subpath = PluginsPathHelper.subpathFromPath(testPath, untilSubpath: testSubpath)
        XCTAssertNil(subpath, "The subpath should be nil")
        
        XCTAssertFalse(PluginsPathHelper.path(testPath, containsSubpath: testSubpath), "The path should not contain the subpath")
        
        let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
        XCTAssertNil(pathComponents, "The path components should be nil")
    }
    
    func testMissingSubpathComponent() {
        
        let testPath = pluginPath
        let testSubpath = pluginsDirectoryPath.stringByAppendingPathComponent(testMissingFilePathComponent) as NSString
        
        let range = PluginsPathHelper.rangeInPath(testPath, untilSubpath: testSubpath)
        XCTAssertTrue(range.location == NSNotFound, "The range should have been found")
        
        let subpath = PluginsPathHelper.subpathFromPath(testPath, untilSubpath: testSubpath)
        XCTAssertNil(subpath, "The subpath should be nil")
        
        XCTAssertFalse(PluginsPathHelper.path(testPath, containsSubpath: testSubpath), "The path should not contain the subpath")
        
        let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
        XCTAssertNil(pathComponents, "The path components should be nil")
    }
    
    func testFullSubpathComponent() {
        
        let testPath = pluginPath.stringByAppendingPathComponent(testPluginInfoDictionaryPathComponent) as NSString
        let testSubpath = pluginsDirectoryPath.stringByAppendingPathComponent(testPluginPathComponent) as NSString
        let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
        let pathComponent = NSString.pathWithComponents(pathComponents)
        XCTAssertTrue(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, containsSubpathComponent: pathComponent), "The path component should contain the subpath component")
        XCTAssertTrue(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, isPathComponent: pathComponent), "The path component should be the path component")
        // Inverse should also be true
        XCTAssertTrue(PluginsPathHelper.pathComponent(pathComponent, containsSubpathComponent: testPluginInfoDictionaryPathComponent), "The path component should contain the subpath component")
        XCTAssertTrue(PluginsPathHelper.pathComponent(pathComponent, isPathComponent: testPluginInfoDictionaryPathComponent), "The path component should be the path component")
    }
    
    func testPartialSubpathComponent() {
        
        let testPath = pluginPath.stringByAppendingPathComponent("Contents") as NSString
        let testSubpath = pluginsDirectoryPath.stringByAppendingPathComponent(testPluginPathComponent) as NSString
        let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
        let pathComponent = NSString.pathWithComponents(pathComponents)
        XCTAssertTrue(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, containsSubpathComponent: pathComponent), "The path component should contain the subpath component")
        XCTAssertFalse(PluginsPathHelper.pathComponent(pathComponent, isPathComponent: testPluginInfoDictionaryPathComponent), "The path component should not be the path component")
    }
    
    func testEmptySubpathComponent() {
        
        let testPath = pluginPath
        let testSubpath = pluginsDirectoryPath.stringByAppendingPathComponent(testPluginPathComponent) as NSString
        let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
        let pathComponent = NSString.pathWithComponents(pathComponents)
        XCTAssertTrue(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, containsSubpathComponent: pathComponent), "The path component should contain the subpath component")
        XCTAssertFalse(PluginsPathHelper.pathComponent(pathComponent, isPathComponent: testPluginInfoDictionaryPathComponent), "The path component not should be the path component")
    }
    
    func testFailingFullSubpathComponent() {
        
        let testPath = pluginPath.stringByAppendingPathComponent("Contents/Resources") as NSString
        let testSubpath = pluginsDirectoryPath.stringByAppendingPathComponent(testPluginPathComponent) as NSString
        let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
        let pathComponent = NSString.pathWithComponents(pathComponents)
        XCTAssertFalse(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, containsSubpathComponent: pathComponent), "The path component should contain the subpath component")
        XCTAssertFalse(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, isPathComponent: pathComponent), "The path component should not be the path component")
    }
    
    func testFailingPartialSubpathComponent() {
        
        let testPath = pluginPath.stringByAppendingPathComponent("Resources") as NSString
        let testSubpath = pluginsDirectoryPath.stringByAppendingPathComponent(testPluginPathComponent) as NSString
        let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
        let pathComponent = NSString.pathWithComponents(pathComponents)
        XCTAssertFalse(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, containsSubpathComponent: pathComponent), "The path component should contain the subpath component")
        XCTAssertFalse(PluginsPathHelper.pathComponent(testPluginInfoDictionaryPathComponent, isPathComponent: pathComponent), "The path component should not be the path component")
    }
}
