//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import WallpapperLib

class Program {

    let consoleIO = ConsoleIO()
    var inputFileName = ""
    var outputFileName: String? = nil
    var shouldExtract = false

    func run() -> Bool {

        let (shouldBreak, resultCode) = self.proceedCommandLineArguments()
        if shouldBreak {
            return resultCode
        }

        if self.shouldExtract {
            return self.extractMetadata()
        } else {
            return self.generateImage()
        }
    }

    private func generateImage() -> Bool {
        do {
            let fileURL = try self.getPathToInputFile()
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
            let fileName = self.outputFileName ?? "output.heic"
            try wallpaperGenerator.generate(pictureInfos: pictureInfos, baseURL: baseURL, outputFileName: fileName);
        } catch (let error as WallpapperError) {
            self.consoleIO.writeMessage("Unexpected error occurs: \(error.message)", to: .error)
            return false
        } catch {
            self.consoleIO.writeMessage("Unexpected error occurs: \(error)", to: .error)
            return false
        }
        
        return true
    }
    
    private func extractMetadata() -> Bool {
        do {
            let fileURL = try self.getPathToInputFile()
            self.consoleIO.writeMessage("Reading HEIC file: '\(fileURL.absoluteString)'...", to: .debug)
            let inputFileContents = try Data(contentsOf: fileURL)
            
            let dynamicWallpaperExtractor = DynamicWallpaperExtractor()
            try dynamicWallpaperExtractor.extract(imageData: inputFileContents, outputFileName: self.outputFileName)
        } catch {
            self.consoleIO.writeMessage("Error occurs during metadata extraction: \(error)", to: .error)
            return false
        }
        
        return true
    }
    
    private func getPathToInputFile() throws -> URL {
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
            case .extract:
                let inputNameOptionIndex = optionIndex + 1
                if inputNameOptionIndex < CommandLine.arguments.count {
                    self.inputFileName = CommandLine.arguments[inputNameOptionIndex]
                }

                optionIndex = inputNameOptionIndex
                
                self.shouldExtract = true
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

    private func printVersion() {
        self.consoleIO.writeMessage("1.7.3")
    }

    private func printUsage() {

        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent

        self.consoleIO.writeMessage("\(executableName): [command_option] [-i jsonFile] [-e heicFile]")
        self.consoleIO.writeMessage("Command options are:")
        self.consoleIO.writeMessage(" -h\t\t\tshow this message and exit")
        self.consoleIO.writeMessage(" -v\t\t\tshow program version and exit")
        self.consoleIO.writeMessage(" -o\t\t\toutput file name (default is 'output.heic')")
        self.consoleIO.writeMessage(" -i\t\t\tinput .json file with wallpaper description")
        self.consoleIO.writeMessage(" -e\t\t\tinput .heic file to extract metadata")
    }
}
