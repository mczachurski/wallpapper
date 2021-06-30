//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
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
