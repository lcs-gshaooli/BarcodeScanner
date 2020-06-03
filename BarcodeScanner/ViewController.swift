//
//  ViewController.swift
//  BarcodeScanner
//
//  Created by Gabriela Shaooli on 2020-06-03.
//  Copyright © 2020 Gabriela Shaooli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet var productName: UILabel!
    @IBOutlet var productImage: UIImageView!
    @IBAction func upcField(_ sender: Any) {
    }
    
    @IBAction func productDetailsButton(_ sender: Any) {
        
        // Disable the button
        
        // Define the completion handler that will be invoked to retrieve image data
        let getProductImage: (Data?, URLResponse?, Error?) -> Void = {
            
            (data, response, error) in
            
            // We expect the error to be nil
            guard error == nil else {
                
                // If the error is not nil, print the error
                print("Error calling GET with provided URL.")
                print(error!)
                return
                
            }
            
            // We expect data to have been received
            guard let receivedData = data else {
                
                // If no data was received, report this
                print("Error: did not receive any data.")
                return
            }
            
            // Now attempt to set the UIImage data
            guard let image = UIImage(data: receivedData) else {
                
                // Could not create an image from received data...
                print("Error: Could not create an image from the received data")
                return
            }
            
}
}
}
