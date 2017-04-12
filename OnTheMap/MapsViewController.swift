//
//  ViewController.swift
//  OnTheMap
//
//  Created by Kiyoshi Woolheater on 3/31/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    var appDelegate: AppDelegate!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        appDelegate = UIApplication.shared.delegate as! AppDelegate

        loadStudentLocations()
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil), //add action
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh)) //add action
            ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: nil) //add action
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
                        self.mapView.addAnnotation(coord)
                        
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
            if let url = URL(string: annotation.subtitle as! String) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
    }
    
    func refresh() {
        loadStudentLocations()
        print("success")
    }
    
}

