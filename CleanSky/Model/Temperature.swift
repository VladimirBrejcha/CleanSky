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

        if Constants.userDefaults.string(forKey: Constants.temperatureValue) == "f" {
            degrees = String(Int(TemperatureConverter.kelvinToFahrenheit(openWeatherMapDegrees))) + "°"
        } else {
            degrees = String(Int(TemperatureConverter.kelvinToCelsius(openWeatherMapDegrees))) + "°"
        }
    }
}
