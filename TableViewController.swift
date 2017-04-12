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
    
    @IBOutlet var peopleTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        LoadingOverlay.shared.showOverlay(view: peopleTableView)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil), //add action
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh)) //add action
        ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: nil) //add action #selector(logout)
        LoadingOverlay.shared.hideOverlayView()
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
        return person.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = self.person[(indexPath as NSIndexPath).row]
        if let url = URL(string: person.mediaURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func refresh() {
        loadStudentLocations()
        print("success")
    }
}








