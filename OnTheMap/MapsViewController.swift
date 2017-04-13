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
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        appDelegate = UIApplication.shared.delegate as! AppDelegate

        loadStudentLocations()
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add)), //add action
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh)) //add action
            ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: nil) //add action
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {return nil}
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            let calloutButton = UIButton(type: .detailDisclosure)
            pinView!.rightCalloutAccessoryView = calloutButton
            pinView!.sizeToFit()
        }
        else {
            pinView!.annotation = annotation
        }
        
        
        return pinView
    }
    
    func loadStudentLocations() {
        LoadingOverlay.shared.showOverlay(view: mapView)
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
                    
                    if let latitude = student["latitude"], let longitude = student["longitude"], let firstName = student["firstName"],let lastName = student["lastName"], let mediaURL = student["mediaURL"] {
                        let coord: MKPointAnnotation = MKPointAnnotation()
                        coord.coordinate = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees)
                        coord.title = ("\(firstName) \(lastName)")
                        coord.subtitle = ("\(mediaURL)")
                        DispatchQueue.main.async(execute: {
                            self.mapView.addAnnotation(coord)
                        })
                    } else {
                        print("fail")
                    }
                }
            }
            
        }
        task.resume()
        LoadingOverlay.shared.hideOverlayView()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation {
            if let url = URL(string: annotation.subtitle!!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
    }
    
    func refresh() {
        //insert delete locations
        loadStudentLocations()
        print("success")
    }
    
    func add() {
        //add if statment for checking location 
        checkForPreviousLocation()
        if previousLocation == false {
            let controller = storyboard!.instantiateViewController(withIdentifier: "addPinController") as! addPinController
            navigationController!.pushViewController(controller, animated: true)
        } else {
            let alert = UIAlertController(title: "Alert", message: "My alert for test", preferredStyle: UIAlertControllerStyle.alert)
        }
    }
    
    var previousLocation: Bool
    
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
                   
                }
            }
            print(parsedResult)
        }
        task.resume()
    }
    
}

