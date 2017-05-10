//
//  File.swift
//  OnTheMap
//
//  Created by Kiyoshi Woolheater on 4/4/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import MapKit

class SavedItems: NSObject {
    
    class func sharedInstance() -> SavedItems {
        struct Singleton {
            static var sharedInstance = SavedItems()
        }
        return Singleton.sharedInstance
    }
    
    var array = [people]()
    var annotations = [MKPointAnnotation]()
    
    var sessionID: String? = nil
    var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var previousLocation: Bool? = false
    
}
