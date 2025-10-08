import Foundation

struct SetupCommand: Command {
    let apiClient: SagebrushAPIClientProtocol

    init(apiClient: SagebrushAPIClientProtocol = SagebrushAPIClient()) {
        self.apiClient = apiClient
    }

    func run() async throws {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let standardsURL = homeDirectory.appendingPathComponent("standards")

        // 1. Find or create ~/standards
        try createDirectoryIfNeeded(at: standardsURL)
        print("✓ ~/standards directory ready")

        // 2. Find or create ~/standards/CLAUDE.md
        try await setupCLAUDETemplate(in: standardsURL)

        // 3. Fetch projects from API
        print("Fetching projects from Sagebrush API...")
        let projects = try await apiClient.fetchProjects()
        print("✓ Found \(projects.count) projects")

        // 4. Create project directories
        for project in projects {
            let projectURL = standardsURL.appendingPathComponent(project.name)
            try createDirectoryIfNeeded(at: projectURL)
            print("✓ Created ~/standards/\(project.name)")
        }

        print("\n✓ Setup complete!")
    }

    private func createDirectoryIfNeeded(at url: URL) throws {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return // Directory already exists
            } else {
                throw CommandError.setupFailed("\(url.path) exists but is not a directory")
            }
        }

        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            throw CommandError.setupFailed("Failed to create directory \(url.path): \(error.localizedDescription)")
        }
    }

    private func setupCLAUDETemplate(in standardsURL: URL) async throws {
        let claudeURL = standardsURL.appendingPathComponent("CLAUDE.md")

        // Check if CLAUDE.md already exists
        if FileManager.default.fileExists(atPath: claudeURL.path) {
            print("✓ ~/standards/CLAUDE.md already exists")
            return
        }

        // Find source template
        let possiblePaths = [
            "/Users/nick/Code/NLF/Standards/CLAUDE.md",
        ]

        guard let foundPath = possiblePaths.first(where: { FileManager.default.fileExists(atPath: $0) }) else {
            throw CommandError.setupFailed("CLAUDE.md template not found. Looked in: \(possiblePaths.joined(separator: ", "))")
        }
        let templateURL = URL(fileURLWithPath: foundPath)

        // Copy template
        do {
            try FileManager.default.copyItem(at: templateURL, to: claudeURL)
            print("✓ Created ~/standards/CLAUDE.md")
        } catch {
            throw CommandError.setupFailed("Failed to copy CLAUDE.md: \(error.localizedDescription)")
        }
    }
}
