//
//  ForecastDateTime.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 13/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import Foundation

struct ForecastDateTime {
    let rawDate: Double
    let timeZone: TimeZone
    
    init(date: Double, timeZone: TimeZone) {
        self.timeZone = timeZone
        self.rawDate = date
    }
    
    var shortTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        
        let date = Date(timeIntervalSince1970: rawDate)
        let weekDay = Calendar.current.component(.weekday, from: date)
        let weekDayName = dateFormatter.weekdaySymbols[weekDay]
        return String(weekDayName)
    }
}
