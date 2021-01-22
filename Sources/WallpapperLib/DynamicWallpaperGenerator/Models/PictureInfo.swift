//
//  PictureInfo.swift
//  WallpapperLib
//
//  Created by Marcin Czachurski on 02/07/2018.
//  Copyright © 2018 Marcin Czachurski. All rights reserved.
//

import Foundation

public struct PictureInfo: Decodable {
    var fileName: String
    var isPrimary: Bool?
    var isForLight: Bool?
    var isForDark: Bool?
    var altitude: Double?
    var azimuth: Double?
    var time: Date?
}
