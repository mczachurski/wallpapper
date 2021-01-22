//
//  ExifExtractorError.swift
//  WallpapperLib
//
//  Created by Marcin Czachurski on 21/10/2021.
//  Copyright © 2021 Marcin Czachurski. All rights reserved.
//

import Foundation

public enum ExifExtractorError: Error {
    case imageSourceNotCreated
    case imageMetadataNotCreated
    case errorDuringMetadataValueParsing
    case missingCreationDate
    case missingLongitude
    case missingLatitude
}
