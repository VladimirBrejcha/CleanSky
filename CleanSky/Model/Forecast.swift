//
//  Forecast.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 13/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import Foundation

struct Forecast {
    let day: String
    var forecastTempDegrees: Double
    var temperature: String
    let imageName: String
    
    init(day: String, forecastTempDegrees: Double, temperature: String? = nil, imageName: String) {
        self.day = day
        self.forecastTempDegrees = forecastTempDegrees
        let temperature = Temperature(openWeatherMapDegrees: forecastTempDegrees)
        self.temperature = temperature.degrees
        self.imageName = imageName
    }
    
    mutating func updateTemperatureValues () {
        let temperature = Temperature(openWeatherMapDegrees: forecastTempDegrees)
        self.temperature = temperature.degrees
    }
    
}
