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
    var openWeatherTemperature: Double
    var convertedTemperature: String?
    let weatherImage: UIImage
    
    init(day: String, temperature: Double, image: UIImage) {
        self.day = day
        openWeatherTemperature = temperature
        weatherImage = image
        updateTemperatureValues()
    }
    //TODO: move this functionality into computed property
    mutating func updateTemperatureValues () {
        let temperature = Temperature(openWeatherMapDegrees: openWeatherTemperature)
        self.convertedTemperature = temperature.degrees
    }
    
}
