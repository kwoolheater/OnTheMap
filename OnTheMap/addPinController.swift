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
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
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
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController")
            self.present(controller, animated: true, completion: nil)
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
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = "\(location.text)"
            request.region = mapView.region
            
            let search = MKLocalSearch(request: request)
            search.start { response, error -> Void in
                if response == nil {
                    let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                self.pointAnnotation = MKPointAnnotation()
                self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: response!.boundingRegion.center.latitude, longitude: response!.boundingRegion.center.longitude)
            
                self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
                self.mapView.centerCoordinate = self.pointAnnotation.coordinate
                self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            
                self.finishButton.isEnabled = true
                self.dismissKeyboard()
            }
        }
    }
    
    @IBAction func post(_ sender: Any) {
           
            let urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
            let url = URL(string: urlString)
            let request = NSMutableURLRequest(url: url!)
            request.httpMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"uniqueKey\": \"\(appDelegate.uniqueKey!)\", \"firstName\": \"\(appDelegate.firstName!)\", \"lastName\": \"\(appDelegate.lastName!)\",\"mapString\": \"\(location.text!)\", \"mediaURL\": \"\(website.text!)\",\"latitude\": \(pointAnnotation.coordinate.latitude), \"longitude\": \(pointAnnotation.coordinate.longitude)}".data(using: String.Encoding.utf8)
            let session = URLSession.shared
            //"{\"uniqueKey\": \"\(appDelegate.uniqueKey!)\", \"firstName\": \"\(appDelegate.firstName!)\", \"lastName\": \"\(appDelegate.lastName!)\",\"mapString\": \"\(location.text!)\", \"mediaURL\": \"\(website.text!)\",\"latitude\": \(pointAnnotation.coordinate.latitude), \"longitude\": \(pointAnnotation.coordinate.longitude)}"
            
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                if error != nil { // Handle error…
                    let alert = UIAlertController(title: "", message: "There was a network error with your request.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
                
                
                self.performUIUpdatesOnMain {
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController")
                    self.present(controller, animated: true, completion: nil)
                }
                
            }
            task.resume()
            
    }
    
    func getUserInfo() {
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(appDelegate.uniqueKey!)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                print("User Info Error")
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(String(describing: newData))'")
                return
            }
            
            guard let user = parsedResult["user"] as? [String: AnyObject] else {
                print("Can't find user in \(parsedResult)")
                return
            }
            
            guard let firstName = user["first_name"] as? String else {
                print("Can't find firstName in \(user)")
                return
            }
            
            guard let lastName = user["last_name"] as? String else {
                print("Can't find lastName in \(user)")
                return
            }

            self.appDelegate.firstName = firstName
            self.appDelegate.lastName = lastName
        }
        task.resume()
        
        
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
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
