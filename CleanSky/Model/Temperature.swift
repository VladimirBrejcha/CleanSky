//
//  Temperature.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 11/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import Foundation

struct Temperature {
    let degrees: String
    
    init(openWeatherMapDegrees: Double) {
        if WeatherViewController.userDefaults.string(forKey: "temperatureValue") == "f" {
            degrees = String(TemperatureConverter.kelvinToFahrenheit(openWeatherMapDegrees)) + "°"
        } else {
            degrees = String(TemperatureConverter.kelvinToCelsius(openWeatherMapDegrees)) + "°"
        }
    }
}
