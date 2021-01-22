//
//  Program.swift
//  wallpapper-exif
//
//  Created by Marcin Czachurski on 21/10/2021.
//  Copyright © 2021 Marcin Czachurski. All rights reserved.
//

import Foundation
import WallpapperLib

class Program {
    let consoleIO = ConsoleIO()
    var inputFileNames: [String] = []
    var wallpapperItems: [WallpapperItem] = []
    
    func run() throws -> Bool {
        
        let (shouldBreak, resultCode) = self.proceedCommandLineArguments()
        if shouldBreak {
            return resultCode
        }
        
        for inputFileName in inputFileNames {
            let fileURL = try getPathToInputFile(inputFileName: inputFileName)
            let inputFileContents = try Data(contentsOf: fileURL)

            let locationExtractor = LocationExtractor()
            let imageLocation = try locationExtractor.extract(imageData: inputFileContents)

            let sc = SunCalculations(date: imageLocation.createDate,
                                     latitude: imageLocation.latitude,
                                     longitude: imageLocation.longitude)

            let position = sc.getSunPosition()

            let wallpapperItem = WallpapperItem(fileName: inputFileName,
                                                altitude: position.altitude,
                                                azimuth: position.azimuth)

            wallpapperItems.append(wallpapperItem)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(wallpapperItems)
        let jsonOptionslString = String(bytes: jsonData, encoding: .utf8)
        
        guard let jsonString = jsonOptionslString else {
            return false
        }
        
        self.consoleIO.writeMessage(jsonString, to: .standard)
        return true
    }
    
    private func getPathToInputFile(inputFileName: String) throws -> URL {
        return URL(fileURLWithPath: inputFileName)
    }
    
    private func proceedCommandLineArguments() -> (Bool, Bool) {
        if CommandLine.arguments.count == 1 {
            self.printUsage()
            return (true, false)
        }

        var optionIndex = 1
        while optionIndex < CommandLine.arguments.count {

            let option = CommandLine.arguments[optionIndex]
            let optionType = OptionType(value: option)

            switch optionType {
            case .help:
                self.printUsage()
                return (true, true)
            case .version:
                self.printVersion()
                return (true, true)
            default:
                let fileName = CommandLine.arguments[optionIndex]
                inputFileNames.append(fileName)
                break;
            }

            optionIndex = optionIndex + 1
        }

        if self.inputFileNames.count == 0 {
            self.consoleIO.writeMessage("unknown input file names.", to: .error)
            return (true, false)
        }

        return (false, false)
    }
    
    private func printVersion() {
        self.consoleIO.writeMessage("1.0.0")
    }
    
    private func printUsage() {

        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent

        self.consoleIO.writeMessage("\(executableName): [file1] [file2]")
        self.consoleIO.writeMessage("Command options are:")
        self.consoleIO.writeMessage(" -h\t\t\tshow this message and exit")
        self.consoleIO.writeMessage(" -v\t\t\tshow program version and exit")
    }
}
