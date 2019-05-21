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
