//
//  ViewController.swift
//  OnTheMap
//
//  Created by Kiyoshi Woolheater on 3/31/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import UIKit
import MapKit

class MapsViewController: UIViewController, MKMapViewDelegate {

    var appDelegate: AppDelegate!
    var person = [people]()
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate

        loadStudentLocations()
        checkForPreviousLocation()
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add)),
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
            ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            
            let calloutButton = UIButton(type: .detailDisclosure)
            pinView!.rightCalloutAccessoryView = calloutButton
            pinView!.sizeToFit()
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let annotation = view.annotation {
            if let url = URL(string: annotation.subtitle!!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
    }
    
    func loadStudentLocations() {
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=200&skip=10&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard (error == nil) else {
                print("There was an error with your request: \(String(describing: error))")
                let alert = UIAlertController(title: "", message: "There was a network error with your request.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
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
            
            for (key ,value) in parsedResult {
                
                if key == "error" {
                    let alert = UIAlertController(title: "", message: "There was a server error with your request.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                } else {
                
                results = value as! [[String:AnyObject]]
                
                for student in results {
                    
//                    self.person = people.annotationsFromPeopleStruct(student)
//                    
//                    DispatchQueue.main.async(execute: {
//                        self.mapView.addAnnotation(person.annotations)
//                    })
                }
                }
            }
            
        }
        task.resume()
    }
    
    func logout() {
        //reset constants
        appDelegate.sessionID = nil
        appDelegate.uniqueKey = nil
        appDelegate.firstName = nil
        appDelegate.lastName = nil
        appDelegate.previousLocation = false
        
        //dismiss current view controller
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func refresh() {
        //delete locations on the map
        let annotationsToRemove = mapView.annotations
        mapView.removeAnnotations(annotationsToRemove)
        
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
                print("Previous Location Error!")
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

