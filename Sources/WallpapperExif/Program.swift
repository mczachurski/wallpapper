//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import WallpapperLib

class Program {
    let consoleIO = ConsoleIO()
    var inputFileNames: [String] = []
    var wallpapperItems: [WallpapperItem] = []
    
    func run() -> Bool {
        
        let (shouldBreak, resultCode) = self.proceedCommandLineArguments()
        if shouldBreak {
            return resultCode
        }
        
        return self.generateSunPositions()
    }
    
    private func generateSunPositions() -> Bool {
        do {
            for inputFileName in inputFileNames {
                let fileURL = try getPathToInputFile(inputFileName: inputFileName)
                self.consoleIO.writeMessage("Reading file: '\(fileURL.absoluteString)'...", to: .debug)
                let inputFileContents = try Data(contentsOf: fileURL)
                self.consoleIO.writeMessage("OK.\n", to: .debug)

                self.consoleIO.writeMessage("Extracting Exif information...", to: .debug)
                let locationExtractor = LocationExtractor()
                let imageLocation = try locationExtractor.extract(imageData: inputFileContents)
                self.consoleIO.writeMessage("OK.\n", to: .debug)

                self.consoleIO.writeMessage("Calculating Sun position...", to: .debug)
                let sunCalculations = SunCalculations(imageLocation: imageLocation)
                let position = sunCalculations.getSunPosition()
                self.consoleIO.writeMessage("OK.\n", to: .debug)

                let wallpapperItem = WallpapperItem(fileName: inputFileName, altitude: position.altitude, azimuth: position.azimuth)
                wallpapperItems.append(wallpapperItem)
            }

            return try self.printJsonString(wallpapperItems: wallpapperItems)
        } catch (let error as WallpapperError) {
            self.consoleIO.writeMessage("Unexpected error occurs: \(error.message)", to: .error)
            return false
        } catch {
            self.consoleIO.writeMessage("Unexpected error occurs: \(error)", to: .error)
            return false
        }
    }
    
    private func printJsonString(wallpapperItems: [WallpapperItem]) throws -> Bool {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let jsonData = try encoder.encode(wallpapperItems)
        let jsonOptionslString = String(bytes: jsonData, encoding: .utf8)
        
        guard let jsonString = jsonOptionslString else {
            self.consoleIO.writeMessage("Error during converting object into string", to: .error)
            return false
        }
        
        self.consoleIO.writeMessage("Output:", to: .standard)
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
        self.consoleIO.writeMessage("1.7.3")
    }
    
    private func printUsage() {

        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent

        self.consoleIO.writeMessage("\(executableName): [file1] [file2]")
        self.consoleIO.writeMessage("Command options are:")
        self.consoleIO.writeMessage(" -h\t\t\tshow this message and exit")
        self.consoleIO.writeMessage(" -v\t\t\tshow program version and exit")
    }
}
