//
//  people.swift
//  OnTheMap
//
//  Created by Kiyoshi Woolheater on 4/10/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//
import MapKit

struct people {
    
    var objectID: String?
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    
    init(dictionary: [String:AnyObject]) {
        if let latitude = dictionary["latitude"] as? Double {
            self.latitude = CLLocationDegrees(latitude)
        } else {
            self.latitude = 0.0
        }
        
        if let longitude = dictionary["longitude"] as? Double {
            self.longitude = CLLocationDegrees(longitude)
        } else {
            self.longitude = 0.0
        }
        
        if let objectID = dictionary["objectId"] as? String {
            self.objectID = objectID
        } else {
            self.objectID = ""
        }
        
        if let uniqueKey = dictionary["uniqueKey"] as? String {
            self.uniqueKey = uniqueKey
        } else {
            self.uniqueKey = ""
        }
        
        if let firstName = dictionary["firstName"] as? String {
            self.firstName = firstName
        } else {
            self.firstName = ""
        }
        
        if let lastName = dictionary["lastName"] as? String {
            self.lastName = lastName
        } else {
            self.lastName = ""
        }
        
        if let mapString = dictionary["mapString"] as? String {
            self.mapString = mapString
        } else {
            self.mapString = ""
        }
        
        if let mediaURL = dictionary["mediaURL"] as? String {
            self.mediaURL = mediaURL
        } else {
            self.mediaURL = ""
        }
    }
    
    static func personFromResults(_ results: [[String:AnyObject]]) -> [people] {
        
        var peoples = [people]()
        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            peoples.append(people(dictionary: result))
        }
        
        print(peoples.count)
        return peoples
    }
    
    static func annotationsFromPeopleStruct(_ person: [people]) -> [MKPointAnnotation] {
        
        var annotations = [MKPointAnnotation]()
        
        for student in person {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            
            annotations.append(annotation)
        }
        
        return annotations
    }
}
