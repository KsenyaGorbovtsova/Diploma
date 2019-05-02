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
    var owner: String
    var status: Bool
    var uid: String
    var date: String
    var repeatAfter: Int
    public  init( status: Bool, uid: String, name: String, owner: String, date: String, repeatAfter: Int) {
        
        self.owner = owner
        self.status = status
        self.uid = uid
        self.name = name
        self.date = date
        self.repeatAfter = repeatAfter
    }
    
    public init(status: Bool, name: String, owner: String, date: String, repeatAfter: Int) {
        
        self.uid = "0"
        self.name = name
        self.status = status
        self.owner = owner
        self.date = date
        self.repeatAfter = repeatAfter
    }
    
}
