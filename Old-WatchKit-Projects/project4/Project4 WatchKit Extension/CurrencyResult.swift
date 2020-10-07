//
//  CurrencyResult.swift
//  Project4 WatchKit Extension
//
//  Created by Paul Hudson on 27/10/2018.
//  Copyright © 2018 Paul Hudson. All rights reserved.
//

import Foundation

struct CurrencyResult: Codable {
    var base: String
    var rates: [String: Double]
}
