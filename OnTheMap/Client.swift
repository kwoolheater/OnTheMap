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
    var appDelegate: AppDelegate!
    
    func loadStudentLocations(completionHandlerForLocation: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=200&skip=10&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = self.session
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard (error == nil) else {
                print("There was an error with your request: \(String(describing: error))")
                completionHandlerForLocation(false, error as! NSError)
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
//                    let alert = UIAlertController(title: "", message: "There was a server error with your request.", preferredStyle: UIAlertControllerStyle.alert)
//                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
                    let userInfo = [NSLocalizedDescriptionKey: "Student locations not available"]
                    completionHandlerForLocation(false, NSError(domain: "Location Download", code: 1, userInfo: userInfo))
                    return
                } else {
                    
                    results = value as! [[String:AnyObject]]
                    
                    SavedItems.sharedInstance().array = people.personFromResults(results)
                    SavedItems.sharedInstance().annotations = people.annotationsFromPeopleStruct(SavedItems.sharedInstance().array)
                    completionHandlerForLocation(true, nil)
                }
            }
        }
        task.resume()
        
        return task
    }
    
    func checkForPreviousLocation(completionHandlerForPrevLocation: @escaping (_ success: Bool, _ previousLocation: Bool, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let uniqueKey = SavedItems.sharedInstance().uniqueKey!
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error
                completionHandlerForPrevLocation(false, false, error as! NSError)
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
            
            for (_,value) in parsedResult {
                
                results = value as! [[String:AnyObject]]
                
                for student in results {
                    
                    guard student["createdAt"] != nil else {
                        completionHandlerForPrevLocation(true, false, nil)
                        return
                    }
                    
                    completionHandlerForPrevLocation(true, true, nil)
                }
            }
        }
        
        task.resume()
        return task
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    class func sharedInstance() -> Client {
        
        struct Singleton {
            
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }

}
