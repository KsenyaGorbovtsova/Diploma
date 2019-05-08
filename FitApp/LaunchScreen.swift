//
//  LaunchScreen.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 04/05/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import UIKit

class LaunchScreen: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sub = Gradient()
        view.layer.insertSublayer(sub.setGradient(view: self.view), at: 0)
    }
}
