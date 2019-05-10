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
    static let userDefaults = UserDefaults.standard
    private let WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast"
    private let APP_ID = "ac6a88be51624ad2b2799855bdf878d4"
    private let cityNameArray = ["Moscow", "London", "New York"]
    private let cityIDArray = ["524901", "2643743", "5128581"] //todo
    private let titleView: TitleView? = nil
    private let currentCity = WeatherViewController.userDefaults.string(forKey: "City")
    
    //instance variables
    private var weatherDataModel = WeatherDataModel()

    //Outlets
    @IBOutlet weak var currentWeatherLabel: UILabel!
    @IBOutlet weak var settingsContainerView: UIView!
    @IBOutlet weak var temperatureValueSettingsSwitch: UISwitch!
    
    
    //MARK: - Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        settingsContainerView.layer.cornerRadius = 20
        setupDropbox()
        setCity(currentCity ?? "default")
        setTemperatureValueSlider()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupDropbox()
    }
    
    //MARK: - UIsetup methods
    fileprivate func setupDropbox() {
        let titleView = TitleView(navigationController: navigationController!, title: "City", items: cityNameArray)
        Config.ArrowButton.Text.selectedColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        Config.List.DefaultCell.Text.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        Config.ArrowButton.Text.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        Config.topLineColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        Config.List.DefaultCell.separatorColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        Config.List.backgroundColor = #colorLiteral(red: 0.926155746, green: 0.9410773516, blue: 0.9455420375, alpha: 0.09754922945)
        titleView?.action = { [weak self] index in
            self?.changeCity(index)
        }
        navigationItem.titleView = titleView
    }
    
    func setTemperatureValueSlider() {
        if WeatherViewController.userDefaults.string(forKey: "temperatureValue") == "f" {
            temperatureValueSettingsSwitch.isOn = true
        } else {
            temperatureValueSettingsSwitch.isOn = false
        }
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
    
    func setCity(_ newcity: String) {
        switch newcity {
        case cityIDArray[0]:
            let locationProperties: [String : String] = ["id" : newcity, "appid" : APP_ID]
            getWeatherData(url:WEATHER_URL, parameters: locationProperties)
        case cityIDArray[1]:
            let locationProperties: [String : String] = ["id" : newcity, "appid" : APP_ID]
            getWeatherData(url:WEATHER_URL, parameters: locationProperties)
        case cityIDArray[2]:
            let locationProperties: [String : String] = ["id" : newcity, "appid" : APP_ID]
            getWeatherData(url:WEATHER_URL, parameters: locationProperties)
        default:
            print("wasntset")
        }
        
    }
    
    func changeCity(_ newCityIndex: Int) {
        let city = cityIDArray[newCityIndex]
//        let cityName = cityNameArray[newCityIndex]
        let locationProperties: [String : String] = ["id" : city, "appid" : APP_ID]
        getWeatherData(url:WEATHER_URL, parameters: locationProperties)
        WeatherViewController.userDefaults.set(city, forKey: "City")
        setCity(city)
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
//            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: condition)
            updateUIWithWeatherData()
            print(condition)
        } else {
            print("Error loading data")
        }
        
        
    }
    
    //MARK: - user interaction methods
    func changeTemperatureValue(_ temperatureValue: Bool) {
        if temperatureValue {
            WeatherViewController.userDefaults.set("c", forKey: "temperatureValue")
            currentWeatherLabel.text = "\(weatherDataModel.returningTemperature)" + "°"
        } else {
            WeatherViewController.userDefaults.set("f", forKey: "temperatureValue")
            currentWeatherLabel.text = "\(weatherDataModel.returningTemperature)" + "°"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view != settingsContainerView {
            settingsContainerView.isHidden = true
        }
    }
    
    @IBAction func settingsButtonAction(_ sender: UIBarButtonItem) {
        if settingsContainerView.isHidden == true {
            settingsContainerView.isHidden = false
        } else {
            settingsContainerView.isHidden = true
        }
    }
    
    @IBAction func temperatureValueSliderAction(_ sender: UISwitch) {
        if temperatureValueSettingsSwitch.isOn {
            changeTemperatureValue(false)
        } else if temperatureValueSettingsSwitch.isOn == false {
            changeTemperatureValue(true)
        }
    }
    
    //MARK: - UI Updates
    /***************************************************************/
    func updateUIWithWeatherData() {
        currentWeatherLabel.text = "\(weatherDataModel.returningTemperature)" + "°"
//        currentWeatherImageView.image = UIImage(named: weatherDataModel.weatherIconName!)
    }


}


