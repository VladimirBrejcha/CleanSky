//
//  ViewController.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 07/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import NavigationDropdownMenu

class WeatherViewController: UIViewController {
  
  private let cityNameArray = ["Moscow", "London", "New York"]
  private var initialIndex = Constants.userDefaults.integer(forKey: Constants.сityIndex)
  
  private var cityID: String {
    switch initialIndex {
    case 0:
      return "524901"
    case 1:
      return "2643743"
    case 2:
      return "5128581"
    default:
      return "524901"
    }
  }
  
  private var cityImage: UIImage {
    switch initialIndex {
    case 0:
      return #imageLiteral(resourceName: "Moscow")
    case 1:
      return #imageLiteral(resourceName: "London")
    case 2:
      return #imageLiteral(resourceName: "New York")
    default:
      return #imageLiteral(resourceName: "Moscow")
    }
  }
  
  private var weatherDataModel = WeatherData()
  private let sessionManager = SessionManager()
  
  //MARK: UI elements
  private var menuView: NavigationDropdownMenu!
  private var activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0,
                                                                            y: 0,
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
    
    setupUIElements()
    
    setLatestUsedWeatherValues()
    
    changeCity()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    activityIndicatorView.frame = CGRect(x: 20,
                                         y: 10 + statusBarHeight,
                                         width: 20,
                                         height: 20)
  }
  
  //MARK: UIsetup methods
  /***************************************************************/
  
  private func setupUIElements() {
    
    settingsContainerView.layer.cornerRadius = 20
    
    setupTemperatureChangingSwitch()
    
    setupDropbox()
    
    view.addSubview(activityIndicatorView)
    
    setupTableView()
  }
  
  private func setupTemperatureChangingSwitch() {
    if Constants.userDefaults.string(forKey: Constants.temperatureValue) == "f" {
      temperatureValueSettingsSwitch.isOn = true
    } else {
      temperatureValueSettingsSwitch.isOn = false
    }
  }
  
  private func setupDropbox() {
    
    menuView = NavigationDropdownMenu(navigationController: self.navigationController,
                                      containerView: self.navigationController!.view,
                                      title: Title.index(initialIndex),
                                      items: cityNameArray)
    
    menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
      self?.initialIndex = indexPath
      self?.changeCity()
    }
    
    menuView.animationDuration = 0.25
    menuView.maskBackgroundOpacity = 0.55
    menuView.cellTextLabelAlignment = .center
    menuView.cellTextLabelFont = UIFont.systemFont(ofSize: 18)
    menuView.shouldKeepSelectedCellColor = true
    menuView.cellBackgroundColor = #colorLiteral(red: 0.1490027606, green: 0.1490303874, blue: 0.1489966214, alpha: 0.2467264525)
    menuView.cellSelectionColor =  #colorLiteral(red: 0.1490027606, green: 0.1490303874, blue: 0.1489966214, alpha: 0.2467264525)
    menuView.cellTextLabelColor = #colorLiteral(red: 0.926155746, green: 0.9410773516, blue: 0.9455420375, alpha: 1)
    menuView.cellSeparatorColor = #colorLiteral(red: 0.926155746, green: 0.9410773516, blue: 0.9455420375, alpha: 0.5102057658)
    
    self.navigationItem.titleView = menuView
  }
  
  private func setupTableView() {
    forecastTableView.dataSource = self
    forecastTableView.register(UINib(nibName: Constants.Cell.nibName, bundle: nil),
                               forCellReuseIdentifier: Constants.Cell.identifier)
  }
  
  //MARK: user interaction methods
  /***************************************************************/
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //this method used to hide settings view on tap outside
    let touch = touches.first
    if touch?.view != settingsContainerView {
      settingsContainerView.isHidden = true
    }
  }
  
  @IBAction func settingsButtonAction(_ sender: UIBarButtonItem) {
    settingsContainerView.isHidden = !settingsContainerView.isHidden
  }
  
  @IBAction func temperatureValueSwitchAction(_ sender: UISwitch) {
    
    let value = temperatureValueSettingsSwitch.isOn ? "f" : "c"
    
    Constants.userDefaults.set(value, forKey: Constants.temperatureValue)
    
    updateUIWithTemperature()
  }
  
  //MARK: Networking
  /***************************************************************/
  private func changeCity() {
    
    isUserInteractionAllowed(false)
    
    let locationProperties = ["id" : cityID,
                              "appid" : Constants.OpenWeather.appID]
    
    getWeatherData(url:Constants.OpenWeather.requestURL,
                   parameters: locationProperties)
  }
  
  private func getWeatherData(url: String, parameters: [String : String]) {
    
    sessionManager.retrier = CustomRequestRetrier()
    
    let request = sessionManager.request(url, method: .get, parameters: parameters).validate()
    
    request.responseJSON { response in
      if response.result.isSuccess {
        print("Get weather data request successefully gotten")
        let weatherJSON: JSON = JSON(response.result.value!)
        self.updateData(json: weatherJSON)
      }
    }
  }
  
  //MARK: JSON Parsing && Model updating
  /***************************************************************/
  
  private func updateData(json: JSON) {
    
    updateWeatherData(json) //pasring json for weather and append values to model
    
    updateForecastData(json) //pasring json for forecasts and append values to model
    
    saveLatestUsedWeatherValues() //saving latest weather stats to use it on load
    
    updateUIWithWeatherData() //updating ui after successefull parsing
  }
  
  private func updateWeatherData(_ json: JSON) {
    guard
      let date = json["list"][0]["dt"].double,
      let openWeatherTemperature = json["list"][0]["main"]["temp"].double,
      let discription = json["list"][0]["weather"][0]["description"].string
      else {
        print("Error parsing weather json")
        return
    }
    
    let currentDate = DateConverter(rawDate: date).date
    //saving date of request to compare it with actual date on app launch
    Constants.userDefaults.set(currentDate, forKey: Constants.DefaultData.currentDay)
    
    weatherDataModel.openWeatherTemperature = openWeatherTemperature
    weatherDataModel.discription = discription.capitalizingFirstLetter()
  }
  
  private func updateForecastData(_ json: JSON) {
    
    weatherDataModel.forecasts.removeAll() //removing old forecast objects to append new ones
    
    let index = [7, 15, 23, 31]
    for index in index {
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
  
  //MARK: UI Updates
  /***************************************************************/
  
  private func updateUIWithWeatherData() {
    
    updateUIWithTemperature()
    
    title = cityNameArray[Constants.userDefaults.integer(forKey: Constants.сityIndex)]
    backgroundImageView.image = cityImage
    currentWeatherDiscriptionLabel.text = weatherDataModel.discription
    
    isUserInteractionAllowed(true)
  }
  
  private func updateUIWithTemperature() {
    
    weatherDataModel.openWeatherTemperature = weatherDataModel.openWeatherTemperature
    
    for index in 0...3 {
      weatherDataModel.forecasts[index].openWeatherTemperature = weatherDataModel.forecasts[index].openWeatherTemperature
    }
    
    currentWeatherLabel.text = weatherDataModel.convertedTemperature
    
    forecastTableView.reloadData()
  }
  
  private func isUserInteractionAllowed(_ isAllowed: Bool) {
    settingsButton.isEnabled = isAllowed
    menuView.isUserInteractionEnabled = isAllowed
    isAllowed
      ? (self.activityIndicatorView.stopAnimating(),
         menuView.alpha = 1.0)
      : (activityIndicatorView.startAnimating(),
         menuView.alpha = 0.35)
  }
  
  //MARK: Working with default values for cases where user cant load new data
  /***************************************************************/
  private func setLatestUsedWeatherValues() {
    
    guard let defaultVersion = Constants.userDefaults.string(forKey: Constants.DefaultData.weatherDisciption) else { return }
    
    let calendar = Calendar.current
    let latestUsedDate = Constants.userDefaults.object(forKey: Constants.DefaultData.currentDay) as! Date
    
    if calendar.isDateInToday(latestUsedDate) {
      
      weatherDataModel.discription = defaultVersion
      weatherDataModel.openWeatherTemperature = Constants.userDefaults.double(forKey: Constants.DefaultData.openWeatherTemperature)
      
      weatherDataModel.forecasts.append(Forecast(day: Constants.userDefaults.string(forKey: Constants.DefaultData.forecastDay1)!,
                                                 temperature: Constants.userDefaults.double(forKey: Constants.DefaultData.forecastTemperature1),
                                                 image: UIImage(data: Constants.userDefaults.data(forKey: Constants.DefaultData.forecastImage1)!)!))
      
      weatherDataModel.forecasts.append(Forecast(day: Constants.userDefaults.string(forKey: Constants.DefaultData.forecastDay2)!,
                                                 temperature: Constants.userDefaults.double(forKey: Constants.DefaultData.forecastTemperature2),
                                                 image: UIImage(data: Constants.userDefaults.data(forKey: Constants.DefaultData.forecastImage2)!)!))
      
      weatherDataModel.forecasts.append(Forecast(day: Constants.userDefaults.string(forKey: Constants.DefaultData.forecastDay3)!,
                                                 temperature: Constants.userDefaults.double(forKey: Constants.DefaultData.forecastTemperature3),
                                                 image: UIImage(data: Constants.userDefaults.data(forKey: Constants.DefaultData.forecastImage3)!)!))
      
      weatherDataModel.forecasts.append(Forecast(day: Constants.userDefaults.string(forKey: Constants.DefaultData.forecastDay4)!,
                                                 temperature: Constants.userDefaults.double(forKey: Constants.DefaultData.forecastTemperature4),
                                                 image: UIImage(data: Constants.userDefaults.data(forKey: Constants.DefaultData.forecastImage4)!)!))
      
      updateUIWithWeatherData() //updating ui with default data
    } else {
      print("\(latestUsedDate) is not current day")
      return
    }
  }
  
  private func saveLatestUsedWeatherValues() {
    Constants.userDefaults.set(initialIndex,
                               forKey: Constants.сityIndex)
    
    Constants.userDefaults.set(weatherDataModel.discription,
                               forKey: Constants.DefaultData.weatherDisciption)
    
    Constants.userDefaults.set(weatherDataModel.openWeatherTemperature,
                               forKey: Constants.DefaultData.openWeatherTemperature)
    
    Constants.userDefaults.set(weatherDataModel.forecasts[0].day,
                               forKey: Constants.DefaultData.forecastDay1)
    
    Constants.userDefaults.set(weatherDataModel.forecasts[1].day,
                               forKey: Constants.DefaultData.forecastDay2)
    
    Constants.userDefaults.set(weatherDataModel.forecasts[2].day,
                               forKey: Constants.DefaultData.forecastDay3)
    
    Constants.userDefaults.set(weatherDataModel.forecasts[3].day,
                               forKey: Constants.DefaultData.forecastDay4)
    
    Constants.userDefaults.set(weatherDataModel.forecasts[0].weatherImage.pngData(),
                               forKey: Constants.DefaultData.forecastImage1)
    
    Constants.userDefaults.set(weatherDataModel.forecasts[1].weatherImage.pngData(),
                               forKey: Constants.DefaultData.forecastImage2)
    
    Constants.userDefaults.set(weatherDataModel.forecasts[2].weatherImage.pngData(),
                               forKey: Constants.DefaultData.forecastImage3)
    
    Constants.userDefaults.set(weatherDataModel.forecasts[3].weatherImage.pngData(),
                               forKey: Constants.DefaultData.forecastImage4)
    
    Constants.userDefaults.set(weatherDataModel.forecasts[0].openWeatherTemperature,
                               forKey: Constants.DefaultData.forecastTemperature1)
    
    Constants.userDefaults.set(weatherDataModel.forecasts[1].openWeatherTemperature,
                               forKey: Constants.DefaultData.forecastTemperature2)
    
    Constants.userDefaults.set(weatherDataModel.forecasts[2].openWeatherTemperature,
                               forKey: Constants.DefaultData.forecastTemperature3)
    
    Constants.userDefaults.set(weatherDataModel.forecasts[3].openWeatherTemperature,
                               forKey: Constants.DefaultData.forecastTemperature4)
  }
}

//MARK: TableView data source methods
/***************************************************************/
extension WeatherViewController: UITableViewDataSource {
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 4
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.identifier,
                                             for: indexPath) as! ForecastTableViewCell
    
    guard !weatherDataModel.forecasts.isEmpty else { return cell }
    
    cell.dayLabel.text = weatherDataModel.forecasts[indexPath.row].day
    cell.temperatureLabel.text = weatherDataModel.forecasts[indexPath.row].convertedTemperature!
    cell.weatherImageView.image = weatherDataModel.forecasts[indexPath.row].weatherImage
    
    return cell
  }
}


