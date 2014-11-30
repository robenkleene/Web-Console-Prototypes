//
//  SubprocessFileSystemModifier.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/22/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

class SubprocessFileSystemModifier {

    class func createFileAtPath(path: NSString) {
        let task = NSTask()
        task.launchPath = "/usr/bin/touch"
        task.arguments = [path]
        SubprocessFileSystemModifier.runTask(task)
    }

    class func removeFileAtPath(path: NSString) {
        if (path.rangeOfString("*").location != NSNotFound) {
            assert(false, "The path should not contain a wildcard")
            return
        }
        
        let task = NSTask()
        task.launchPath = "/bin/rm"
        task.arguments = [path]
        SubprocessFileSystemModifier.runTask(task)
    }
    
    class func removeDirectoryAtPath(path: NSString) {
        if (path.rangeOfString("*").location != NSNotFound) {
            assert(false, "The path should not contain a wildcard")
            return
        }

        if (!path.hasPrefix("/var/folders/")) {
            assert(false, "The path should be a temporary directory")
            return
        }

        let task = NSTask()
        task.launchPath = "/bin/rm"
        task.arguments = ["-r", path]
        SubprocessFileSystemModifier.runTask(task)
    }
    
    class func moveFileAtPath(path: NSString, toPath destinationPath: NSString) {
        let task = NSTask()
        task.launchPath = "/bin/mv"
        task.arguments = [path, destinationPath]
        SubprocessFileSystemModifier.runTask(task)
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
    
    class func runTask(task: NSTask) {
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
        }
        
        task.launch()
    }
}
