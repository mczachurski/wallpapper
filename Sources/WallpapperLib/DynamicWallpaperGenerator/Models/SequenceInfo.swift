//
//  SequenceInfo.swift
//  WallpapperLib
//
//  Created by Marcin Czachurski on 03/07/2018.
//  Copyright © 2018 Marcin Czachurski. All rights reserved.
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
