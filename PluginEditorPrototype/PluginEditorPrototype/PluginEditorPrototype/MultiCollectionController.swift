//
//  PluginsController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/14/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation
import Cocoa

@objc class MultiCollectionController: NSObject {
    private let nameToObjectController: WCLKeyToObjectController
    private var mutableObjects = NSMutableArray()
    
    init(_ objects: [AnyObject], key: String) {
        self.nameToObjectController = WCLKeyToObjectController(key: key, objects: objects)
        self.mutableObjects.addObjectsFromArray(self.nameToObjectController.allObjects())
        super.init()
    }
    
    // MARK: Accessing Plugins
    
    func objectWithKey(key: String) -> AnyObject? {
        return nameToObjectController.objectWithKey(key)
    }

    // MARK: Convenience
    
    func addObject(object: AnyObject) {
        insertObject(object, inObjectsAtIndex: 0)
    }
    
    func addObjects(objects: [AnyObject]) {
        let range = NSMakeRange(0, objects.count)
        let indexes = NSIndexSet(indexesInRange: range)
        insertObjects(objects, atIndexes: indexes)
    }
    
    func removeObject(object: AnyObject) {
        let index = indexOfObject(object)
        if index != NSNotFound {
            removeObjectFromObjectsAtIndex(index)
        }
    }
    
    func indexOfObject(object: AnyObject) -> Int {
         return mutableObjects.indexOfObject(object)
    }
    
    // MARK: Required Key-Value Coding To-Many Relationship Compliance
    
    func objects() -> NSArray {
        return NSArray(array: mutableObjects)
    }
    
    func insertObject(object: AnyObject, inObjectsAtIndex index: Int) {
        var replacedObject: AnyObject? = nameToObjectController.addObject(object)
        mutableObjects.insertObject(object, atIndex: index)
        if let replacedObject: AnyObject = replacedObject {
            let index = mutableObjects.indexOfObject(replacedObject)
            if index != NSNotFound {
                removeObjectFromObjectsAtIndex(index)
            }
        }
    }
    
    func insertObjects(objects: [AnyObject], atIndexes indexes: NSIndexSet) {
        var replacedObjects: NSArray? = nameToObjectController.addObjectsFromArray(objects)
        mutableObjects.insertObjects(objects, atIndexes: indexes)
        if let replacedObjects: NSArray = replacedObjects {
            let indexes = mutableObjects.indexesOfObjectsPassingTest({
                (object: AnyObject!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
                return replacedObjects.containsObject(object)
            })
            removeObjectsAtIndexes(indexes)
        }
    }

    func removeObjectFromObjectsAtIndex(index: Int) {
        let object: AnyObject = mutableObjects.objectAtIndex(index)
        nameToObjectController.removeObject(object)
        mutableObjects.removeObjectAtIndex(index)
    }
    
    func removeObjectsAtIndexes(indexes: NSIndexSet) {
        let objects = mutableObjects.objectsAtIndexes(indexes)
        nameToObjectController.removeObjectsFromArray(objects)
        mutableObjects.removeObjectsAtIndexes(indexes)
    }

}