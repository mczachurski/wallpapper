//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public enum ImageMetadataGeneratorError: WallpapperError {
    case addTagIntoImageFailed
    case imageNotFinalized
    case namespaceNotRegistered
    case notSupportedSystem
    
    public var message: String {
        switch self {
        case .addTagIntoImageFailed:
            return "Add tag into image failed."
        case .imageNotFinalized:
            return "Image has not be finilized."
        case .namespaceNotRegistered:
            return "Namespave cannot be registered."
        case .notSupportedSystem:
            return "Not supported operating system."
        }
    }
}
