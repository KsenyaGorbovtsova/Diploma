//
//  User.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 24/03/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation
import UIKit

class User: NSObject {

    var firstName: String
    var secondName: String
    var email: String
    var password: String
    var uid: String
    var image: Data
    public init (email: String, uid: String, firstName: String, secondName: String, image: Data) {
        self.password = "0"
        self.firstName = firstName
        self.secondName = secondName
        self.email = email
        self.uid = uid
        self.image = image
        
    }
    public init( email: String, password: String, firstName: String, secondName: String) {
        self.uid = "0"
        self.firstName = firstName
        self.secondName = secondName
        self.email = email
        self.password = password
        self.image = (UIImage(named: "noPhoto")?.pngData())!
    }
    public override init(){
        self.uid = "0"
        self.firstName = ""
        self.secondName = ""
        self.email = ""
        self.password = ""
        self.image = (UIImage(named: "noPhoto")?.pngData())!
        
    }
}
