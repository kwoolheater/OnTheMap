//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Kiyoshi Woolheater on 4/10/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import UIKit

class tableViewController: UITableViewController {

    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil), //add action
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: nil) //add action
        ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: nil) //add action
        
    }
    
    
    
    
}
