// weatherManager.swift
// Clima
//
// Created by Martin Mohammed on 02.06.23.
// Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

private let API_BASE_URL = "https://api.openweathermap.org/data/2.5/weather?"
private let API_KEY = OPEN_WEATHER_API_KEY
enum customError: Error{
    case invalidInput(message: String)
}

protocol WeatherManagerDelegate {
    // Requirements
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    
    // Same function, but with different parameter lists -> function overloading!
    func getWeather(cityName: String){
        performHTTPRequest(with: API_BASE_URL, queryParams: ["q": cityName, "units": "metric", "appid": API_KEY])
    }
    
    func getWeather(lon: CLLocationDegrees, lat: CLLocationDegrees){
        performHTTPRequest(with: API_BASE_URL, queryParams: ["lat": String(lat), "lon": String(lon), "units": "metric","appid": API_KEY])
    }
    
    // Perform the HTTP request
    private func performHTTPRequest(with baseUrl: String, queryParams: [String: String]){
        var customURL = baseUrl
        
        // Adding the query parameters to the URL
        for (key, value) in queryParams {
            // Encode the value url appropriately
            
            guard let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                fatalError("There was an error in encoding the value of: \(key) to \(value)")
            }
            customURL += "\(key)=\(encodedValue)&"
        }
        // 1. Create a URL
        if let endURL = URL(string: customURL) {
            // If the URL is successfully created from the provided string, continue
            
            // 2. Create a URLSession - ≈ HTTP client
            /**
             * `data tasks` (receive data over HTTP,
             * `download tasks`
             * `upload tasks` to interact with web services & retrieve data from remote servers
             */
            let session = URLSession(configuration: .default)
            // Create a URLSession object with default configuration
            
            // 3. Create a data task
            let task = session.dataTask(with: endURL){
                // Handle the completion of the data task with a trainling closure
                (data: Data?, urlResponse: URLResponse?,  error: Error?) in
                
                if let error = error {
                    self.delegate?.didFailWithError(error: error)
                    return
                }
                
                // if data is nil, go to the else block and leave the scope
                guard let safeData = data else {
                    fatalError("Fetched data is not defined.")
                }
                // Optional binding
                if let weather = self.parseJSON(safeData) {
                    // 1. --> Limit this WeatherManager to this project...
                    // let weatherVC = WeatherViewController()
                    // weatherVC.didUpdateWeather(weather)
                    
                    // 2. --> Reuse by using DelegatePattern
                    delegate?.didUpdateWeather(self, weather: weather)
                }
                
            }
            // Create a data task using the URLSession, which will perform the network request specified by the URL
            
            // 4. Start the task
            task.resume()
            // Start or resume the data task, triggering the network request
        }
        
    }
    
    
    private func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            // Attempt to decode the weatherData object
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            // Extract the data from the Instance of the Structure
            let cityName = decodedData.name
            let temperature = decodedData.main.temp
            let conditionId = decodedData.weather[0].id
            
            let weatherInstance = WeatherModel(cityName: cityName, temperature: temperature, conditionId: conditionId)
            return weatherInstance
        } catch {
            // An error occurred during decoding
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
