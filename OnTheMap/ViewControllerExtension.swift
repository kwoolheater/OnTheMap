//
//  ViewControllerExtension.swift
//  OnTheMap
//
//  Created by Kiyoshi Woolheater on 5/11/17.
//  Copyright © 2017 Kiyoshi Woolheater. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String) {
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let OKaction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(OKaction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
}
