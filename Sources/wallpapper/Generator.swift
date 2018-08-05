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

    var picureInfos: [PictureInfo]
    let outputFileName: String
    let options = [kCGImageDestinationLossyCompressionQuality: 1.0]
    let consoleIO = ConsoleIO()

    init(picureInfos: [PictureInfo], outputFileName: String) {
        self.picureInfos = picureInfos
        self.outputFileName = outputFileName
    }

    func run() throws {
        if #available(OSX 10.13, *) {
            let destinationData = NSMutableData()
            let currentDirectory = FileManager.default.currentDirectoryPath

            if let currentDirectoryURL = URL(string: "file://\(currentDirectory)"),
                let destination = CGImageDestinationCreateWithData(destinationData, AVFileType.heic as CFString, self.picureInfos.count, nil) {

                self.picureInfos.sort { (left, right) -> Bool in
                    return left.isPrimary == true
                }

                for (index, pictureInfo) in self.picureInfos.enumerated() {
                    let fileURL = currentDirectoryURL.appendingPathComponent(pictureInfo.fileName)

                    self.consoleIO.writeMessage("Reading image file: '\(fileURL)'...")
                    let orginalImage = NSImage(contentsOf: fileURL)
                    self.consoleIO.writeMessage("OK.\n")

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

                            self.consoleIO.writeMessage("Adding image and metadata...")
                            CGImageDestinationAddImageAndMetadata(destination, cgImage, imageMetadata, self.options as CFDictionary)
                            self.consoleIO.writeMessage("OK.\n")
                        } else {
                            self.consoleIO.writeMessage("Adding image...")
                            CGImageDestinationAddImage(destination, cgImage, self.options as CFDictionary)
                            self.consoleIO.writeMessage("OK.\n")
                        }
                    }
                }

                self.consoleIO.writeMessage("Finalizing image container...")
                guard CGImageDestinationFinalize(destination) else {
                    throw ImageFinalizingError()
                }
                self.consoleIO.writeMessage("OK.\n")

                self.consoleIO.writeMessage("Saving data to file '\(self.outputFileName)'...")
                let imageData = destinationData as Data
                let outputURL = currentDirectoryURL.appendingPathComponent(self.outputFileName)
                try imageData.write(to: outputURL)
                self.consoleIO.writeMessage("OK.\n")
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
            sequenceItem.i = index

            if item.isForLight {
                sequenceInfo.ap.l = index
            }

            if item.isForDark {
                sequenceInfo.ap.d = index
            }

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
