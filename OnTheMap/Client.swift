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
    
    func login(email: String, password: String, completionHandlerForLogin: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard (error == nil) else {
                print("There was an error with your request: \(String(describing: error))")
//                let alert = UIAlertController(title: "", message: "There was a network error. Check your connection.", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
                completionHandlerForLogin(false, error as! NSError)
                return
            }
            let range = Range(5 ..< data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(String(describing: newData))'")
                return
            }
            
            guard let session = parsedResult["session"] as? [String:AnyObject] else {
                print("Could not find session in \(String(describing: parsedResult))")
//                let alert = UIAlertController(title: "", message: "Username or Password incorrect.", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
                completionHandlerForLogin(false, error as! NSError)
                return
            }
            
            guard let sessionId = session["id"] as? String else {
                print("Could not find ID in \(String(describing: session))")
//                let alert = UIAlertController(title: "", message: "Username or Password incorrect.", preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
                completionHandlerForLogin(false, error as! NSError)
                return
            }
            
            guard let account = parsedResult["account"] as? [String:AnyObject] else {
                print("Could not find account in \(String(describing: parsedResult))")
                return
            }
            
            guard let uniqueKey = account["key"] as? String else {
                print("Could not find key in \(String(describing: account))")
                return
            }
            SavedItems.sharedInstance().uniqueKey = uniqueKey
            SavedItems.sharedInstance().sessionID = sessionId
            completionHandlerForLogin(true, nil)
        }
        task.resume()
        return task
    }
    
    
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
    
    func postNewLocation (completionHandlerForPost: @escaping(_ success: Bool, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(appDelegate.uniqueKey!)\", \"firstName\": \"\(appDelegate.firstName!)\", \"lastName\": \"\(appDelegate.lastName!)\",\"mapString\": \"\(location.text!)\", \"mediaURL\": \"\(website.text!)\",\"latitude\": \(self.lat), \"longitude\": \(self.lon)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        //"{\"uniqueKey\": \"\(appDelegate.uniqueKey!)\", \"firstName\": \"\(appDelegate.firstName!)\", \"lastName\": \"\(appDelegate.lastName!)\",\"mapString\": \"\(location.text!)\", \"mediaURL\": \"\(website.text!)\",\"latitude\": \(pointAnnotation.coordinate.latitude), \"longitude\": \(pointAnnotation.coordinate.longitude)}"
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
            self.performUIUpdatesOnMain {
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController")
                self.present(controller, animated: true, completion: nil)
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
