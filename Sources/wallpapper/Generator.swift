//
//  Generator.swift
//  wallpapper
//
//  Created by Marcin Czachurski on 02/07/2018.
//  Copyright © 2018 Marcin Czachurski. All rights reserved.
//

import Foundation
import AppKit
import AVFoundation

class Generator {

    let picureInfos: [PictureInfo]
    let outputFileName: String
    let options = [kCGImageDestinationLossyCompressionQuality: 1.0]

    init(picureInfos: [PictureInfo], outputFileName: String) {
        self.picureInfos = picureInfos
        self.outputFileName = outputFileName
    }

    func run() throws {
        if #available(OSX 10.13, *) {
            let destinationData = NSMutableData()
            let currentDirectory = FileManager.default.currentDirectoryPath

            if let currentDirectoryURL = URL(string: "file://\(currentDirectory)"),
                let destination = CGImageDestinationCreateWithData(destinationData, AVFileType.heic as CFString, 16, nil) {

                for (index, pictureInfo) in self.picureInfos.enumerated() {
                    let fileURL = currentDirectoryURL.appendingPathComponent(pictureInfo.fileName)
                    let orginalImage = NSImage(contentsOf: fileURL)

                    if let cgImage = orginalImage?.CGImage {

                        if index == 0 {
                            let imageMetadata = CGImageMetadataCreateMutable()

                            guard CGImageMetadataRegisterNamespaceForPrefix(imageMetadata, "http://ns.apple.com/namespace/1.0/" as CFString, "apple_desktop" as CFString, nil) else {
                                throw NamespaceNotRegisteredError()
                            }

                            let sequenceInfo = self.createPropertyList()
                            let base64PropertyList = try self.createBase64PropertyList(sequenceInfo: sequenceInfo)

                            let imageMetadataTag = CGImageMetadataTagCreate("http://ns.apple.com/namespace/1.0/" as CFString, "apple_desktop" as CFString, "solar" as CFString, CGImageMetadataType.string, base64PropertyList as CFTypeRef)

                            guard CGImageMetadataSetTagWithPath(imageMetadata, nil, "apple_desktop:solar" as CFString, imageMetadataTag!) else {
                                throw AddTagImageError()
                            }

                            CGImageDestinationAddImageAndMetadata(destination, cgImage, imageMetadata, self.options as CFDictionary)
                        } else {
                            CGImageDestinationAddImage(destination, cgImage, self.options as CFDictionary)
                        }
                    }
                }

                CGImageDestinationFinalize(destination)
                let imageData = destinationData as Data

                let outputURL = currentDirectoryURL.appendingPathComponent(self.outputFileName)
                try imageData.write(to: outputURL)
            }
        } else {
            throw NotSupportedSystemError()
        }
    }

    func createPropertyList() -> SequenceInfo {

        let sequenceInfo = SequenceInfo()

        for (index, item) in self.picureInfos.enumerated() {
            let sequenceItem = SequenceItem()
            sequenceItem.a = item.altitude
            sequenceItem.z = item.azimuth
            sequenceItem.o = item.themeMode == .both ? 0 : 1
            sequenceItem.i = index

            sequenceInfo.si.append(sequenceItem)
        }

        return sequenceInfo
    }

    func createBase64PropertyList(sequenceInfo: SequenceInfo) throws -> String {

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let plistData = try encoder.encode(sequenceInfo)

        let base64PropertyList = plistData.base64EncodedString()
        return base64PropertyList
    }
}
