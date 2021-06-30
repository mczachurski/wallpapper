//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public enum ExifExtractorError: WallpapperError {
    case imageSourceNotCreated
    case imageMetadataNotCreated
    case missingCreationDate
    case missingLongitude
    case missingLatitude
    case notSupportedCreationDate(date: String?)
    case notSupportedLongitude(longitiude: String?)
    case notSupportedLatitude(latitude: String?)
    
    public var message: String {
        switch self {
        case .imageSourceNotCreated:
            return "CGImageSource object cannot be created."
        case .imageMetadataNotCreated:
            return "CGImageMetadata object cannot be created."
        case .missingCreationDate:
            return "Missing 'xmp:CreateDate' exif metadata."
        case .missingLongitude:
            return "Missing 'exif:GPSLongitude' exif metadata."
        case .missingLatitude:
            return "Missing 'exif:GPSLatitude' exif metadata."
        case .notSupportedCreationDate(let date):
            return "Not supported format of creation date: '\(date ?? "")'."
        case .notSupportedLongitude(let longitiude):
            return "Not supported format of longitiude: '\(longitiude ?? "")'."
        case .notSupportedLatitude(let latitude):
            return "Not supported format of latitude: '\(latitude ?? "")'."
        }
    }
}
