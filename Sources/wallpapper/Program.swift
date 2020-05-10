//
//  Panagram.swift
//  wallpapper
//
//  Created by Marcin Czachurski on 03/07/2018.
//  Copyright © 2018 Marcin Czachurski. All rights reserved.
//

import Foundation

class Program {

    let consoleIO = ConsoleIO()
    var inputFileName = ""
    var outputFileName = "output.heic"

    func run() -> Bool {

        let (shouldBreak, resultCode) = self.proceedCommandLineArguments()
        if shouldBreak {
            return resultCode
        }

        do {
            let fileURL = try self.getPathToJsonFile()
            self.consoleIO.writeMessage("Reading JSON file: '\(fileURL.absoluteString)'...", to: .debug)
            let inputFileContents = try Data(contentsOf: fileURL)
            self.consoleIO.writeMessage("OK.\n", to: .debug)
            
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            decoder.dateDecodingStrategy = .formatted(formatter)

            self.consoleIO.writeMessage("Decoding JSON file...", to: .debug)
            let pictureInfos = try decoder.decode([PictureInfo].self, from: inputFileContents)
            self.consoleIO.writeMessage("OK (\(pictureInfos.count) pictures).\n", to: .debug)

            let baseURL = fileURL.deletingLastPathComponent()
            let wallpaperGenerator = WallpaperGenerator()
            try wallpaperGenerator.generate(pictureInfos: pictureInfos, baseURL: baseURL, outputFileName: self.outputFileName);

        } catch {
            self.consoleIO.writeMessage("type: \(error)", to: .error)
            return false
        }

        return true
    }

    func getPathToJsonFile() throws -> URL {
        return URL(fileURLWithPath: inputFileName)
    }

    func proceedCommandLineArguments() -> (Bool, Bool) {
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
            case .input:
                let inputNameOptionIndex = optionIndex + 1
                if inputNameOptionIndex < CommandLine.arguments.count {
                    self.inputFileName = CommandLine.arguments[inputNameOptionIndex]
                }

                optionIndex = inputNameOptionIndex
            case .output:
                let outputNameOptionIndex = optionIndex + 1
                if outputNameOptionIndex < CommandLine.arguments.count {
                    self.outputFileName = CommandLine.arguments[outputNameOptionIndex]
                }

                optionIndex = outputNameOptionIndex
            default:
                break;
            }

            optionIndex = optionIndex + 1
        }

        if self.inputFileName == "" {
            self.consoleIO.writeMessage("unknown input file name.", to: .error)
            return (true, false)
        }

        return (false, false)
    }

    func printVersion() {
        self.consoleIO.writeMessage("1.5.0")
    }

    func printUsage() {

        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent

        self.consoleIO.writeMessage("\(executableName): [command_option] -i inputFile")
        self.consoleIO.writeMessage("Command options are:")
        self.consoleIO.writeMessage(" -h\t\t\tshow this message and exit")
        self.consoleIO.writeMessage(" -v\t\t\tshow program version and exit")
        self.consoleIO.writeMessage(" -o\t\t\toutput file name (default is 'output.heic')")
        self.consoleIO.writeMessage(" -i\t\t\tinput file name, json file with wallpaper description")
    }
}
