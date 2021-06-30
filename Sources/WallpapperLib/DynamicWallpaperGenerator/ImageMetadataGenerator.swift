//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import ImageIO

public class ImageMetadataGenerator {
    private let pictureInfos: [PictureInfo]
    
    public lazy var images: [String] = {
        let sordedPictureInfors = pictureInfos.sorted(by: { (left, right) -> Bool in
            return left.isPrimary == true
        })
        
        let sortedFileNames = sordedPictureInfors.map { pictureInfo -> String in
            pictureInfo.fileName
        }
        var addedDict = [String: Bool]()
        return sortedFileNames.filter { addedDict.updateValue(true, forKey: $0) == nil }
    }()
    
    init(pictureInfos: [PictureInfo]) {
        self.pictureInfos = pictureInfos
    }
    
    public func getImageMetadata() throws -> CGMutableImageMetadata {
        let imageMetadata = CGImageMetadataCreateMutable()
        let sequenceInfo = self.createPropertyList()

        if sequenceInfo.sequenceItems != nil {
            try self.appendDesktopProperties(to: imageMetadata, withKey: "solar", value: sequenceInfo)
        } else if sequenceInfo.timeItems != nil {
            try self.appendDesktopProperties(to: imageMetadata, withKey: "h24", value: sequenceInfo)
        } else {
            try self.appendDesktopProperties(to: imageMetadata, withKey: "apr", value: sequenceInfo.apperance)
        }

        return imageMetadata
    }

    private func appendDesktopProperties<T>(to imageMetadata: CGMutableImageMetadata, withKey key: String, value: T) throws where T: Codable {
        guard CGImageMetadataRegisterNamespaceForPrefix(imageMetadata,
                                                        "http://ns.apple.com/namespace/1.0/" as CFString,
                                                        "apple_desktop" as CFString,
                                                        nil) else {
            throw ImageMetadataGeneratorError.namespaceNotRegistered
        }

        let base64PropertyList = try self.createBase64PropertyList(value: value)
        let imageMetadataTag = CGImageMetadataTagCreate("http://ns.apple.com/namespace/1.0/" as CFString,
                                                        "apple_desktop" as CFString,
                                                        key as CFString,
                                                        CGImageMetadataType.string,
                                                        base64PropertyList as CFTypeRef)

        guard CGImageMetadataSetTagWithPath(imageMetadata, nil, "apple_desktop:\(key)" as CFString, imageMetadataTag!) else {
            throw ImageMetadataGeneratorError.addTagIntoImageFailed
        }
    }

    private func createPropertyList() -> SequenceInfo {

        let sequenceInfo = SequenceInfo()

        for (index, item) in self.pictureInfos.enumerated() {

            if item.isForLight != nil || item.isForDark != nil {
                if sequenceInfo.apperance == nil {
                    sequenceInfo.apperance = Apperance()
                }
            }
            
            if item.isForLight ?? false {
                sequenceInfo.apperance?.lightIndex = index
            }

            if item.isForDark ?? false {
                sequenceInfo.apperance?.darkIndex = index
            }

            if let altitude = item.altitude, let azimuth = item.azimuth {
                let sequenceItem = SequenceItem()
                sequenceItem.altitude = altitude
                sequenceItem.azimuth = azimuth
                sequenceItem.imageIndex = self.getImageIndex(fileName: item.fileName)

                if sequenceInfo.sequenceItems == nil {
                    sequenceInfo.sequenceItems = []
                }

                sequenceInfo.sequenceItems?.append(sequenceItem)
            }

            if let time = item.time {
                let timeItem = TimeItem()
                timeItem.imageIndex = self.getImageIndex(fileName: item.fileName)
                let hour = Calendar.current.component(.hour, from: time)
                timeItem.time = Double(hour) / 24.0

                if sequenceInfo.timeItems == nil {
                    sequenceInfo.timeItems = []
                }

                sequenceInfo.timeItems?.append(timeItem)
            }
        }

        return sequenceInfo
    }

    private func createBase64PropertyList<T>(value: T) throws -> String where T: Codable {

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let plistData = try encoder.encode(value)

        let base64PropertyList = plistData.base64EncodedString()
        return base64PropertyList
    }
    
    private func getImageIndex(fileName: String) -> Int {
        return self.images.firstIndex(of: fileName) ?? 0
    }
}
