//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Kiyoshi Woolheater on 4/10/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import UIKit

class tableViewController: UITableViewController  {

    var appDelegate: AppDelegate!
    var person = [people]()
    var clearTable = false
    
    @IBOutlet var peopleTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add)),
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout)) //add action #selector(logout)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStudentLocations()
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    func loadStudentLocations() {
        // fill array of people with data
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard (error == nil) else {
                print("There was an error with your request: \(String(describing: error))")
                let alert = UIAlertController(title: "", message: "There was a network error with your request.", preferredStyle: UIAlertControllerStyle.alert)
                self.present(alert, animated: true, completion: nil)
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
                    
                    if let firstName = student["firstName"], let lastName = student["lastName"], let mediaURL = student["mediaURL"] {
                        
                        self.person.append(people(firstName: firstName as! String, lastName: lastName as! String, mediaURL: mediaURL as! String))
                        
                    }
                }
            }
            self.performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
        task.resume()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "personCell"
        let person = self.person[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        
        cell?.imageView?.image = #imageLiteral(resourceName: "tableImage")
        cell?.textLabel?.text = "\(person.firstName) \(person.lastName)"
        cell?.detailTextLabel?.text = person.mediaURL
        
        
        return cell!
    }
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if clearTable {
            return 0
        } else {
            return person.count
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = self.person[(indexPath as NSIndexPath).row]
        if let url = URL(string: person.mediaURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func logout() {
        //reset constants
        appDelegate.sessionID = nil
        appDelegate.uniqueKey = nil
        appDelegate.firstName = nil
        appDelegate.lastName = nil
        appDelegate.previousLocation = false
        //push to login controller
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(controller, animated: true, completion: nil)
    }
    
    func refresh() {
        //delete locations on the map
        clearTable = true
        tableView.reloadData()
        clearTable = false
        
        loadStudentLocations()
    }
    
    func add() {
        //add if statment for checking location
        
        if previousLocation == false {
            let controller = storyboard!.instantiateViewController(withIdentifier: "AddPinController") as! AddPinController
            navigationController!.pushViewController(controller, animated: true)
        } else {
            let alert = UIAlertController(title: "", message: "User has already posted a student location. Would you like to overwrite their location?", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "AddPinNavigationController")
                self.present(controller, animated: true, completion: nil)
            }
            
            let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            
            alert.addAction(okAction)
            alert.addAction(DestructiveAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    var previousLocation: Bool? = false
    
    func checkForPreviousLocation() {
        
        let uniqueKey = appDelegate.uniqueKey!
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error
                print("Previous Location Error.")
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
                        self.previousLocation = false
                        return
                    }
                    
                    self.previousLocation = true
                    self.appDelegate.previousLocation = true
                }
            }
        }
        task.resume()
    }
}








