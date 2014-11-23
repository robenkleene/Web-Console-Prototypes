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
