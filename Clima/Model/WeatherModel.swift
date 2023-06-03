//
//  WeatherModel.swift
//  Clima
//
//  Created by Martin Mohammed on 02.06.23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

struct WeatherModel {
    let cityName: String
    let temperature: Float
    let conditionId: Int
    
    //    -------------- COMPUTED PROPERTIES --------------
    // compute on the fly
    var weatherCondition: String {
        get {
            var weatherCondition: String?
            switch self.conditionId{
            case 200...232:
                weatherCondition = "cloud.bolt"
            case 300...321:
                weatherCondition = "cloud.drizzle"
            case 500...531:
                weatherCondition = "cloud.rain"
            case 600...622:
                weatherCondition =  "cloud.snow"
            case 701...781:
                weatherCondition = "cloud.fog"
            case 800:
                weatherCondition = "sun.max"
            case 801...804:
                weatherCondition = "cloud.bolt"
            default:
                fatalError("Error. Not known weatherId: \(conditionId)")
            }
            return weatherCondition ?? "sun.max"
        }
    }
    
    var temperatureString: String {
        get {
            return String(format: "%.1f", temperature)
        }
    }
    
    init(cityName: String, temperature: Float, conditionId: Int) {
        self.cityName = cityName
        self.temperature = temperature
        self.conditionId = conditionId
    }
}
