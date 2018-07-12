//
//  NSImage.swift
//  wallpapper
//
//  Created by Marcin Czachurski on 11/07/2018.
//  Copyright © 2018 Marcin Czachurski. All rights reserved.
//

import Foundation
import AppKit

extension NSImage {
    @objc var CGImage: CGImage? {
        get {
            guard let imageData = self.tiffRepresentation else { return nil }
            guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
            return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
        }
    }
}
