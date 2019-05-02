//
//  measurements.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 29/04/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation

class Measurements: NSObject {
    
    var uid: String
    var name: String
    
    public init (uid: String, name: String) {
        self.uid = uid
        self.name = name
    }
    public init (name: String) {
        self.uid = "0"
        self.name = name
    }
    
}
