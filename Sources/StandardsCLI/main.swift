import Foundation

let arguments = CommandLine.arguments

// Get directory path from arguments or use current directory
let directoryPath: String
if arguments.count > 1 {
    directoryPath = arguments[1]
} else {
    directoryPath = FileManager.default.currentDirectoryPath
}

// Resolve path to URL
let url: URL
if directoryPath == "." {
    url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
} else {
    url = URL(fileURLWithPath: directoryPath)
}

// Validate directory exists
var isDirectory: ObjCBool = false
guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
      isDirectory.boolValue else {
    print("Error: '\(directoryPath)' is not a valid directory")
    exit(1)
}

do {
    // Run validation
    let validator = MarkdownValidator()
    let result = try validator.validate(directory: url)

    // Print results
    if result.isValid {
        print("✓ All Markdown files have lines of 120 characters or less")
        exit(0)
    } else {
        print("✗ Found line length violations:\n")

        for fileViolation in result.violations {
            let relativePath = url.path.isEmpty ? fileViolation.file.path :
                fileViolation.file.path.replacingOccurrences(of: url.path + "/", with: "")
            print("\(relativePath):")

            for violation in fileViolation.violations {
                print("  Line \(violation.lineNumber): \(violation.length) characters " +
                      "(exceeds \(violation.maxLength))")
            }
            print("")
        }

        exit(1)
    }
} catch {
    print("Error: \(error.localizedDescription)")
    exit(1)
}
