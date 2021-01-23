//
//  main.swift
//  wallpapper-exif
//
//  Created by Marcin Czachurski on 21/10/2021.
//  Copyright © 2021 Marcin Czachurski. All rights reserved.
//

import Foundation

let program = Program()
let result = program.run()

exit(result ? EXIT_SUCCESS : EXIT_FAILURE)
