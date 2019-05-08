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

class WeatherViewController: UIViewController {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "ac6a88be51624ad2b2799855bdf878d4"
    let items = ["Moscow", "London", "New York"]
    let titleView: TitleView? = nil
    
    //instance variables
    var weatherDataModel = WeatherDataModel()

    //Outlets
    @IBOutlet weak var currentWeatherImageView: UIImageView!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    
    
    fileprivate func setupDropbox() {
        let titleView = TitleView(navigationController: navigationController!, title: "City", items: items)
        Config.ArrowButton.Text.selectedColor = .black
        Config.List.DefaultCell.Text.color = .black
        Config.List.DefaultCell.separatorColor = .gray
        Config.List.backgroundColor = .white
        titleView?.action = { [weak self] index in
            self?.changeCity(index)
        }
        
        navigationItem.titleView = titleView
    }
    
    //MARK: - Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDropbox()
    }
    
    //MARK: - Networking
    /***************************************************************/
    func getWeatherData(url: String, parameters: [String : String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success")
                
                let weatherJSON: JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
            } else {
                print("Network error")
                if let error = response.result.error {
                    print("error - \(error)")
                } else {
                    print("some error")
                }
            }
            
        }
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
    func updateWeatherData(json: JSON) {
        print(json)
        if let temperature = json["main"]["temp"].double {
            let city = json["name"].stringValue
            let condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.temperature = Int(temperature - 273.15)
            weatherDataModel.city = city
            weatherDataModel.condition = condition
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: condition)
            updateUIWithWeatherData()
        } else {
            print("Error loading data")
        }
        
        
    }
    
    func changeCity(_ newCityIndex: Int) {
        let city = items[newCityIndex]
        let locationProperties: [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url:WEATHER_URL, parameters: locationProperties)
    }
    
    
    //MARK: - UI Updates
    /***************************************************************/
    func updateUIWithWeatherData() {
        currentWeatherLabel.text = "\(weatherDataModel.temperature)"
        currentWeatherImageView.image = UIImage(named: weatherDataModel.weatherIconName!)
    }


}


