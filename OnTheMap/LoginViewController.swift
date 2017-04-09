//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Kiyoshi Woolheater on 3/31/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var keyboardOnScreen = false
    var appDelegate: AppDelegate!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "tableViewController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func login(_ sender: Any) {
        
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email.text!)\", \"password\": \"\(password.text!)\"}}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
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
            
//            for _ in parsedResult {
//                guard let account = parsedResult["account"] as? [String:AnyObject] else {
//                    print("Could not find account in \(parsedResult).")
//                    return
//                }
//                
//                for (key, value) in account {
//                    if key == "registered" {
//                        print(value)
//                        self.appDelegate.userID = key
//                        success = key as! Int
//                        print(success)
//                    } else {
//                        print("mother ")
//                    }
//                }
//                
//            }
        
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
    }
    
    @IBAction func signUp(_ sender: Any) {
        if let url = URL(string: "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            iconImage.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            iconImage.isHidden = false
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(email)
        resignIfFirstResponder(password)
    }
}

private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
