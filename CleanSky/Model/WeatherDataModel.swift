//
//  WeatherDataModel.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 07/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import UIKit

class WeatherDataModel {
    
    //model variables
    var temperature = 0
    var condition = 0
    var city: String?
    var weatherIconName: String?
    
    //This method turns a condition code into the name of the weather condition image
    
    func updateWeatherIcon(condition: Int) -> String {
        
        switch (condition) {
            
        case 0...300 :
            return "storm"
            
        case 301...500 :
            return "lightRain"
            
        case 501...600 :
            return "shower"
            
        case 601...700 :
            return "snow"
            
        case 701...771 :
            return "fog"
            
        case 772...799 :
            return "storm2"
            
        case 800 :
            return "sunny"
            
        case 801...804 :
            return "cloudy"
            
        case 900...903, 905...1000  :
            return "storm2"
            
        case 903 :
            return "snow2"
            
        case 904 :
            return "sunny"
            
        default :
            return "questionMark"
        }
        
    }
}
