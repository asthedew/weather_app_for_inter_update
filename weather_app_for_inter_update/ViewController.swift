//
//  ViewController.swift
//  weather_app_for_inter_update
//
//  Created by Wang Lupei on 16/9/5.
//  Copyright © 2016年 Lp. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var tempMaxLabel: UILabel!
    // Map View
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var currentLat: String = ""
    var currentLon: String = ""
    
    @IBAction func currentWeatherBt(sender: AnyObject) {
        // Get Current Location Weather Information
        getWeatherInfo("http://api.openweathermap.org/data/2.5/weather?lat=" + currentLat + "&lon=" + currentLon + "&APPID=7e0a5d6414d9ced298fff20557632e52")
    }
    
    @IBAction func getLocationWeatherBt(sender: AnyObject) {
        // Get Locaton Weather Information Which Entered By User
        // If is empty return alert box
        if locationTextField.text == "City Name" {
            setCityAlert()
        } else {
            getWeatherInfo("http://api.openweathermap.org/data/2.5/weather?q=\(locationTextField.text!)&APPID=7e0a5d6414d9ced298fff20557632e52")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Display Current Location on mapView
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span:MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
        // latitude and longtitude
        //latitudeLabel.text = String(center.latitude)
        //longitudeLabel.text = String(center.longitude)
        currentLat = String(center.latitude)
        currentLon = String(center.longitude)
    }

    // Function Used To Get The Weather Information
    // String value called urlString and return type of String
    func getWeatherInfo(urlString: String) {
        // Create A Url Object
        let urlRequest = NSURL(string: urlString)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(urlRequest!) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.displayWeatherInfo(data!)
            })
        }
        task.resume()
    }

    func displayWeatherInfo(weatherInfoData: NSData) {
        
        // Deserialize the data using NSJSONSerialization
        do {
            if let jsonObject = try NSJSONSerialization.JSONObjectWithData(weatherInfoData, options: []) as? NSDictionary {
            
                // Parse JSON Data
                // Set City Name To Label
                if let cityName = jsonObject["name"] as? String {
                    cityNameLabel.text = "City: " + cityName
                }
                // Set Description To Label
                if let weather = jsonObject["weather"] as? [AnyObject] {
                    if let item = weather[0] as? [String: AnyObject] {
                        if let description = item["description"] as? String {
                            descriptionLabel.text = description
                        }
                    }
                }
                // Set Temp, Min Temp And Max Temp To Label
                if let main = jsonObject["main"] as? NSDictionary {
                    if let temp = main["temp"] as? Double {
                        tempLabel.text = "Temp: " + String(format: "%.2f", (temp - 273.15)) + "℃"
                    }
                    if let tempMin = main["temp_min"] as? Double {
                        tempMinLabel.text = "Temp Min: " + String(format: "%.2f", (tempMin - 273.15)) + "℃"
                    }
                    if let tempMax = main["temp_max"] as? Double {
                        tempMaxLabel.text = "Temp Max: " + String(format: "%.2f", (tempMax - 273.15)) + "℃"
                    }
                }
                // Set Latitude And Longitute To The Label
                if let coord = jsonObject["coord"] as? NSDictionary {
                    if let lat = coord["lat"] as? Double {
                        latitudeLabel.text = "Latitude: " + String(lat)
                    }
                    if let lon = coord["lon"] as? Double {
                        longitudeLabel.text = "Longtitude: " + String(lon)
                    }
                }
            }
        }catch let err as NSError {
            print(err.localizedDescription)
        }
    }
    
    // Set Alert
    func setCityAlert() {
        let alert = UIAlertController(title: "", message: "Please Enter City Name", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Action to exit the Alert
        let exitAlert = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(exitAlert)
        
        // Present the cityAlart after tapped the button
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

