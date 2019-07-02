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
    var isPrimary: Bool?
    var isForLight: Bool?
    var isForDark: Bool?
    var altitude: Double?
    var azimuth: Double?
    var time: Date?

    init(fileName: String,
         isPrimary: Bool?,
         isForLight: Bool?,
         isForDark: Bool?,
         altitude: Double,
         azimuth: Double?,
         time: Date?
    ) {
        self.fileName = fileName
        self.isPrimary = isPrimary
        self.isForLight = isForLight
        self.isForDark = isForDark
        self.altitude = altitude
        self.azimuth = azimuth
        self.time = time 
    }
}
