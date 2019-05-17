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
    
    static let CityIndex = "CityIndex"
    
    static let temperatureValue = "temperatureValue"
    
    struct DefaultData {
        static let currentDay = "day"
        static let weatherDisciption = "discription"
        static let openWeatherTemperature = "temperature"
        static let forecastDay1 = "day1"
        static let forecastDay2 = "day2"
        static let forecastDay3 = "day3"
        static let forecastDay4 = "day4"
        static let forecastImage1 = "img1"
        static let forecastImage2 = "img2"
        static let forecastImage3 = "img3"
        static let forecastImage4 = "img4"
        static let forecastTemperature1 = "temperature1"
        static let forecastTemperature2 = "temperature2"
        static let forecastTemperature3 = "temperature3"
        static let forecastTemperature4 = "temperature4"
    }
    
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
