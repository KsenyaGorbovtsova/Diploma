//
//  Structs.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 21/05/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation

struct listOfPractice: Codable {
    let practices: [practice]
}
struct practice: Codable {
    let id: String
    let date: String
    let repeatAfter: Int
    let owner: String
    let status: Bool
    let name: String
}

struct measurement: Codable {
    let id: String
    let name: String
}

struct apparatus: Codable {
    let id: String
    let name: String
    let image: String
}

struct exercise: Codable {
    let id: String
    let name: String
    let num_try: Int
    let num_rep: Int
    let num_measure: Int
    let apparatusId: String
    let measureUnitId: String
    let status: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case num_try
        case num_rep
        case num_measure
        case apparatusId
        case measureUnitId = "measure_unitId"
        case status
    }
}
