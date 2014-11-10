//
//  PluginsDirectoryManager.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

@objc protocol PluginsDirectoryManagerDelegate {
    optional func directoryWillChange(directoryURL: NSURL)
}

class PluginsDirectoryManager: WCLPluginsDirectoryManager {
    var delegate: PluginsDirectoryManagerDelegate?

    override init(pluginsDirectoryURL: NSURL) {
        super.init(pluginsDirectoryURL: pluginsDirectoryURL)
//        watchURL(pluginsDirectoryURL)
    }
//    func watchPath(path: String) {
//        if let path = path as NSString? {
//            let fd = open(path.fileSystemRepresentation, O_EVTONLY)
//            
//            let source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,
//                UInt(fd),
//                DISPATCH_VNODE_DELETE |
//                    DISPATCH_VNODE_WRITE |
//                    DISPATCH_VNODE_EXTEND |
//                    DISPATCH_VNODE_ATTRIB |
//                    DISPATCH_VNODE_LINK |
//                    DISPATCH_VNODE_RENAME |
//                DISPATCH_VNODE_REVOKE,
//                DISPATCH_TARGET_QUEUE_DEFAULT)
//            
//            dispatch_source_set_event_handler(source, {
//                let data = UInt(dispatch_source_get_data(source))
//                if (data & DISPATCH_VNODE_DELETE > 0) {
//                    println("DISPATCH_VNODE_DELETE")
//                    dispatch_source_cancel(source);
//                }
//                
//                if (data & DISPATCH_VNODE_WRITE > 0) {
//                    println("DISPATCH_VNODE_WRITE")
//                }
//                
//                if (data & DISPATCH_VNODE_EXTEND > 0) {
//                    println("DISPATCH_VNODE_EXTEND")
//                }
//                
//                if (data & DISPATCH_VNODE_ATTRIB > 0) {
//                    println("DISPATCH_VNODE_ATTRIB")
//                }
//                
//                if (data & DISPATCH_VNODE_LINK > 0) {
//                    println("DISPATCH_VNODE_LINK")
//                }
//                
//                if (data & DISPATCH_VNODE_RENAME > 0) {
//                    println("DISPATCH_VNODE_RENAME")
//                }
//                
//                if (data & DISPATCH_VNODE_REVOKE > 0) {
//                    println("DISPATCH_VNODE_REVOKE")
//                }
//
//                println("Got here");
//            })
//            
//            dispatch_source_set_cancel_handler(source, {
//                close(fd)
//                return
//            })
//            
//            dispatch_resume(source);
//        }
//    }
//
//    func watchURL(url: NSURL) {
//        if let path = url.path {
//            watchPath(path)
//        }
//    }
}


