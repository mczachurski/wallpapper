//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import AppKit
import AVFoundation

public class LocationExtractor {
    
    public init() {
    }
    
    public func extract(imageData: Data) throws -> ImageLocation {
        let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil)
        guard let imageSourceValue = imageSource else {
            throw MetadataExtractorError.imageSourceNotCreated
        }
        
        let imageMetadata = CGImageSourceCopyMetadataAtIndex(imageSourceValue, 0, nil)
        guard let imageMetadataValue = imageMetadata else {
            throw MetadataExtractorError.imageMetadataNotCreated
        }
        
        var latRaw: String?
        var lat: Double?
        
        var lngRaw: String?
        var lng: Double?
        
        var datRaw: String?
        var dat: Date?
        
        CGImageMetadataEnumerateTagsUsingBlock(imageMetadataValue, nil, nil) { (value, metadataTag) -> Bool in

            let valueString = value as String
            let tag = CGImageMetadataTagCopyValue(metadataTag)
            
            switch valueString {
            case "exif:GPSLatitude":
                guard let valueTag = tag as? String else {
                    return false
                }
                
                latRaw = valueTag
                lat = self.toDecimaDegrees(value: valueTag)
                break
            case "exif:GPSLongitude":
                guard let valueTag = tag as? String else {
                    return false
                }

                lngRaw = valueTag
                lng = self.toDecimaDegrees(value: valueTag)
                break
            case "xmp:CreateDate":
                guard let valueTag = tag as? String else {
                    return false
                }
                
                datRaw = valueTag
                dat = self.toDate(value: valueTag)
                break
            default:
                break
            }
            
            return true
        }

        guard latRaw != nil else {
            throw ExifExtractorError.missingLatitude
        }
        
        guard lngRaw != nil else {
            throw ExifExtractorError.missingLongitude
        }

        guard datRaw != nil else {
            throw ExifExtractorError.missingCreationDate
        }
        
        guard let latitude = lat else {
            throw ExifExtractorError.notSupportedLatitude(latitude: latRaw)
        }
        
        guard let longitude = lng else {
            throw ExifExtractorError.notSupportedLongitude(longitiude: lngRaw)
        }

        guard let createDate = dat else {
            throw ExifExtractorError.notSupportedCreationDate(date: datRaw)
        }
        
        return ImageLocation(latitude: latitude, longitude: longitude, createDate: createDate)
    }
    
    func toDate(value: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return dateFormatter.date(from: value)
    }
    
    func toDecimaDegrees(value: String) -> Double? {
        let parts = value.split(separator: ",")
        guard parts.count == 2 else {
            return nil
        }
        
        let deg = Double(parts[0])
        
        let minParts = parts[1].split(separator: ".")
        guard minParts.count >= 1 else {
            return nil
        }
        
        let min = Double(minParts[0])
        
        guard let degrees = deg else {
            return nil
        }

        guard let minutes = min else {
            return nil
        }
        
        return degrees + (minutes / 60)
    }
}
