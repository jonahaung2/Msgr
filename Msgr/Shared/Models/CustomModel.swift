//
//  CustomModel.swift
//  Msgr
//
//  Created by Aung Ko Min on 25/12/22.
//

import Foundation
public class Objects: NSObject, NSCoding {

    public var objects: [Object] = []

    enum Key:String {
        case objects = "objects"
    }

    init(objects: [Object]) {
        self.objects = objects
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(objects, forKey: Key.objects.rawValue)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        let mObjects = aDecoder.decodeObject(forKey: Key.objects.rawValue) as! [Object]
        self.init(objects: mObjects)
    }
}

public class Object: NSObject, NSCoding {

    public var location: Int = 0
    public var length: Int = 0

    enum Key:String {
        case location = "location"
        case length = "length"
    }

    init(location: Int, length: Int) {
        self.location = location
        self.length = length
    }

    public override init() {
        super.init()
    }

    public func encode(with aCoder: NSCoder) {

        aCoder.encode(location, forKey: Key.location.rawValue)
        aCoder.encode(length, forKey: Key.length.rawValue)
    }

    public required convenience init?(coder aDecoder: NSCoder) {

        let mlocation = aDecoder.decodeInt32(forKey: Key.location.rawValue)
        let mlength = aDecoder.decodeInt32(forKey: Key.length.rawValue)

        self.init(location: Int(mlocation), length:
            Int(mlength))
    }
}


