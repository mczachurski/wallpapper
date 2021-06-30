//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public class SequenceItem : Codable {
    enum CodingKeys: String, CodingKey {
        case altitude = "a"
        case azimuth = "z"
        case imageIndex = "i"
    }
    
    var altitude: Double = 0.0
    var azimuth: Double = 0.0
    var imageIndex: Int = 0
}
