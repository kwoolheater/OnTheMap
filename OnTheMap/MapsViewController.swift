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

    var person = [people]()
    var annotations = [MKPointAnnotation]()
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadStudentLocations()
        checkForPreviousLocation()
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add)),
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
            ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
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
        Client.sharedInstance().loadStudentLocations { (success, error) in
            self.performUIUpdatesOnMain {
                if success {
                    self.mapView.addAnnotations(SavedItems.sharedInstance().annotations)
                } else {
                    self.showAlert(title: (error?.localizedDescription)!)
                }
            }
        }
    }
    
    func logout() {
        //reset constants
        SavedItems.sharedInstance().sessionID = nil
        SavedItems.sharedInstance().uniqueKey = nil
        SavedItems.sharedInstance().firstName = nil
        SavedItems.sharedInstance().lastName = nil
        SavedItems.sharedInstance().previousLocation = false
        
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

