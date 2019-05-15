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
import NVActivityIndicatorView

class WeatherViewController: UIViewController {
    
    private let cityNameArray = ["Moscow", "London", "New York"]
    private let cityIDArray = ["524901", "2643743", "5128581"]
    private let cityImageDictionary = ["524901" : #imageLiteral(resourceName: "Moscow"), "2643743" : #imageLiteral(resourceName: "London"), "5128581" : #imageLiteral(resourceName: "New York")]
    
    private var weatherDataModel = WeatherData()
    let sessionManager = SessionManager()
    
    // UI elements
    private var titleView: TitleView!
    
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 20,
                                                                      y: 30,
                                                                      width: 20,
                                                                      height: 20), type: .ballClipRotate)
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var settingsContainerView: UIView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var temperatureValueSettingsSwitch: UISwitch!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    @IBOutlet weak var currentWeatherDiscriptionLabel: UILabel!
    @IBOutlet weak var forecastTableView: UITableView!
    
    //MARK: Controller life cycle methods
    /***************************************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        
        setupSettingsView()
        setupTemperatureChangingSwitch()
        setupDropbox()
        setupActivityIndicator()
        setupTableView()
        setCity()
    }
    
    //MARK: UIsetup methods
    /***************************************************************/
    fileprivate func setupDropbox() {
        titleView = TitleView(navigationController: navigationController!,
                              title: "Choose city",
                              items: cityNameArray,
                              initialIndex: Constants.userDefaults.integer(forKey: Constants.City.index))
        titleView?.action = { [weak self] index in
            let city = self?.cityIDArray[index] //getting id of a current city to save it
            Constants.userDefaults.set(index, forKey: Constants.City.index)
            Constants.userDefaults.set(city, forKey: Constants.City.ID) //saving current city to use it on app launch
            self?.setCity()
        }
        Config.ArrowButton.Text.selectedColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        Config.topLineColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        Config.List.DefaultCell.separatorColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        Config.List.backgroundColor = #colorLiteral(red: 0.926155746, green: 0.9410773516, blue: 0.9455420375, alpha: 0.09754922945)
        navigationItem.titleView = titleView
    }
    
    fileprivate func setupTemperatureChangingSwitch() {
        if Constants.userDefaults.string(forKey: Constants.temperatureValue) == "f" {
            temperatureValueSettingsSwitch.isOn = true
        } else {
            temperatureValueSettingsSwitch.isOn = false
        }
    }
    
    fileprivate func setupSettingsView() {
        settingsContainerView.layer.cornerRadius = 20
    }
    
    fileprivate func setupActivityIndicator() {
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        currentWindow?.addSubview(activityIndicatorView)
    }
    
    fileprivate func setupTableView() {
        forecastTableView.dataSource = self
        forecastTableView.register(UINib(nibName: Constants.Cell.nibName, bundle: nil),
                                   forCellReuseIdentifier: Constants.Cell.identifier)
    }
    
    //MARK: Networking
    /***************************************************************/
    fileprivate func setCity() {
        blockUserInteraction()
        if let city = Constants.userDefaults.string(forKey: Constants.City.ID) { //setting city based on city id
            let locationProperties: [String : String] = ["id" : city, "appid" : Constants.OpenWeather.appID]
            getWeatherData(url:Constants.OpenWeather.requestURL, parameters: locationProperties)
        } else {
            let locationProperties: [String : String] = ["id" : cityIDArray[0], "appid" : Constants.OpenWeather.appID] //setting city if city id doesnt exist yet
            getWeatherData(url:Constants.OpenWeather.requestURL, parameters: locationProperties)
        }
    }
    
    fileprivate func getWeatherData(url: String, parameters: [String : String]) {
        sessionManager.retrier = OAuth2Handler()
        let request = sessionManager.request(url, method: .get, parameters: parameters).validate()
        request.responseJSON { response in
            if response.result.isSuccess {
                print("Get weather data request successefully gotten")
                let weatherJSON: JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            } else {
                self.blockUserInteraction()
                if let error = response.result.error {
                    self.sessionManager.retrier?.should(self.sessionManager, retry: request, with: error, completion: { (Bool, TimeInterval) in
                        
                    })
                    print("Error requesting weather data - \(error)")
                } else {
                    print("Unknown error requesting weather data")
                }
            }
        }
    }
    
    //MARK: JSON Parsing && Model updating
    /***************************************************************/
    func updateWeatherData(json: JSON) {
        
        guard
            let openWeatherTemperature = json["list"][0]["main"]["temp"].double,
            let discription = json["list"][0]["weather"][0]["description"].string
            else {
                print("Error parsing weather json")
                return
        }
        
        updateForecastData(json)
        
        weatherDataModel.openWeatherTemperature = openWeatherTemperature
        weatherDataModel.discription = discription.capitalizingFirstLetter()
        
        updateUIWithWeatherData()
    }
    
    fileprivate func updateForecastData(_ json: JSON) {
        
        weatherDataModel.forecasts.removeAll()
        
        for index in 0...32 where (index == 7 || index == 15 || index == 23 || index == 31) {
            guard
                let date = json["list"][index]["dt"].double,
                let openWeatherTemperature = json["list"][index]["main"]["temp"].double,
                let condition = json["list"][index]["weather"][0]["id"].int
                else {
                    print("Error parsing forecast json")
                    break
            }
            let forecastDate = DateConverter(rawDate: date).weekDay
            let forecastImage = weatherDataModel.updateWeatherIcon(condition: condition)
            let forecast = Forecast(day: forecastDate, temperature: openWeatherTemperature, image: forecastImage)
            
            weatherDataModel.forecasts.append(forecast)
        }
    }
    
    //MARK: user interaction methods
    /***************************************************************/
    //this method used to hide settings view on tap outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view != settingsContainerView {
            settingsContainerView.isHidden = true
        }
    }
    
    @IBAction func settingsButtonAction(_ sender: UIBarButtonItem) {
        settingsContainerView.isHidden = !settingsContainerView.isHidden
    }
    
    //TODO: refactor this methods
    @IBAction func temperatureValueSwitchAction(_ sender: UISwitch) {
        if temperatureValueSettingsSwitch.isOn {
            Constants.userDefaults.set("f", forKey: Constants.temperatureValue)
        } else if temperatureValueSettingsSwitch.isOn == false {
            Constants.userDefaults.set("c", forKey: Constants.temperatureValue)
        }
        updateUIWithtemperature()
    }
    
    //MARK: UI Updates
    /***************************************************************/
    func updateUIWithtemperature() {
        weatherDataModel.openWeatherTemperature = weatherDataModel.openWeatherTemperature
        for index in 0...3 {
            
            weatherDataModel.forecasts[index].openWeatherTemperature = weatherDataModel.forecasts[index].openWeatherTemperature
        }
        currentWeatherLabel.text = weatherDataModel.convertedTemperature
        forecastTableView.reloadData()
    }
    
    
    
    func updateUIWithWeatherData() {
        updateUIWithtemperature()
        
        titleView?.button.label.text = cityNameArray[Constants.userDefaults.integer(forKey: Constants.City.index)]
        backgroundImageView.image = cityImageDictionary[Constants.userDefaults.string(forKey: Constants.City.ID) ?? cityIDArray[0]]
        currentWeatherDiscriptionLabel.text = weatherDataModel.discription
        
        allowUserInteraction()
    }
    
    fileprivate func allowUserInteraction() {
        titleView.alpha = 1.0
        titleView.isUserInteractionEnabled = true
        settingsButton.isEnabled = true
        activityIndicatorView.stopAnimating()
    }
    
    fileprivate func blockUserInteraction() {
        titleView.alpha = 0.35
        titleView.isUserInteractionEnabled = false
        settingsButton.isEnabled = false
        activityIndicatorView.startAnimating()
    }
    
    fileprivate func showLastRecorded() {
        
    }
}

extension WeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.identifier,
                                                 for: indexPath) as! ForecastTableViewCell
        if weatherDataModel.forecasts.isEmpty == false  {
            cell.dayLabel.text = weatherDataModel.forecasts[indexPath.row].day
            cell.temperatureLabel.text = (weatherDataModel.forecasts[indexPath.row].convertedTemperature!)
            cell.weatherImageView.image = weatherDataModel.forecasts[indexPath.row].weatherImage
        }
        return cell
    }
}









