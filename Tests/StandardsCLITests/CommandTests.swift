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

    @Test("Setup command copies CLAUDE.md template")
    func setupCommandCopiesCLAUDEmd() throws {
        let testDir = try createTestDirectory()
        defer { cleanupTestDirectory(testDir) }

        let command = SetupCommand(targetDirectory: testDir.path)
        try command.run()

        let destinationURL = testDir.appendingPathComponent("CLAUDE.md")
        #expect(FileManager.default.fileExists(atPath: destinationURL.path))

        // Verify content was copied
        let copiedContent = try String(contentsOf: destinationURL, encoding: .utf8)
        #expect(copiedContent.contains("# Luxe Project"))
        #expect(copiedContent.contains("Swift Everywhere"))
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

        // Temporarily rename CLAUDE.md and ~/standards to test failure case
        let claudeMdURL = URL(fileURLWithPath: "/Users/nick/Code/NLF/Standards/CLAUDE.md")
        let tempClaudeMdURL = URL(fileURLWithPath: "/Users/nick/Code/NLF/Standards/CLAUDE.md.tmp-\(UUID().uuidString)")

        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let standardsURL = homeDirectory.appendingPathComponent("standards")
        let tempStandardsURL = homeDirectory.appendingPathComponent("standards-temp-\(UUID().uuidString)")

        let claudeMdExists = FileManager.default.fileExists(atPath: claudeMdURL.path)
        let standardsExists = FileManager.default.fileExists(atPath: standardsURL.path)

        if claudeMdExists {
            try FileManager.default.moveItem(at: claudeMdURL, to: tempClaudeMdURL)
        }
        if standardsExists {
            try FileManager.default.moveItem(at: standardsURL, to: tempStandardsURL)
        }
        defer {
            if claudeMdExists {
                try? FileManager.default.moveItem(at: tempClaudeMdURL, to: claudeMdURL)
            }
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
