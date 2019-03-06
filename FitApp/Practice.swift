//
//  Practice.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 25/02/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation

class Practice: NSObject {

    
    var name: String = "Треня"
    var date: String
    var status: Bool
    var uid: String
    public  init(date:String, status: Bool, uid: String) {
        
        self.date = date
        self.status = status
        self.uid = uid
    }
    
    
}
