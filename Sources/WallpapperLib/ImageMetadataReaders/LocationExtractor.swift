//
//  LocationExtractor.swift
//  WallpapperLib
//
//  Created by Marcin Czachurski on 21/10/2021.
//  Copyright © 2021 Marcin Czachurski. All rights reserved.
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
        
        var lat: Double?
        var lng: Double?
        var dat: Date?
        
        CGImageMetadataEnumerateTagsUsingBlock(imageMetadataValue, nil, nil) { (value, metadataTag) -> Bool in

            let valueString = value as String
            let tag = CGImageMetadataTagCopyValue(metadataTag)
            // print("Metadata key: '\(valueString)' - '\(tag)'")
            
            switch valueString {
            case "exif:GPSLatitude":
                guard let valueTag = tag as? String else {
                    return false
                }
                
                lat = self.toDecimaDegrees(value: valueTag)
                break
            case "exif:GPSLongitude":
                guard let valueTag = tag as? String else {
                    return false
                }

                lng = self.toDecimaDegrees(value: valueTag)
                break
            case "xmp:CreateDate":
                guard let valueTag = tag as? String else {
                    return false
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                dat = dateFormatter.date(from: valueTag)
                break
            default:
                break
            }
            
            return true
        }
        
        guard let latitude = lat else {
            throw ExifExtractorError.missingLatitude
        }
        
        guard let longitude = lng else {
            throw ExifExtractorError.missingLongitude
        }

        guard let createDate = dat else {
            throw ExifExtractorError.missingCreationDate
        }
        
        return ImageLocation(latitude: latitude, longitude: longitude, createDate: createDate)
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
