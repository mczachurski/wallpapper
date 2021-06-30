//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
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
