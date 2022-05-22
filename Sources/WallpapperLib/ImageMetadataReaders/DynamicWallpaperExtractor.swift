//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import AppKit
import AVFoundation

public class DynamicWallpaperExtractor {
    let consoleIO = ConsoleIO()

    public init() {
    }
    
    public func extract(imageData: Data, outputFileName: String?) throws {
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
            self.consoleIO.writeMessage("---------------------------------------------------")
            self.consoleIO.writeMessage("Metadata key: \(valueString)")
            
            let tag = CGImageMetadataTagCopyValue(metadataTag)
            
            guard let valueTag = tag as? String else {
                self.consoleIO.writeMessage("\tError during convert tag into string")
                return true
            }
            
            if valueString.starts(with: "apple_desktop:solar") || valueString.starts(with: "apple_desktop:h24") {
                guard let decodedData = Data(base64Encoded: valueTag) else {
                    self.consoleIO.writeMessage("\tError during convert tag into binary data")
                    return true
                }
                
                if let outputFileName = outputFileName {
                    self.saveImage(decodedData: decodedData, outputFileName: outputFileName)
                }
                
                let decoder = PropertyListDecoder()
                guard let sequenceInfo = try? decoder.decode(SequenceInfo.self, from: decodedData) else {
                    self.consoleIO.writeMessage("\tError during convert tag into object")
                    return true
                }
                
                if let apperance = sequenceInfo.apperance {
                    self.consoleIO.writeMessage("[APPERANCE]")
                    self.consoleIO.writeMessage("\timage index: \(apperance.darkIndex), dark")
                    self.consoleIO.writeMessage("\timage index: \(apperance.lightIndex), light")
                }
                
                if let solarItems = sequenceInfo.sequenceItems {
                    self.consoleIO.writeMessage("[SOLAR]")
                    for solarItem in solarItems {
                        self.consoleIO.writeMessage("\timage index: \(solarItem.imageIndex), azimuth: \(solarItem.azimuth), altitude: \(solarItem.altitude)")
                    }
                }
                
                if let timeItems = sequenceInfo.timeItems {
                    self.consoleIO.writeMessage("[TIME]")
                    for timeItem in timeItems {
                        self.consoleIO.writeMessage("\timage index: \(timeItem.imageIndex), time: \(timeItem.time)")
                    }
                }
            } else if valueString.starts(with: "apple_desktop:apr") {
                guard let decodedData = Data(base64Encoded: valueTag) else {
                    self.consoleIO.writeMessage("\tError during convert tag into binary data")
                    return false
                }
                
                if let outputFileName = outputFileName {
                    self.saveImage(decodedData: decodedData, outputFileName: outputFileName)
                }
                
                let decoder = PropertyListDecoder()
                guard let apperance = try? decoder.decode(Apperance.self, from: decodedData) else {
                    self.consoleIO.writeMessage("\tError during convert tag into object")
                    return false
                }
                
                self.consoleIO.writeMessage("[APPERANCE]")
                self.consoleIO.writeMessage("\timage index: \(apperance.darkIndex), dark")
                self.consoleIO.writeMessage("\timage index: \(apperance.lightIndex), light")
            } else {
                self.consoleIO.writeMessage("\tvalue: \(valueTag)")
            }
            
            return true
        }
    }
    
    private func saveImage(decodedData: Data, outputFileName:  String) {
        let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let plistFile = path.appendingPathComponent(outputFileName)
        do {
            try decodedData.write(to: plistFile)
            self.consoleIO.writeMessage("\tSaved plist file: \(plistFile)")
        }
        catch {
            self.consoleIO.writeMessage("\tError during writing plist file: \(plistFile)")
        }
    }
}
