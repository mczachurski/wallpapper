//
//  PictureInfo.swift
//  wallpapper
//
//  Created by Marcin Czachurski on 02/07/2018.
//  Copyright © 2018 Marcin Czachurski. All rights reserved.
//

import Foundation

class PictureInfo: Decodable {
    var fileName: String
    var isPrimary = false
    var isForLight = false
    var isForDark = false
    var altitude = 0.0
    var azimuth = 0.0

    init(fileName: String, isPrimary: Bool, isForLight: Bool, isForDark: Bool, altitude: Double, azimuth: Double) {
        self.fileName = fileName
        self.isPrimary = isPrimary
        self.isForLight = isForLight
        self.isForDark = isForDark
        self.altitude = altitude
        self.azimuth = azimuth
    }
}
