//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public class ConsoleIO {
    
    public init() {
    }
    
    public func writeMessage(_ message: String, to: OutputType = .standard) {
        switch to {
        case .standard:
            print(message)
        case .debug:
            fputs("\(message)", stdout)
            fflush(stdout)
        case .error:
            fputs("Error: \(message)\n", stderr)
        }
    }
}
