//
//  Forecast.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 13/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import UIKit

struct Forecast {
    let day: String
    var openWeatherTemperature: Double {
        willSet {
            convertedTemperature = Temperature(openWeatherMapDegrees: newValue).degrees
        }
    }
    var convertedTemperature: String?
    let weatherImage: UIImage
    
    init(day: String, temperature: Double, image: UIImage) {
        self.day = day
        openWeatherTemperature = temperature
        weatherImage = image
    }
}
