//
//  WeatherDataModel.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 07/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import UIKit

struct WeatherData {
    
    var discription: String?
    var openWeatherTemperature: Double? {
        willSet {
            convertedTemperature = Temperature(openWeatherMapDegrees: newValue!).degrees
        }
    }
    var convertedTemperature: String?
    var forecasts = [Forecast]()
    
    //This method turns a condition code into the weather condition image
    func updateWeatherIcon(condition: Int) -> UIImage {
        
        switch (condition) {
        case 0...300 :
            return #imageLiteral(resourceName: "storm")
        case 301...500 :
            return #imageLiteral(resourceName: "shower")
        case 501...600 :
            return #imageLiteral(resourceName: "lightRain")
        case 601...700 :
            return #imageLiteral(resourceName: "snow")
        case 701...771 :
            return #imageLiteral(resourceName: "fog")
        case 772...799 :
            return #imageLiteral(resourceName: "storm2")
        case 800 :
            return #imageLiteral(resourceName: "sunny")
        case 801...804 :
            return #imageLiteral(resourceName: "cloudy")
        case 900...903, 905...1000  :
            return #imageLiteral(resourceName: "storm2")
        case 903 :
            return #imageLiteral(resourceName: "snow2")
        case 904 :
            return #imageLiteral(resourceName: "sunny")
        default :
            return #imageLiteral(resourceName: "questionMark")
        }
    }
}
