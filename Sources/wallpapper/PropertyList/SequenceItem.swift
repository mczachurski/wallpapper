//
//  SequenceItem.swift
//  wallpapper
//
//  Created by Marcin Czachurski on 03/07/2018.
//  Copyright © 2018 Marcin Czachurski. All rights reserved.
//

import Foundation

class SequenceItem : Codable {
    enum CodingKeys: String, CodingKey {
        case altitude = "a"
        case azimuth = "z"
        case imageIndex = "i"
    }
    
    var altitude: Double = 0.0
    var azimuth: Double = 0.0
    var imageIndex: Int = 0
}
