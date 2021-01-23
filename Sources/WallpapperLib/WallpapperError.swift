//
//  WallpapperError.swift
//  WallpapperLib
//
//  Created by Marcin Czachurski on 22/10/2021.
//  Copyright © 2021 Marcin Czachurski. All rights reserved.
//

import Foundation

public protocol WallpapperError: Error {
    var message: String { get }
}
