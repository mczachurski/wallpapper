//
//  MetadataExtractor.swift
//  wallpapper
//
//  Created by Marcin Czachurski on 20/01/2021.
//  Copyright © 2021 Marcin Czachurski. All rights reserved.
//

import Foundation
import AppKit
import AVFoundation

class MetadataExtractor {

    public func extract(imageData: Data) throws {
        let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil)
        guard let imageSourceValue = imageSource else {
            throw MetadataExtractorError.imageSourceNotCreated
        }
        
        let imageMetadata = CGImageSourceCopyMetadataAtIndex(imageSourceValue, 0, nil)
        guard let imageMetadataValue = imageMetadata else {
            throw MetadataExtractorError.imageMetadataNotCreated
        }
        
        CGImageMetadataEnumerateTagsUsingBlock(imageMetadataValue, nil, nil) { (value, metadataTag) -> Bool in

            let valueString = value as String
            print("---------------------------------------------------")
            print("Metadata key: \(valueString)")
            
            let tag = CGImageMetadataTagCopyValue(metadataTag)
            
            guard let valueTag = tag as? String else {
                print("\tError during convert tag into string")
                return true
            }
            
            if valueString.starts(with: "apple_desktop:solar") || valueString.starts(with: "apple_desktop:h24") {
                guard let decodedData = Data(base64Encoded: valueTag) else {
                    print("\tError during convert tag into binary data")
                    return true
                }
                
                let decoder = PropertyListDecoder()
                guard let sequenceInfo = try? decoder.decode(SequenceInfo.self, from: decodedData) else {
                    print("\tError during convert tag into object")
                    return true
                }
                
                if let apperance = sequenceInfo.apperance {
                    print("[APPERANCE]")
                    print("\timage index: \(apperance.darkIndex), dark")
                    print("\timage index: \(apperance.lightIndex), light")
                }
                
                if let solarItems = sequenceInfo.sequenceItems {
                    print("[SOLAR]")
                    for solarItem in solarItems {
                        print("\timage index: \(solarItem.imageIndex), azimuth: \(solarItem.azimuth), altitude: \(solarItem.altitude)")
                    }
                }
                
                if let timeItems = sequenceInfo.timeItems {
                    print("[TIME]")
                    for timeItem in timeItems {
                        print("\timage index: \(timeItem.imageIndex), time: \(timeItem.time)")
                    }
                }
            } else if valueString.starts(with: "apple_desktop:apr") {
                guard let decodedData = Data(base64Encoded: valueTag) else {
                    print("\tError during convert tag into binary data")
                    return false
                }
                
                let decoder = PropertyListDecoder()
                guard let apperance = try? decoder.decode(Apperance.self, from: decodedData) else {
                    print("\tError during convert tag into object")
                    return false
                }
                
                print("[APPERANCE]")
                print("\timage index: \(apperance.darkIndex), dark")
                print("\timage index: \(apperance.lightIndex), light")
            } else {
                print("\tvalue: \(valueTag)")
            }
            
            return true
        }
    }
}
