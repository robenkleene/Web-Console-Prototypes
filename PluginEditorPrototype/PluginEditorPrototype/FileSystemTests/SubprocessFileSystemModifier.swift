//
//  SubprocessFileSystemModifier.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/22/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

class SubprocessFileSystemModifier {

    // MARK: createFileAtPath
    class func createFileAtPath(path: NSString) {
        createFileAtPath(path, handler: nil)
    }
    class func createFileAtPath(path: NSString, handler: (Void -> Void)?) {
        let task = NSTask()
        task.launchPath = "/usr/bin/touch"
        task.arguments = [path]
        SubprocessFileSystemModifier.runTask(task, handler)
    }

    // MARK: createDirectoryAtPath
    class func createDirectoryAtPath(path: NSString) {
        createDirectoryAtPath(path, handler: nil)
    }
    class func createDirectoryAtPath(path: NSString, handler: (Void -> Void)?) {
        let task = NSTask()
        task.launchPath = "/bin/mkdir"
        task.arguments = [path]
        SubprocessFileSystemModifier.runTask(task, handler)
    }

    // MARK: removeFileAtPath
    class func removeFileAtPath(path: NSString) {
        removeFileAtPath(path, handler: nil)
    }
    class func removeFileAtPath(path: NSString, handler: (Void -> Void)?) {
        if path.rangeOfString("*").location != NSNotFound {
            assert(false, "The path should not contain a wildcard")
            return
        }
        let task = NSTask()
        task.launchPath = "/bin/rm"
        task.arguments = [path]
        SubprocessFileSystemModifier.runTask(task, handler)
    }
    
    // MARK: removeDirectoryAtPath
    class func removeDirectoryAtPath(path: NSString) {
        removeDirectoryAtPath(path, handler: nil)
    }
    class func removeDirectoryAtPath(path: NSString, handler: (Void -> Void)?) {
        if path.rangeOfString("*").location != NSNotFound {
            assert(false, "The path should not contain a wildcard")
            return
        }
        if !path.hasPrefix("/var/folders/") {
            assert(false, "The path should be a temporary directory")
            return
        }
        let task = NSTask()
        task.launchPath = "/bin/rm"
        task.arguments = ["-r", path]
        SubprocessFileSystemModifier.runTask(task, handler)
    }

    // MARK: copyDirectoryAtPath
    class func copyDirectoryAtPath(path: NSString, toPath destinationPath: NSString) {
        copyDirectoryAtPath(path, toPath: destinationPath, handler: nil)
    }
    class func copyDirectoryAtPath(path: NSString, toPath destinationPath: NSString, handler: (Void -> Void)?) {
        if path.rangeOfString("*").location != NSNotFound {
            assert(false, "The path should not contain a wildcard")
            return
        }
        if destinationPath.rangeOfString("*").location != NSNotFound {
            assert(false, "The destination path should not contain a wildcard")
            return
        }
        if !path.hasPrefix("/var/folders/") {
            assert(false, "The path should be a temporary directory")
            return
        }
        if !destinationPath.hasPrefix("/var/folders/") {
            assert(false, "The destination path should be a temporary directory")
            return
        }
        if path.hasSuffix("/") {
            assert(false, "The path should not end with a slash")
            return
        }
        if destinationPath.hasSuffix("/") {
            assert(false, "The path should not end with a slash")
            return
        }
        
        let task = NSTask()
        task.launchPath = "/bin/cp"
        task.arguments = ["-R", path, destinationPath]
        SubprocessFileSystemModifier.runTask(task, handler)
    }
    
    // MARK: moveItemAtPath
    class func moveItemAtPath(path: NSString, toPath destinationPath: NSString) {
        moveItemAtPath(path, toPath: destinationPath, handler: nil)
    }
    class func moveItemAtPath(path: NSString, toPath destinationPath: NSString, handler: (Void -> Void)?) {
        let task = NSTask()
        task.launchPath = "/bin/mv"
        task.arguments = [path, destinationPath]
        SubprocessFileSystemModifier.runTask(task, handler)
    }

    // MARK: Helpers
    class func runTask(task: NSTask, handler: (Void -> Void)?) {
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
                assert(false, "There should not be output to standard error")
            }
        }
        
        task.terminationHandler = { (task: NSTask!) -> Void in
            handler?()
            task.standardOutput.fileHandleForReading.readabilityHandler = nil
            task.standardError.fileHandleForReading.readabilityHandler = nil
        }
        
        task.launch()
    }

    class func writeToFileAtPath(path: NSString, contents: String) {
        let echoTask = NSTask()
        echoTask.launchPath = "/bin/echo"
        echoTask.arguments = [contents]
        let pipe = NSPipe()
        echoTask.standardOutput = pipe
        
        let teeTask = NSTask()
        teeTask.launchPath = "/usr/bin/tee"
        teeTask.arguments = [path]
        teeTask.standardInput = pipe
        teeTask.standardOutput = NSPipe() // Suppress stdout
        
        teeTask.launch()
        echoTask.launch()
    }
}
