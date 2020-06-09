//
//  ViewController.swift
//  BarcodeScanner
//
//  Created by Gabriela Shaooli on 2020-06-03.
//  Copyright © 2020 Gabriela Shaooli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var productName: UILabel!
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var upcField: UITextField!
    
    
    var scanField = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Pre-load a UPC number to lookup
        upcField.text = "7501035911208"
        
    }
    
    
    
    @IBAction func scanButton(_ sender: Any) {
        
        performSegue(withIdentifier: scanField, sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! BarcodeViewController
        vc.finalbarcode = self.scanField
    }
    
    
    @IBAction func productDetailsButton(_ sender: Any) {
        
        
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
            
            
            DispatchQueue.main.async {
                // Set the product image
                self.productImage = UIImageView(image: image)
                self.productImage.frame = CGRect(x: 20, y: 325, width: self.view.frame.width - 40, height: 400)
                // Add the image view to the parent view
                self.view.addSubview(self.productImage)
            }
        }
        
        // Define the completion handler that will be invoked when the data is finished being retrieved from the web service / API
        //
        // This closure (closure is just a fancy name for "a block of code" will be invoked when the web service has responded
        let getScannedProductDetails: (Data?, URLResponse?, Error?) -> Void = {
            
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
            
            
            // Now attempt to parse the data as JSON
            guard let json = try? JSON(data: receivedData) else {
                
                print("Error: Could not convert received data to JSON.")
                return
            }
            
            print(json.stringValue)
            // Attempt to extract the values we want from the parsed JSON
            guard let image = json["image"].string,
                let description = json["description"].string else {
                    
                    print("Error: Could not obtain desired data from the Digit Eyes JSON.")
                    return
            }
            
            // Create a structure based on the given data
            let retrievedProduct = Product(imageAddress: image, description: description)
            
            print("\nFrom the view, the image URL is:")
            print(retrievedProduct.imageAddress)
            
            // Try to obtain the description for the product
            print("\nFrom the view, the image description is:")
            print(retrievedProduct.description)
            
            // Set the product name
            // self.productName.text = retrievedProduct.description
            DispatchQueue.main.async { // Correct
                self.productName.text = retrievedProduct.description
                
            }
            
            // Define a URL for the image
            guard let productImageURL = URL(string: retrievedProduct.imageAddress) else {
                
                print("Could not create a URL from image address provided by DigitEyes.")
                return
            }
            
            // Now go get the actual image
            let getProductImageTask = URLSession.shared.dataTask(with: productImageURL, completionHandler: getProductImage)
            
            // Now actually carry out the task
            getProductImageTask.resume()
            
        }
        
        // Get the URL for the Digit-Eyes website, based on the provided UPC code
        let upcLookupURL = getDataLookupURL(forUPC: self.upcField.text!)
        
        // Now actually set up a task that will invoke the completion handler when complete
        let getProductDetailsTask = URLSession.shared.dataTask(with: upcLookupURL, completionHandler: getScannedProductDetails)
        
        // Temporarily set the results label
        self.productName.text = "Working..."
        
        // Now actually carry out the task
        getProductDetailsTask.resume()
        
        print("Button tapped")
        
        
    }
    
}

