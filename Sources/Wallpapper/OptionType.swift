//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

enum OptionType: String {
    case help = "-h"
    case version = "-v"
    case input = "-i"
    case output = "-o"
    case extract = "-e"
    case unknown

    init(value: String) {
        switch value {
        case "-h": self = .help
        case "-v": self = .version
        case "-i": self = .input
        case "-o": self = .output
        case "-e": self = .extract
        default: self = .unknown
        }
    }
}
