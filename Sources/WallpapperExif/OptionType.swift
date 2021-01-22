//
//  OptionType.swift
//  wallpapper-exif
//
//  Created by Marcin Czachurski on 21/10/2021.
//  Copyright © 2021 Marcin Czachurski. All rights reserved.
//

import Foundation

enum OptionType: String {
    case help = "-h"
    case version = "-v"
    case unknown

    init(value: String) {
        switch value {
        case "-h": self = .help
        case "-v": self = .version
        default: self = .unknown
        }
    }
}
