//
//  WeatherData.swift
//  Clima
//
//  Created by Martin Mohammed on 02.06.23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let weather: [Weather]
    let main: Main
    let coord: Coordinates
}

struct Main: Codable {
    let temp: Float
}


struct Coordinates: Codable {
    let lon: Float
    let lat: Float
}

struct Weather: Codable{
    let id: Int // encoding weather conditions
    let main: String
}
