//
//  Practice.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 25/02/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation

class Practice: NSObject {

    
    var name: String 
    var date: String
    var status: Bool
    var uid: String
    public  init(date:String, status: Bool, uid: String, name: String) {
        
        self.date = date
        self.status = status
        self.uid = uid
        self.name = name
    }
    
    public init(date: String, status: Bool, name: String) {
        self.date = date
        self.uid = "0"
        self.name = name
        self.status = status
    }
    
}
