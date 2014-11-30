//
//  PluginsDirectoryManagerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation
import XCTest

//class PluginsDirectoryManagerExpectationHelper: PluginsDirectoryManagerDelegate {
//    let expectation: XCTestExpectation
//    init(_ expectation: XCTestExpectation) {
//        self.expectation = expectation
//    }
//
//    func directoryWillChange(directoryURL: NSURL) {
//        println("Fulfilled")
//        expectation.fulfill()
//    }
//}

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
    
    // Mssing path components should all behave identical to if the path actually exists because handling deleted info dictionaries will be exactly this case
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
                
                let testPath = temporaryPluginPath.stringByAppendingPathComponent(testPathComponent) as NSString
                let testSubpath = temporaryDirectoryPath.stringByAppendingPathComponent(testPluginPathComponent) as NSString
                let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
                let pathComponent = NSString.pathWithComponents(pathComponents)
                XCTAssertTrue(PluginsPathHelper.pathComponent(pathComponent, containsSubpathComponent: testPathComponent), "The path component should contain the subpath component")
                // Inverse should also be true
                XCTAssertTrue(PluginsPathHelper.pathComponent(testPathComponent, containsSubpathComponent: pathComponent), "The path component should contain the subpath component")
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
                XCTAssertTrue(PluginsPathHelper.pathComponent(pathComponent, containsSubpathComponent: testPathComponent), "The path component should contain the subpath component")
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
                XCTAssertTrue(PluginsPathHelper.pathComponent(pathComponent, containsSubpathComponent: testPathComponent), "The path component should contain the subpath component")
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
                XCTAssertFalse(PluginsPathHelper.pathComponent(pathComponent, containsSubpathComponent: testPathComponent), "The path component should contain the subpath component")
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
                XCTAssertFalse(PluginsPathHelper.pathComponent(pathComponent, containsSubpathComponent: testPathComponent), "The path component should contain the subpath component")
            }
        }
    }
}


class PluginsDirectoryManagerTestCase: TemporaryPluginTestCase {
    func renameItemAtURL(srcURL: NSURL, toName newFilename: NSString) {
        var error: NSError?
        let dstURL = srcURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(newFilename)
        let moveSuccess = NSFileManager.defaultManager().moveItemAtURL(srcURL, toURL: dstURL, error: &error)
        XCTAssertTrue(moveSuccess, "The move should succeed")
        XCTAssertNil(error, "The error should be nil")
    }
    


    func testMovePlugin() {
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            if let temporaryPlugin = temporaryPlugin {
                let pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: temporaryDirectoryURL)

                // Move the plugin
                var error: NSError?
                let pluginPath = temporaryPlugin.bundle.bundlePath
                let newPluginFilename = temporaryPlugin.identifier
                let newPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(newPluginFilename)

                println("oldPluginPath = \(pluginPath)")
                println("newPluginPath = \(newPluginPath)")
                
//                SubprocessFileSystemModifier.moveFileAtPath(pluginPath, toPath: newPluginPath)
                
//                let moveSuccess = NSFileManager.defaultManager().moveItemAtURL(oldPluginPath, toURL: newPluginURL, error: &error)
//                XCTAssertTrue(moveSuccess, "The move should succeed")
//                XCTAssertNil(error, "The error should be nil")

//                // Move it again
//                error = nil
//                let moveSuccess2 = NSFileManager.defaultManager().moveItemAtURL(newPluginURL, toURL: oldPluginURL, error: &error)
//                XCTAssertTrue(moveSuccess2, "The move should succeed")
//                XCTAssertNil(error, "The error should be nil")

//                let expectation = expectationWithDescription("Plugins Directory Event")
//                waitForExpectationsWithTimeout(defaultTimeout, handler: { error in
//                    println("Expectation")
//                })
                
                // TODO: Instantiate a plugin directory manager for the parent directory
                // TODO: Move the `info.plist`
                // TODO: Confirm that the right call backs fire
            }
        }
    }

    func testRenameInfoDictionaryPath() {
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            if let temporaryPlugin = temporaryPlugin {
                let pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: temporaryDirectoryURL)
                
//                let expectation = expectationWithDescription("Plugins Directory Event")
                
                // Move the plist
//                var error: NSError?
//                let oldInfoDictionaryURL = temporaryPlugin.infoDictionaryURL
//                let newInfoDictionaryFilename = temporaryPlugin.identifier
//                renameItemAtURL(oldInfoDictionaryURL, toName: newInfoDictionaryFilename)
                
                
                // TODO: Move it again
                
//                waitForExpectationsWithTimeout(defaultTimeout, handler: { error in
//                    println("Expectation")
//                })
            }
        }
    }

    // TODO: Gets notified moving the file
    // TODO: Gets notified modifying the plist
}