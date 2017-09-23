//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Kiyoshi Woolheater on 4/10/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import UIKit

class tableViewController: UITableViewController {

    var clearTable = false
    
    @IBOutlet var peopleTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add)),
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout)) //add action #selector(logout)
        
        loadStudentLocations()
        checkForPreviousLocation()
        
    }
    
    func loadStudentLocations() {
        Client.sharedInstance().loadStudentLocations { (success, error) in
            self.performUIUpdatesOnMain {
                if success {
                    self.tableView.reloadData()
                } else {
                    self.showAlert(title: (error?.localizedDescription)!)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "personCell"
        let person = SavedItems.sharedInstance().array[(indexPath as NSIndexPath).row]
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
            return SavedItems.sharedInstance().array.count
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = SavedItems.sharedInstance().array[(indexPath as NSIndexPath).row]
        if let url = URL(string: person.mediaURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func logout() {
        Client.sharedInstance().deleteSession { (success, error) in
            self.performUIUpdatesOnMain {
                if success {
                    //reset constants
                    SavedItems.sharedInstance().sessionID = nil
                SavedItems.sharedInstance().uniqueKey = nil
                    SavedItems.sharedInstance().firstName = nil
                    SavedItems.sharedInstance().lastName = nil
                    SavedItems.sharedInstance().previousLocation = false
                    
                    //dismiss current view controller
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showAlert(title: (error?.localizedDescription)!)
                }
            }
        }
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
        
        Client.sharedInstance().checkForPreviousLocation { (success, prevLocation, error) in
            if success {
                self.previousLocation = prevLocation
                SavedItems.sharedInstance().previousLocation = prevLocation
            } else {
                self.performUIUpdatesOnMain {
                    self.showAlert(title: (error?.localizedDescription)!)
                }
            }
        }
    }
}








