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
    var forecastTempDegrees: Double
    var temperature: String
    let image: UIImage
    
    init(day: String, forecastTempDegrees: Double, temperature: String? = nil, image: UIImage) {
        self.day = day
        self.forecastTempDegrees = forecastTempDegrees
        let temperature = Temperature(openWeatherMapDegrees: forecastTempDegrees)
        self.temperature = temperature.degrees
        self.image = image
    }
    
    mutating func updateTemperatureValues () {
        let temperature = Temperature(openWeatherMapDegrees: forecastTempDegrees)
        self.temperature = temperature.degrees
    }
    
}
