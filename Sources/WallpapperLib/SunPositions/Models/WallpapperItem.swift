//
//  WallpapperItem.swift
//  WallpapperLib
//
//  Created by Marcin Czachurski on 21/10/2021.
//  Copyright © 2021 Marcin Czachurski. All rights reserved.
//

import Foundation

public struct WallpapperItem: Encodable {
    public let fileName: String
    public let altitude: Double
    public let azimuth: Double
    
    public init(fileName: String, altitude: Double, azimuth: Double) {
        self.fileName = fileName
        self.altitude = altitude
        self.azimuth = azimuth
    }
}
