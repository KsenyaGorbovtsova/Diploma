//
//  User.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 24/03/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation

class User: NSObject {
    var firstName: String
    var secondName: String
    var email: String
    var password: String
    var uid: String
    public init (email: String, uid: String, firstName: String, secondName: String) {
        self.password = "0"
        self.firstName = firstName
        self.secondName = secondName
        self.email = email
        self.uid = uid
        
    }
    public init( email: String, password: String, firstName: String, secondName: String) {
        self.uid = "0"
        self.firstName = firstName
        self.secondName = secondName
        self.email = email
        self.password = password
        
    }
}
