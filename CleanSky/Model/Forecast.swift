//
//  Forecast.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 13/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import UIKit

struct Forecast {
    var day: String //weekday for forecast
    var openWeatherTemperature: Double { //given by OpenWeatherAPI temperature
        willSet {
            convertedTemperature = Temperature(openWeatherMapDegrees: newValue).degrees
        }
    }
    var convertedTemperature: String? //converted to Celsius or Fahrinheit temperature
    var weatherImage: UIImage //icon for forecast
    
    init(day: String, temperature: Double, image: UIImage) {
        self.day = day
        openWeatherTemperature = temperature
        weatherImage = image
    }
}
