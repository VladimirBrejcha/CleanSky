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
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast"
    let APP_ID = "ac6a88be51624ad2b2799855bdf878d4"
    let items = ["Moscow", "London", "New York"]
    let cityID = ["524901", "2643743", "5128581"]
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
        if let temperature = json["list"][0]["main"]["temp"].double {
            let city = json["city"]["name"].stringValue
            let condition = json["list"][0]["weather"][0]["id"].intValue
            
            weatherDataModel.temperature = Int(temperature - 273.15)
            weatherDataModel.city = city
            weatherDataModel.condition = condition
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: condition)
            updateUIWithWeatherData()
            print(condition)
        } else {
            print("Error loading data")
        }
        
        
    }
    
    func changeCity(_ newCityIndex: Int) {
        let city = cityID[newCityIndex]
        let locationProperties: [String : String] = ["id" : city, "appid" : APP_ID]
        getWeatherData(url:WEATHER_URL, parameters: locationProperties)
    }
    
    
    //MARK: - UI Updates
    /***************************************************************/
    func updateUIWithWeatherData() {
        currentWeatherLabel.text = "\(weatherDataModel.temperature)" + "°"
        currentWeatherImageView.image = UIImage(named: weatherDataModel.weatherIconName!)
    }


}


