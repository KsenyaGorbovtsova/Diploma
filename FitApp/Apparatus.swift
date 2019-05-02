//
//  Apparatus.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 29/04/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation


class Apparatus: NSObject {
    
    var uid: String
    var image: Data
    var name: String
    
    public init (uid: String, image: Data, name: String) {
        self.uid = uid
        self.name = name
        self.image = image
    }
    public init (image:Data, name: String) {
        self.uid = "0"
        self.name = name
        self.image = image
    }
    
}
