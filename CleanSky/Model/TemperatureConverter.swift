//
//  TemperatureConverter.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 11/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import Foundation

struct TemperatureConverter {
    
    static func kelvinToCelsius(_ degrees: Double) -> Double {
        return round(degrees - 273.15)
    }
    
    static func kelvinToFahrenheit(_ degrees: Double) -> Double {
        return round(degrees * 9 / 5 - 459.67)
    }
}
