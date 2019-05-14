//
//  Constants.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 14/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import Foundation

struct Constants {
    
    static let userDefaults = UserDefaults.standard
    
    struct City {
        static let ID = "CityID"
        static let index = "CityIndex"
    }
    
    static let temperatureValue = "temperatureValue"
    
    struct Cell {
        static let identifier = "forecastCell"
        static let nibName = "ForecastTableViewCell"
    }
    
    struct OpenWeather {
        static let requestURL = "http://api.openweathermap.org/data/2.5/forecast"
        static let appID = "ac6a88be51624ad2b2799855bdf878d4"
    }
    
    
    private init() { }
}
