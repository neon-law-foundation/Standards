import Foundation

struct LintCommand: Command {
    let directoryPath: String

    func run() async throws {
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
            throw CommandError.invalidDirectory(directoryPath)
        }

        // Run validation
        let validator = MarkdownValidator()
        let result = try validator.validate(directory: url)

        // Print results
        if result.isValid {
            print("✓ All Markdown files have lines of 120 characters or less")
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

            print("""

            📝 Fix Instructions:
            All lines in Markdown files must be ≤120 characters. To fix these violations:

            1. Break long lines at natural boundaries (spaces, punctuation)
            2. Keep each line as close to 120 characters as possible without exceeding it
            3. Maintain readability and proper Markdown formatting
            4. For long URLs or code, consider using reference-style links

            Example fix for a 150-character line:
            Before: "This is an extremely long line that contains too many characters and needs to be broken up into
            multiple lines for better readability."
            After:  "This is an extremely long line that contains too many characters and needs to be broken up into
            multiple
            lines for better readability."

            Run 'standards lint .' again after fixing to verify all lines are within the limit.
            """)

            throw CommandError.lintFailed
        }
    }
}

enum CommandError: Error, LocalizedError {
    case invalidDirectory(String)
    case lintFailed
    case unknownCommand(String)
    case missingArgument(String)
    case setupFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidDirectory(let path):
            return "Invalid directory: \(path)"
        case .lintFailed:
            return "Lint check failed"
        case .unknownCommand(let command):
            return "Unknown command: \(command)"
        case .missingArgument(let arg):
            return "Missing argument: \(arg)"
        case .setupFailed(let reason):
            return "Setup failed: \(reason)"
        }
    }
}
