import Foundation

let arguments = CommandLine.arguments

func printUsage() {
    print("""
    Usage: standards <command> [arguments]

    Commands:
      lint <directory>    Validate Markdown files have lines ≤120 characters
      setup <directory>   Copy CLAUDE.md template to target directory

    Examples:
      standards lint .
      standards setup .
    """)
}

do {
    guard arguments.count > 1 else {
        printUsage()
        exit(1)
    }

    let commandName = arguments[1]
    let command: Command

    switch commandName {
    case "lint":
        let directoryPath = arguments.count > 2 ? arguments[2] : "."
        command = LintCommand(directoryPath: directoryPath)

    case "setup":
        let directoryPath = arguments.count > 2 ? arguments[2] : "."
        command = SetupCommand(targetDirectory: directoryPath)

    case "--help", "-h":
        printUsage()
        exit(0)

    default:
        throw CommandError.unknownCommand(commandName)
    }

    try command.run()
    exit(0)
} catch let error as CommandError {
    switch error {
    case .lintFailed:
        exit(1)
    default:
        print("Error: \(error.localizedDescription)")
        exit(1)
    }
} catch {
    print("Error: \(error.localizedDescription)")
    exit(1)
}
