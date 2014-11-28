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

class PluginsDirectoryManagerTestCase: TemporaryPluginTestCase {
    func renameItemAtURL(srcURL: NSURL, toName newFilename: NSString) {
        var error: NSError?
        let dstURL = srcURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(newFilename)
        let moveSuccess = NSFileManager.defaultManager().moveItemAtURL(srcURL, toURL: dstURL, error: &error)
        XCTAssertTrue(moveSuccess, "The move should succeed")
        XCTAssertNil(error, "The error should be nil")
    }
    
    func testPluginPathHelpers() {
        if let temporaryDirectoryPath = temporaryDirectoryURL?.path {
            if let temporaryPlugin = temporaryPlugin {
                let temporaryPluginPath = temporaryPlugin.bundle.bundlePath as NSString

                let compareSubpathFromRangeEqualsSubpath:(path: NSString, range: NSRange, subpath: NSString) -> Bool = {
                    (path, range, subpath) -> Bool in
                    let subpathFromRange = path.substringWithRange(range) as NSString
                    return subpathFromRange.stringByStandardizingPath == subpath.stringByStandardizingPath
                }
                let compareRangesEqual:(rangeOne: NSRange, rangeTwo: NSRange) -> Bool = {
                    (rangeOne, rangeTwo) -> Bool in
                    return rangeOne.location == rangeTwo.location && rangeOne.length == rangeTwo.length
                }

                let testPaths = [temporaryPluginPath as NSString, temporaryPluginPath.stringByAppendingString("/") as NSString]
                let testSubpaths = [temporaryDirectoryPath  as NSString, temporaryDirectoryPath.stringByAppendingString("/") as NSString]
                let testRange = PluginsPathHelper.rangeInPath(testPaths[0], untilSubpath: testSubpaths[0])
                let testPathComponents = PluginsPathHelper.pathComponentsOfPath(testPaths[0], afterSubpath: testSubpaths[0]) as NSArray!
                XCTAssertEqual(testPathComponents.count, 1, "The path components count should equal one")
                let temporaryPluginPathComponent = "\(testPluginName).\(pluginFileExtension)" as NSString
                
                for testPath: NSString in testPaths {
                    for testSubpath: NSString in testSubpaths {
                        let range = PluginsPathHelper.rangeInPath(testPath, untilSubpath: testSubpath)
                        XCTAssertTrue(range.location != NSNotFound, "The range should have been found")
                        XCTAssertTrue(compareSubpathFromRangeEqualsSubpath(path: testPath, range: range, subpath: testSubpath), "The subpath from the range should equal the subpath")
                        XCTAssertTrue(compareRangesEqual(rangeOne: testRange, rangeTwo: range), "The ranges should be equal")
                        let subpath = PluginsPathHelper.subpathFromPath(testPath, untilSubpath: testSubpath) as NSString!
                        XCTAssertEqual(subpath.stringByStandardizingPath, testSubpath.stringByStandardizingPath, "The subpaths should be equal")
                        XCTAssertTrue(PluginsPathHelper.path(testPath, containsSubpath: testSubpath), "The path should contain the subpath")

                        let pathComponents = PluginsPathHelper.pathComponentsOfPath(testPath, afterSubpath: testSubpath) as NSArray!
                        XCTAssertEqual(pathComponents, testPathComponents, "The path components should equal the test path components")
                        XCTAssertEqual(pathComponents[0] as NSString, temporaryPluginPathComponent, "The path component should equal the temporary plugin path component")
                    }
                }
                
                // Test which version should be used, with or without slash
                // Test inverses of having "/" that should also match
                
                // class func rangeInPath(path: NSString, untilSubpath subpath: NSString) -> NSRange

                // class func subpathFromPath(path: NSString, untilSubpath subpath: NSString) -> NSString?

                // class func pathComponentsOfPath(path: NSString, afterSubpath subpath: NSString) -> NSArray?
            
                // class func path(path: NSString, containsSubpath subpath: NSString) -> Bool

                // Test negative cases just like above, things that should fail
            }
        }
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