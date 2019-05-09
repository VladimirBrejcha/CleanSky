//
//  SettingsViewController.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 07/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var celsiusButton: UIButton!
    @IBOutlet weak var fahrenheitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        celsiusButton.isSelected = true

    }
    
    func changeTemperatureValues() {
        if celsiusButton.isSelected {
            WeatherViewController.userDefaults.set("fahrenheit", forKey: "temperatureValue")
            celsiusButton.isSelected = false
            fahrenheitButton.isSelected = true
        } else if fahrenheitButton.isSelected {
            WeatherViewController.userDefaults.set("celsius", forKey: "temperatureValue")
            fahrenheitButton.isSelected = false
            celsiusButton.isSelected = true
        }
    }
    
    @IBAction func valueButtonAction(_ sender: UIButton) {
        changeTemperatureValues()
    }
    
}
