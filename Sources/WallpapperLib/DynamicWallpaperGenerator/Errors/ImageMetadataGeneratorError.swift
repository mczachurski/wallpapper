//
//  ImageMetadataGeneratorError.swift
//  WallpapperLib
//
//  Created by Marcin Czachurski on 20/01/2021.
//  Copyright © 2021 Marcin Czachurski. All rights reserved.
//

import Foundation

public enum ImageMetadataGeneratorError: WallpapperError {
    case addTagIntoImageFailed
    case imageNotFinalized
    case namespaceNotRegistered
    case notSupportedSystem
    
    public var message: String {
        switch self {
        case .addTagIntoImageFailed:
            return "Add tag into image failed."
        case .imageNotFinalized:
            return "Image has not be finilized."
        case .namespaceNotRegistered:
            return "Namespave cannot be registered."
        case .notSupportedSystem:
            return "Not supported operating system."
        }
    }
}
