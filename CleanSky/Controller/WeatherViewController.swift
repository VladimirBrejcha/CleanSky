//
//  ViewController.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 07/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import UIKit
import Dropdowns
import Alamofire
import SwiftyJSON
import CoreLocation

class WeatherViewController: UIViewController {
    
    //Constants
//    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
//    let APP_ID = "ac6a88be51624ad2b2799855bdf878d4"
    let items = ["Moscow", "London", "New-York"]
    
    //instance variables
    var weatherDataModel = WeatherDataModel()

    @IBOutlet weak var currentWeatherImageView: UIImageView!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleView = TitleView(navigationController: navigationController!, title: "City", items: items)
        Config.ArrowButton.Text.color = .black
        Config.ArrowButton.Text.selectedColor = .black
        Config.List.DefaultCell.Text.color = .black
        Config.List.DefaultCell.separatorColor = .gray
        Config.List.backgroundColor = .white
        titleView?.action = { [weak self] index in
            print(self!)
            print("select \(index)")
        }
        
        navigationItem.titleView = titleView
    }


}

