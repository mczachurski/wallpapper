//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public class SequenceInfo : Codable {
    enum CodingKeys: String, CodingKey {
        case sequenceItems = "si"
        case timeItems = "ti"
        case apperance = "ap"
    }
    
    var sequenceItems: [SequenceItem]?
    var timeItems: [TimeItem]?
    var apperance: Apperance?
}
