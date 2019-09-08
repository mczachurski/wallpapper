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
    let baseURL: URL
    let outputFileName: String
    let options = [kCGImageDestinationLossyCompressionQuality: 1.0]
    let consoleIO = ConsoleIO()

    init(picureInfos: [PictureInfo], baseURL: URL, outputFileName: String) {
        self.picureInfos = picureInfos
        self.baseURL = baseURL
        self.outputFileName = outputFileName
    }

    func run() throws {
        if #available(OSX 10.13, *) {
            let destinationData = NSMutableData()
            if let destination = CGImageDestinationCreateWithData(destinationData, AVFileType.heic as CFString, self.picureInfos.count, nil) {

                self.picureInfos.sort { (left, right) -> Bool in
                    return left.isPrimary == true
                }

                for (index, pictureInfo) in self.picureInfos.enumerated() {
                    let fileURL = URL(fileURLWithPath: pictureInfo.fileName, relativeTo: self.baseURL)

                    self.consoleIO.writeMessage("Reading image file: '\(fileURL.absoluteString)'...", to: .debug)
                    guard let orginalImage = NSImage(contentsOf: fileURL) else {
                        self.consoleIO.writeMessage("ERROR.\n", to: .debug)
                        return
                    }

                    self.consoleIO.writeMessage("OK.\n", to: .debug)

                    if let cgImage = orginalImage.CGImage {

                        if index == 0 {
                            let imageMetadata = try createImageMetadata()

                            self.consoleIO.writeMessage("Adding image and metadata...", to: .debug)
                            CGImageDestinationAddImageAndMetadata(destination, cgImage, imageMetadata, self.options as CFDictionary)
                            self.consoleIO.writeMessage("OK.\n", to: .debug)
                        } else {
                            self.consoleIO.writeMessage("Adding image...", to: .debug)
                            CGImageDestinationAddImage(destination, cgImage, self.options as CFDictionary)
                            self.consoleIO.writeMessage("OK.\n", to: .debug)
                        }
                    }
                }

                self.consoleIO.writeMessage("Finalizing image container...", to: .debug)
                guard CGImageDestinationFinalize(destination) else {
                    throw ImageFinalizingError()
                }
                self.consoleIO.writeMessage("OK.\n", to: .debug)

                let outputURL = URL(fileURLWithPath: self.outputFileName)
                self.consoleIO.writeMessage("Saving data to file '\(outputURL.absoluteString)'...", to: .debug)
                let imageData = destinationData as Data
                try imageData.write(to: outputURL)
                self.consoleIO.writeMessage("OK.\n", to: .debug)
            }
        } else {
            throw NotSupportedSystemError()
        }
    }

    func createImageMetadata() throws -> CGMutableImageMetadata {
        let imageMetadata = CGImageMetadataCreateMutable()
        let sequenceInfo = self.createPropertyList()

        if sequenceInfo.si != nil {
            try self.appendDesktopProperties(to: imageMetadata, withKey: "solar", value: sequenceInfo)
        } else if sequenceInfo.ti != nil {
            try self.appendDesktopProperties(to: imageMetadata, withKey: "h24", value: sequenceInfo)
        } else {
            try self.appendDesktopProperties(to: imageMetadata, withKey: "apr", value: sequenceInfo.ap)
        }

        return imageMetadata
    }

    func appendDesktopProperties<T>(to imageMetadata: CGMutableImageMetadata, withKey key: String, value: T) throws where T: Codable {
        guard CGImageMetadataRegisterNamespaceForPrefix(imageMetadata, "http://ns.apple.com/namespace/1.0/" as CFString, "apple_desktop" as CFString, nil) else {
            throw NamespaceNotRegisteredError()
        }

        let base64PropertyList = try self.createBase64PropertyList(value: value)
        let imageMetadataTag = CGImageMetadataTagCreate("http://ns.apple.com/namespace/1.0/" as CFString, "apple_desktop" as CFString, key as CFString, CGImageMetadataType.string, base64PropertyList as CFTypeRef)

        guard CGImageMetadataSetTagWithPath(imageMetadata, nil, "apple_desktop:\(key)" as CFString, imageMetadataTag!) else {
            throw AddTagImageError()
        }
    }

    func createPropertyList() -> SequenceInfo {

        let sequenceInfo = SequenceInfo()

        for (index, item) in self.picureInfos.enumerated() {

            if item.isForLight ?? false {
                sequenceInfo.ap.l = index
            }

            if item.isForDark ?? false {
                sequenceInfo.ap.d = index
            }

            if let altitude = item.altitude, let azimuth = item.azimuth {
                let sequenceItem = SequenceItem()
                sequenceItem.a = altitude
                sequenceItem.z = azimuth
                sequenceItem.i = index

                if sequenceInfo.si == nil {
                    sequenceInfo.si = []
                }

                sequenceInfo.si?.append(sequenceItem)
            }

            if let time = item.time {
                let timeItem = TimeItem()
                timeItem.i = index
                let hour = Calendar.current.component(.hour, from: time)
                timeItem.t = Double(hour) / 24.0

                if sequenceInfo.ti == nil {
                    sequenceInfo.ti = []
                }

                sequenceInfo.ti?.append(timeItem)
            }
        }

        return sequenceInfo
    }

    func createBase64PropertyList<T>(value: T) throws -> String where T: Codable {

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let plistData = try encoder.encode(value)

        let base64PropertyList = plistData.base64EncodedString()
        return base64PropertyList
    }
}
