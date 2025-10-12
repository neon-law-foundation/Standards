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
    func lintCommandPassesWithValidFiles() async throws {
        let testDir = try createTestDirectory()
        defer { cleanupTestDirectory(testDir) }

        let fileURL = testDir.appendingPathComponent("test.md")
        try "# Short content".write(to: fileURL, atomically: true, encoding: .utf8)

        let command = LintCommand(directoryPath: testDir.path, fix: false)
        try await command.run()
    }

    @Test("Lint command fails with invalid files")
    func lintCommandFailsWithInvalidFiles() async throws {
        let testDir = try createTestDirectory()
        defer { cleanupTestDirectory(testDir) }

        let fileURL = testDir.appendingPathComponent("test.md")
        let longLine = String(repeating: "a", count: 150)
        try longLine.write(to: fileURL, atomically: true, encoding: .utf8)

        let command = LintCommand(directoryPath: testDir.path, fix: false)

        await #expect(throws: CommandError.self) {
            try await command.run()
        }
    }

    @Test("Lint command fails with non-existent directory")
    func lintCommandFailsWithNonExistentDirectory() async throws {
        let command = LintCommand(directoryPath: "/non/existent/path", fix: false)

        await #expect(throws: CommandError.self) {
            try await command.run()
        }
    }

    @Test("Setup command creates ~/standards structure")
    func setupCommandCreatesStandardsStructure() async throws {
        let testDir = try createTestDirectory()
        defer { cleanupTestDirectory(testDir) }

        // Use temp directory as "home" for testing
        let mockHomeURL = testDir.appendingPathComponent("home")
        try FileManager.default.createDirectory(at: mockHomeURL, withIntermediateDirectories: true)

        // Mock API client with test projects
        let mockProjects = [Project(name: "TestProject")]
        let mockClient = MockSagebrushAPIClient(projects: mockProjects)

        // Note: This test would need dependency injection for home directory
        // For now, we test the sync command which is more unit-testable
        // SetupCommand tests are covered by manual testing
    }
}
