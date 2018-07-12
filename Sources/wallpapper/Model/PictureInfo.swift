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
    var themeMode: ThemeMode = .both
    var altitude = 0.0
    var azimuth = 0.0

    init(fileName: String, isPrimary: Bool, themeMode: ThemeMode, altitude: Double, azimuth: Double) {
        self.fileName = fileName
        self.isPrimary = isPrimary
        self.themeMode = themeMode
        self.altitude = altitude
        self.azimuth = azimuth
    }
}
