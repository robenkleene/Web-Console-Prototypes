//
//  WCLDirectoryWatcherTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/20/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class WCLDirectoryWatcherTests: TemporaryDirectoryTestCase {


    func testFileSystemEvent() {
        if let temporaryDirectoryURL = temporaryDirectoryURL {

            println("temporaryDirectoryURL = \(temporaryDirectoryURL)")
            
            // Start watching the directory
            let directoryWatcher = WCLDirectoryWatcher(URL: temporaryDirectoryURL)

            let expectation = expectationWithDescription("File System Event")
            
            // Do something that will create a predictable file system event
            if let testFilePath = temporaryDirectoryURL.path?.stringByAppendingPathComponent("testfile.txt") {
                // Setup the task
                let task = NSTask()
                task.launchPath = "/usr/bin/touch"

                println("\(testFilePath)")
                
                task.arguments = [testFilePath]
                //                [task setCurrentDirectoryPath:directoryPath];
                
                // Standard Output
                task.standardOutput = NSPipe()
                task.standardOutput.fileHandleForReading.readabilityHandler = { (file: NSFileHandle!) -> Void in
                    let data = file.availableData
                    if let output: String! = NSString(data: data, encoding: NSUTF8StringEncoding) {
                        println("standardOutput \(output)")
                    }
                }
                
                task.standardError = NSPipe()
                task.standardError.fileHandleForReading.readabilityHandler = { (file: NSFileHandle!) -> Void in
                    let data = file.availableData
                    if let output: String! = NSString(data: data, encoding: NSUTF8StringEncoding) {
                        println("standardError \(output)")
                    }
                }
                
                task.terminationHandler = { (task: NSTask!) -> Void in
                    task.standardOutput.fileHandleForReading.readabilityHandler = nil
                    task.standardError.fileHandleForReading.readabilityHandler = nil
                    println("Termination handler")
                }
                
                task.launch()
            }
            
            waitForExpectationsWithTimeout(defaultTimeout, handler: { error in
                println("Expectation")
            })

        }
    }

}
