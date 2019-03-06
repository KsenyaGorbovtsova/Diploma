//
//  Exercise.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 01/03/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation


class Exercise: NSObject {
    
    var uid: String
    var name: String
    var num_try: Int
    var num_rep: Int
    var num_measure: Int
    var apparatusId: String
    var measureUnitId: String
    var status: Bool
    
    public init(name: String, uid: String, num_try: Int, num_rep: Int, num_measure: Int, measureUnitId: String, apparatusId: String, status: Bool ) {
        self.name = name
        self.uid = uid
        self.num_try = num_try
        self.num_rep = num_rep
        self.num_measure = num_measure
        self.measureUnitId = measureUnitId
        self.apparatusId = apparatusId
        self.status = status
        
    }
    public init(name: String,  num_try: Int, num_rep: Int, num_measure: Int, measureUnitId: String, apparatusId: String, status: Bool ) {
        self.uid = "0"
        self.name = name
        self.num_try = num_try
        self.num_rep = num_rep
        self.num_measure = num_measure
        self.measureUnitId = measureUnitId
        self.apparatusId = apparatusId
        self.status = status
    }
    
}
