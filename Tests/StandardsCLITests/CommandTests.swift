import Foundation
import Testing
@testable import StandardsCLI

@Suite("Command Tests")
struct CommandTests {
    func createTestDirectory() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("CommandTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        return tempDir
    }

    func cleanupTestDirectory(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

    @Test("Lint command passes with valid files")
    func lintCommandPassesWithValidFiles() throws {
        let testDir = try createTestDirectory()
        defer { cleanupTestDirectory(testDir) }

        let fileURL = testDir.appendingPathComponent("test.md")
        try "# Short content".write(to: fileURL, atomically: true, encoding: .utf8)

        let command = LintCommand(directoryPath: testDir.path)
        try command.run()
    }

    @Test("Lint command fails with invalid files")
    func lintCommandFailsWithInvalidFiles() throws {
        let testDir = try createTestDirectory()
        defer { cleanupTestDirectory(testDir) }

        let fileURL = testDir.appendingPathComponent("test.md")
        let longLine = String(repeating: "a", count: 150)
        try longLine.write(to: fileURL, atomically: true, encoding: .utf8)

        let command = LintCommand(directoryPath: testDir.path)

        #expect(throws: CommandError.self) {
            try command.run()
        }
    }

    @Test("Lint command fails with non-existent directory")
    func lintCommandFailsWithNonExistentDirectory() throws {
        let command = LintCommand(directoryPath: "/non/existent/path")

        #expect(throws: CommandError.self) {
            try command.run()
        }
    }

    @Test("Setup command copies CLAUDE.md from ~/standards")
    func setupCommandCopiesCLAUDEmd() throws {
        let testDir = try createTestDirectory()
        defer { cleanupTestDirectory(testDir) }

        // Check if ~/standards/CLAUDE.md exists
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let templateURL = homeDirectory.appendingPathComponent("standards/CLAUDE.md")

        guard FileManager.default.fileExists(atPath: templateURL.path) else {
            // Skip test if template doesn't exist
            return
        }

        let command = SetupCommand(targetDirectory: testDir.path)
        try command.run()

        let destinationURL = testDir.appendingPathComponent("CLAUDE.md")
        #expect(FileManager.default.fileExists(atPath: destinationURL.path))

        // Verify content was copied
        let originalContent = try String(contentsOf: templateURL, encoding: .utf8)
        let copiedContent = try String(contentsOf: destinationURL, encoding: .utf8)
        #expect(originalContent == copiedContent)
    }

    @Test("Setup command fails with non-existent directory")
    func setupCommandFailsWithNonExistentDirectory() throws {
        let command = SetupCommand(targetDirectory: "/non/existent/path")

        #expect(throws: CommandError.self) {
            try command.run()
        }
    }

    @Test("Setup command fails when template not found")
    func setupCommandFailsWhenTemplateNotFound() throws {
        let testDir = try createTestDirectory()
        defer { cleanupTestDirectory(testDir) }

        // Temporarily rename ~/standards if it exists to test failure case
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let standardsURL = homeDirectory.appendingPathComponent("standards")
        let tempStandardsURL = homeDirectory.appendingPathComponent("standards-temp-\(UUID().uuidString)")

        let standardsExists = FileManager.default.fileExists(atPath: standardsURL.path)
        if standardsExists {
            try FileManager.default.moveItem(at: standardsURL, to: tempStandardsURL)
        }
        defer {
            if standardsExists {
                try? FileManager.default.moveItem(at: tempStandardsURL, to: standardsURL)
            }
        }

        let command = SetupCommand(targetDirectory: testDir.path)

        #expect(throws: CommandError.self) {
            try command.run()
        }
    }
}
