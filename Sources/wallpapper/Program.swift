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
            let currentDirectory = FileManager.default.currentDirectoryPath

            guard let currentDirectoryURL = URL(string: "file://\(currentDirectory)") else {
                throw InputFileNotExistsError(currentDirectory: currentDirectory)
            }

            let fileURL = currentDirectoryURL.appendingPathComponent(inputFileName)

            self.consoleIO.writeMessage("Reading JSON file: '\(fileURL)'...", to: .debug)
            let inputFileContents = try Data(contentsOf: fileURL)
            self.consoleIO.writeMessage("OK.\n", to: .debug)
            
            let decoder = JSONDecoder()
            self.consoleIO.writeMessage("Decoding JSON file...", to: .debug)
            let picureInfos = try decoder.decode([PictureInfo].self, from: inputFileContents)
            self.consoleIO.writeMessage("OK (\(picureInfos.count) pictures).\n", to: .debug)

            let generator = Generator(picureInfos: picureInfos, outputFileName: self.outputFileName)
            try generator.run()

        } catch let inputError as InputFileNotExistsError {
            self.consoleIO.writeMessage("type: '\(inputError)'. Current directory: '\(inputError.currentDirectory)'. ", to: .error)
            return false
        }
        catch {
            self.consoleIO.writeMessage("type: \(error)", to: .error)
            return false
        }

        return true
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
        self.consoleIO.writeMessage("1.2.1")
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
