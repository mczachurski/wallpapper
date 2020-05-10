//
//  TimeItem.swift
//  wallpapper
//
//  Created by Marcin Czachurski on 01/07/2019.
//  Copyright © 2019 Marcin Czachurski. All rights reserved.
//

import Foundation

class TimeItem : Codable {
    enum CodingKeys: String, CodingKey {
        case time = "t"
        case imageIndex = "i"
    }

    var time: Double = 0.0
    var imageIndex: Int = 0
}
