
//
//  DirectoryDuplicateController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/4/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation
import Cocoa

class CopyDirectoryController {
    let copyTempDirectoryURL: NSURL
    let tempDirectoryName: NSString
    var trashDirectoryName: NSString {
        get {
            return tempDirectoryName + " Recovered"
        }
    }
    
    init(tempDirectoryName: String) {
        self.tempDirectoryName = tempDirectoryName
        self.copyTempDirectoryURL = Directory.Caches.URL().URLByAppendingPathComponent(tempDirectoryName)
        self.cleanUp()
    }
    

    // MARK: Public
    
    func cleanUp() {
        self.dynamicType.moveContentsOfURL(copyTempDirectoryURL, toDirectoryInTrashWithName: trashDirectoryName)
    }
    
    func copyItemAtURL(URL: NSURL, completionHandler handler: (URL: NSURL?, error: NSError?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var error: NSError?
            var copiedURL = self.dynamicType.URLOfItemCopiedFromURL(URL, toDirectoryURL: self.copyTempDirectoryURL, error: &error)
            dispatch_async(dispatch_get_main_queue()) {
                handler(URL: copiedURL, error: error)
                if let path = copiedURL?.path {
                    let fileExists = NSFileManager.defaultManager().fileExistsAtPath(path)
                    assert(!fileExists, "The file should not exist")
                } else {
                    assert(false, "Getting the path should succeed")
                }
            }
        }
    }
    

    // MARK: Private Clean Up Helpers

    class func moveContentsOfURL(URL: NSURL, toDirectoryInTrashWithName trashDirectoryName: NSString) {
        var validCachesURL = false
        if let path = URL.path {
            let hasPrefix = path.hasPrefix(Directory.Caches.path())
            validCachesURL = hasPrefix
        }
        if !validCachesURL {
            assert(false, "The URL should be a valid caches URL")
            return
        }

        var foundFilesToRecover = false
        let keys: Array<AnyObject> = [NSURLNameKey]
        let options = NSDirectoryEnumerationOptions.SkipsHiddenFiles | NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants
        if let enumerator = NSFileManager.defaultManager().enumeratorAtURL(URL,
            includingPropertiesForKeys: keys,
            options: options,
            errorHandler: nil)
        {
            while let fileURL = enumerator.nextObject() as? NSURL {
                
                var filename: AnyObject?
                var getNameError: NSError?
                fileURL.getResourceValue(&filename, forKey: NSURLNameKey, error: &getNameError)
                assert(getNameError == nil, "The error should be nil")
                if let filename = filename as? NSString {
                    if filename == trashDirectoryName {
                        continue
                    }

                    let trashDirectoryURL = URL.URLByAppendingPathComponent(trashDirectoryName)
                    if !foundFilesToRecover {
                        var createDirectoryError: NSError?
                        let createDirectorySuccess = createDirectoryIfMissingAtURL(trashDirectoryURL, error: &createDirectoryError)
                        assert(createDirectorySuccess && createDirectoryError == nil, "Creating the directory should succeed")
                        foundFilesToRecover = true
                    }
                    
                    let UUID = NSUUID()
                    let UUIDString = UUID.UUIDString
                    let destinationFileURL = trashDirectoryURL.URLByAppendingPathComponent(UUIDString)
                    var moveError: NSError?
                    let moveSuccess = NSFileManager.defaultManager().moveItemAtURL(fileURL, toURL: destinationFileURL, error: &moveError)
                    assert(moveSuccess && moveError == nil, "The move should succeed")
                }
            }
        }

        if !foundFilesToRecover {
            return
        }

        if let path = URL.path {
            NSWorkspace.sharedWorkspace().performFileOperation(NSWorkspaceRecycleOperation,
                source: path,
                destination: "",
                files: [trashDirectoryName],
                tag: nil)
        } else {
            assert(false, "Getting the path should succeed")
        }
    }
    

    // MARK: Private Duplicate Helpers
    
    private class func URLOfItemCopiedFromURL(URL: NSURL, toDirectoryURL directoryURL: NSURL, error: NSErrorPointer) -> NSURL? {
        // TODO: Should set error instead of assert

        // Setup the destination directory
        var createError: NSError?
        let createDirectorySuccess = createDirectoryIfMissingAtURL(directoryURL, error: &createError)
        assert(createDirectorySuccess && createError == nil, "The create should succeed")
        
        let uuid = NSUUID()
        let uuidString = uuid.UUIDString
        let destinationURL = directoryURL.URLByAppendingPathComponent(uuidString)
        var copyError: NSError?
        let copySuccess = NSFileManager.defaultManager()
            .copyItemAtURL(URL,
                toURL: destinationURL,
                error: &copyError)

        let success = (copySuccess && copyError == nil)
        assert(success, "The copy should succeed")
        
        var copiedURL: NSURL? = success ? destinationURL : nil
        return copiedURL
    }


    // MARK: Private Create Directory Helpers
    
    private class func createDirectoryIfMissingAtPath(path: NSString, error: NSErrorPointer) -> Bool {
        // TODO: Should set error instead of assert
        var isDir: ObjCBool = false
        let exists = NSFileManager.defaultManager()
            .fileExistsAtPath(path,
                isDirectory: &isDir)
        
        if exists {
            let success = isDir ? true : false
            assert(success, "The file should be a directory")
            return success
        }
        
        var error: NSError?
        let createSuccess = NSFileManager.defaultManager()
            .createDirectoryAtPath(path,
                withIntermediateDirectories: true,
                attributes: nil,
                error: &error)
        assert(createSuccess && error == nil, "The create should succeed")
        return createSuccess
    }
    
    private class func createDirectoryIfMissingAtURL(URL: NSURL, error: NSErrorPointer) -> Bool {
        if let path = URL.path {
            var error: NSError?
            return createDirectoryIfMissingAtPath(path, error: &error)
        }
        
        assert(false, "Getting the path should succeed")
        return false
    }
}