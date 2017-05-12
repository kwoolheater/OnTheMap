//
//  addPinController.swift
//  OnTheMap
//
//  Created by Kiyoshi Woolheater on 4/12/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class AddPinController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var website: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var keyboardOnScreen = false
    var lat = CLLocationDegrees()
    var lon = CLLocationDegrees()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel)) 
        
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPinController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        searchButton.layer.cornerRadius = 5
        finishButton.layer.cornerRadius = 5
        finishButton.isEnabled = false
        website.text = ""
        getUserInfo()
        
    }
    
    func cancel() {
        
        performUIUpdatesOnMain {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func goodWebsite(text: String) -> Bool {
        //check website formatting
        if (text.hasPrefix("http://") || text.hasPrefix("https://")) {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        
        if (goodWebsite(text: website.text!) == false) {
            let alertController = UIAlertController(title: nil, message: "Website not formatted properly", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        } else if (goodWebsite(text: website.text!) == true) {
            self.activityIndicator.startAnimating()
            
            let geoCode = CLGeocoder()
            geoCode.geocodeAddressString(location.text!) { (placemarks, error) in
                
                if let placemark = placemarks?[0] {
                    self.lat = (placemark.location?.coordinate.latitude)!
                    self.lon = (placemark.location?.coordinate.longitude)!
                    self.mapView.showAnnotations([MKPlacemark(placemark: placemark)], animated: true)
                    
                    self.activityIndicator.stopAnimating()
                    self.finishButton.isEnabled = true
                    
                } else if error != nil {
                    self.activityIndicator.stopAnimating()
                    print(error)
                }
            }
        }
    }
    
    @IBAction func post(_ sender: Any) {
        
        Client.sharedInstance().postNewLocation(location: location.text!, website: website.text!, latitude: lat as Double, longitude: lon as Double) { (success, error) in
            self.performUIUpdatesOnMain {
                if success {
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showAlert(title: (error?.localizedDescription)!)
                }
            }
        }
    }
    
    func getUserInfo() {
        
        Client.sharedInstance().getUserInfo() { (success, error) in
            self.performUIUpdatesOnMain {
                if (error != nil) {
                    self.showAlert(title: (error?.localizedDescription)!)
                }
            }
        }
    }
    
    
}

extension AddPinController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func buttonAction(sender: UIButton!) {
        var btnsendtag: UIButton = sender
        if btnsendtag.tag == 1 {
            //do anything here
        }
    }
}
