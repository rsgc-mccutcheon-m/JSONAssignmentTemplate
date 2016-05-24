//
//  ViewController.swift
//  Bird's-i-View
//
//  Created by Mark on 2016-05-16.
//  Copyright © 2016 Clutch Industries. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation


class ViewController : UIViewController, CLLocationManagerDelegate {
    
    
    let manager : CLLocationManager = CLLocationManager()
    
    var lat : String = ""
    var long : String = ""
    var latDouble : Double = 0.0
    var longDouble : Double = 0.0
    
    
    var imgURL : NSURL = NSURL()
    
    
    @IBOutlet var GPS : UILabel!
    @IBOutlet var date : UILabel!
    
    @IBOutlet weak var Image: UIImageView!
    
    
    // If data is successfully retrieved from the server, we can parse it here
    func parseMyJSON(theData : NSData) {
        
        // De-serializing JSON can throw errors, so should be inside a do-catch structure
        do {
            
            // Do the initial de-serialization
            
            let json = try NSJSONSerialization.JSONObjectWithData(theData, options: NSJSONReadingOptions.AllowFragments) as! AnyObject
            //
                    print("Now, add your parsing code here...")
            
            if let jsonElements = json as? [String : String] {
                
                print(jsonElements)
                
                var numElements = jsonElements.count
                
                if let imgURL = NSURL(string: jsonElements[ "url" ]!) {
                    
                    print(imgURL)
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        
                        let imgData = NSData(contentsOfURL: imgURL)
                        
                        print(imgData)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.Image.image = UIImage(data: imgData!)
                            
                            
                            var gpsText : String = ("lon=" + String(self.longDouble))
                            
                            gpsText += ("&lat=" + String(self.latDouble))
                            
                            self.GPS.text = gpsText
                            
                        });
                    }
                    
                }
                
            }
            
        } catch let error as NSError {
            print ("Failed to load: \(error.localizedDescription)")
        }
        
        
    }
    
    
    // Set up and begin an asynchronous request for JSON data
    func getMyJSON() {
        
        // Define a completion handler
        // The completion handler is what gets called when this **asynchronous** network request is completed.
        //https://api.nasa.gov/planetary/earth/imagery?lon=100.75&lat=1.5&cloud_score=False&api_key=HP7NhvAtAFV4AiPhn1VViToDCcGCco2Qb8kJGcjA
        //we need to first build the url!
        
        var urlString : String = "https://api.nasa.gov/planetary/earth/imagery?"
        
        urlString += ("lon=" + String(longDouble))
        
        urlString += ("&lat=" + String(latDouble))
        
        urlString += ("&cloud_score=False&api_key=HP7NhvAtAFV4AiPhn1VViToDCcGCco2Qb8kJGcjA")
        
        
        // This is where we'd process the JSON retrieved
        let myCompletionHandler : (NSData?, NSURLResponse?, NSError?) -> Void = {
            
            (data, response, error) in
            
            // Cast the NSURLResponse object into an NSHTTPURLResponse objecct
            if let r = response as? NSHTTPURLResponse {
                
                // If the request was successful, parse the given data
                if r.statusCode == 200 {
                    
                    if let d = data {
                        
                        // Parse the retrieved data
                        self.parseMyJSON(d)
                        
                    }
                    
                }
                
            }
            
        }
        
        // Define a URL to retrieve a JSON file from
        
        // Try to make a URL request object
        if let url = NSURL(string: urlString) {
            
            // We have an valid URL to work with
            //print(url)
            
            // Now we create a URL request object
            let urlRequest = NSURLRequest(URL: url)
            
            // Now we need to create an NSURLSession object to send the request to the server
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            
            // Now we create the data task and specify the completion handler
            let task = session.dataTaskWithRequest(urlRequest, completionHandler: myCompletionHandler)
            
            // Finally, we tell the task to start (despite the fact that the method is named "resume")
            task.resume()
            
        } else {
            
            // The NSURL object could not be created
            print("Error: Cannot create the NSURL object.")
            
        }
        
    }
    
    // This is the method that will run as soon as the view controller is created
    override func viewDidLoad() {
        
        // Sub-classes of UIViewController must invoke the superclass method viewDidLoad in their
        // own version of viewDidLoad()
        super.viewDidLoad()
        
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Required method for CLLocationManagerDelegate
    // This method runs when the location of the user has been updated.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // We now have the user's location, so stop finding their location.
        // (Looking for current location is a battery drain)
        self.manager.stopUpdatingLocation()
        
        // Set the most recent location found
        let latestLocation = locations.last
        
        // Format the current location as strings with four decimal places of accuracy
        lat = String(format: "%.4f", latestLocation!.coordinate.latitude)
        long = String(format: "%.4f", latestLocation!.coordinate.longitude)
        
        // Save the current location as a Double
        latDouble = Double(latestLocation!.coordinate.latitude)
        longDouble = Double(latestLocation!.coordinate.longitude)
        
        // Report the location
        print("Location obtained at startup...")
        print("Latitude: \(latDouble)")
        print("Longitude: \(longDouble)")
        
        // Now actually retrieve the cooling centre data
        getMyJSON()
    }
    
    // Required method for CLLocationManagerDelegate
    // This method will be run when there is an error determing the user's location
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        // Report the error
        print("didFailWithError \(error)")
        
    }
    
    
}

