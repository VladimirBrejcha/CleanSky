//
//  ViewController.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 07/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import UIKit
import Dropdowns

class ViewController: UIViewController {
    let items = ["Moscow", "London", "New-York"]

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

