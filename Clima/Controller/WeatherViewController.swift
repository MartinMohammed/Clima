
//
// ViewController.swift
// Clima
//
// Created by Angela Yu on 01/09/2019.
// Copyright © 2019 App Brewery. All rights reserved.
//

// API key for OpenWeatherAPI
// Endpoint for weather data: "https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}"

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CoreLocation.CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // Set up the text field delegate to receive events from text field
        // Set the current view controller as the delegate for the search text field
        searchTextField.delegate = self
        
        // Receive notifications, events by the WeatherManager
        self.weatherManager.delegate = self
        
        // Receive location from LocationManager
        locationManager.delegate = self
        self.getLocation()
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        // Get the current interface style
        let currentInterfaceStyle = traitCollection.userInterfaceStyle
        
        // Toggle the interface style
        if currentInterfaceStyle == .light {
            // Switch to dark mode
            overrideUserInterfaceStyle = .dark
        } else {
            // Switch to light mode
            overrideUserInterfaceStyle = .light
        }
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        // Get current location, and then the delegate method gets called
        // update the weather data!
        self.getLocation()
    }
    
}


// MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate{
    @IBAction func searchPressed(_ sender: UIButton) {
        // Dismiss the keyboard
        searchTextField.endEditing(true)
    }
    
    // Asks the delegate if the text field should process the pressing of the return button (≈ event listener)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Programmatically trigger the search button action
        searchButton.sendActions(for: UIControl.Event.touchUpInside)
        
        // Allow the text field to process the return button press
        return true
    }
    
    // Determines if the text field should end editing when the user tries to deselect it
    // For example, when clicking on another button
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // Perform some validation...
        if textField.text != "" {
            return true // Allow ending editing
        } else {
            // Validation failed - provide user feedback
            textField.placeholder = "Type something: "
            return false
        }
    }
    
    // Called when the text field finishes editing
    // The text field notifies the view controller (delegate) that the user stopped editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        let city: String = textField.text!
        getWeather(city)
        
        textField.text = ""
    }
}

// MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate{
    func getWeather(_ cityName: String) {
        // Fetch weather data from OpenWeatherAPI
        let trimmedCityName = cityName.trimmingCharacters(in: .whitespacesAndNewlines)        
        weatherManager.getWeather(cityName: trimmedCityName)
    }
    
    
    
    //    --------------- METHODS CALLED BY WeatherManager ---------------
    // Notify if data is fetched from API
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            // Update the UI by the meain thread after the async operation has ended
            self.cityLabel.text = weather.cityName
            self.temperatureLabel.text = weather.temperatureString
            // expects a system symbol image - the name of SF Icon
            self.conditionImageView.image = UIImage(systemName: weather.weatherCondition)
        }
    }
    
    // Notify when error happened in the fetch process
    func didFailWithError(error: Error) {
        print(error)
    }
    
}


// MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get most recent location and most accurate
        if let currentLocation = locations.last {
            /**
             method call that stops the location updates being provided by the `CLLocationManager` instance referred to by the variable `locationManager`.
             */
            locationManager.stopUpdatingLocation()
            let lat = currentLocation.coordinate.latitude
            let long = currentLocation.coordinate.longitude
            weatherManager.getWeather(lon: long, lat: lat)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func getLocation(){
        // Ask for geolocation permission
        locationManager.requestWhenInUseAuthorization()
        /**
         Only one location fix is reported to the delegate, after which location services are stopped
         */
        locationManager.requestLocation()
        // In case you want to monitor their location -> `startUpdatingLocation`
    }
}
