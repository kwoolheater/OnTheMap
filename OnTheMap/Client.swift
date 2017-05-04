//
//  Client.swift
//  OnTheMap
//
//  Created by Kiyoshi Woolheater on 4/12/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import Foundation
import UIKit

class Client: NSObject {
    
    var session = URLSession.shared
    
    private func loadStudentLocations(completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=200&skip=10&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = self.session
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard (error == nil) else {
                print("There was an error with your request: \(String(describing: error))")
                let alert = UIAlertController(title: "", message: "There was a network error with your request.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(String(describing: data))'")
                return
            }
            
            var results: [[String:AnyObject]]
            
            for (key ,value) in parsedResult {
                
                if key == "error" {
                    let alert = UIAlertController(title: "", message: "There was a server error with your request.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
//                    present(alert, animated: true, completion: nil)
                    return
                } else {
                    
                    results = value as! [[String:AnyObject]]
                    
                    for student in results {
                        if let latitude = student["latitude"], let longitude = student["longitude"], let firstName = student["firstName"],let lastName = student["lastName"], let mediaURL = student["mediaURL"] {
                            
                        }
                    }
    
                }
            }
        }
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
//}
//
//
//let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=200&skip=10&order=-updatedAt")!)
//request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
//request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
//
//let session = URLSession.shared
//let task = session.dataTask(with: request as URLRequest) { data, response, error in
//    guard (error == nil) else {
//        print("There was an error with your request: \(String(describing: error))")
//        let alert = UIAlertController(title: "", message: "There was a network error with your request.", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//        return
//    }
//    
//    let parsedResult: [String:AnyObject]!
//    do {
//        parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
//    } catch {
//        print("Could not parse the data as JSON: '\(String(describing: data))'")
//        return
//    }
//    
//    var results: [[String:AnyObject]]
//    
//    for (key ,value) in parsedResult {
//        
//        if key == "error" {
//            let alert = UIAlertController(title: "", message: "There was a server error with your request.", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//            return
//        } else {
//            
//            results = value as! [[String:AnyObject]]
//            
//            for student in results {
//    
//            }
//    }
//    
//}
//task.resume()
}
