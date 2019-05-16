//
//  ForecastDateTime.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 13/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import Foundation

struct DateConverter {
    let rawDate: Double
    
    var date: Date {
        return Date(timeIntervalSince1970: rawDate)
    }
    
    var weekDay: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        let weekDayName: String = dateFormatter.string(from: date)
        
        return String(weekDayName)
    }
    
    var currentDay: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date)
        guard let day = components.day else { return 1 }
        
        return day - 1
    }
}

