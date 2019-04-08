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
    public  init( status: Bool, uid: String, name: String, owner: String) {
        
        self.owner = owner
        self.status = status
        self.uid = uid
        self.name = name
    }
    
    public init(status: Bool, name: String, owner: String) {
        
        self.uid = "0"
        self.name = name
        self.status = status
        self.owner = owner
    }
    
}
