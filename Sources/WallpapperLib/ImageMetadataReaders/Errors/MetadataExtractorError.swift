//
//  MetadataExtractorError.swift
//  WallpapperLib
//
//  Created by Marcin Czachurski on 21/10/2021.
//  Copyright © 2021 Marcin Czachurski. All rights reserved.
//

import Foundation

public enum MetadataExtractorError: WallpapperError {
    case imageSourceNotCreated
    case imageMetadataNotCreated
    
    public var message: String {
        switch self {
        case .imageSourceNotCreated:
            return "CGImageSource object cannot be created."
        case .imageMetadataNotCreated:
            return "CGImageMetadata object cannot be created."
        }
    }
}
