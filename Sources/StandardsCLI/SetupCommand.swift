import Foundation

struct SetupCommand: Command {
    let targetDirectory: String

    func run() throws {
        // Resolve target directory
        let targetURL: URL
        if targetDirectory == "." {
            targetURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        } else {
            targetURL = URL(fileURLWithPath: targetDirectory)
        }

        // Validate target directory exists
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: targetURL.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            throw CommandError.invalidDirectory(targetDirectory)
        }

        // Find CLAUDE.md template in ~/standards
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let templateURL = homeDirectory.appendingPathComponent("standards/CLAUDE.md")

        guard FileManager.default.fileExists(atPath: templateURL.path) else {
            throw CommandError.setupFailed("Template file not found at ~/standards/CLAUDE.md")
        }

        // Destination path
        let destinationURL = targetURL.appendingPathComponent("CLAUDE.md")

        // Check if CLAUDE.md already exists
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            print("⚠️  CLAUDE.md already exists at \(destinationURL.path)")
            print("Do you want to overwrite it? (y/N): ", terminator: "")
            guard let response = readLine()?.lowercased(), response == "y" else {
                print("Setup cancelled")
                return
            }
        }

        // Copy template to target directory
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: templateURL, to: destinationURL)
            print("✓ CLAUDE.md copied to \(targetURL.path)")
        } catch {
            throw CommandError.setupFailed("Failed to copy CLAUDE.md: \(error.localizedDescription)")
        }
    }
}
