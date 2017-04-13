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
    
    
    
    /*func taskForPosting (_ method: String, completionHandlerForPOST: @escaping () -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: method)
        request.httpMethod = "POST"
        //add values is different
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard (error == nil) else {
                print("There was an error with your request: \(String(describing: error))")
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
                print("Could not find session in \(String(describing: parsedResult["session"]))")
                return
            }
            
            guard let sessionId = session["id"] as? String else {
                print("Could not find ID in \(String(describing: session["id"]))")
                return
            }
            self.appDelegate.sessionID = sessionId
            self.completeLogin()
        }
        task.resume()
        
        return task
    }*/
    
}
