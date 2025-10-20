import Foundation

struct SetupCommand: Command {
  let apiClient: SagebrushAPIClientProtocol
  let homeDirectory: URL
  let templateDirectory: URL

  init(
    apiClient: SagebrushAPIClientProtocol = SagebrushAPIClient(),
    homeDirectory: URL? = nil,
    templateDirectory: URL? = nil
  ) {
    self.apiClient = apiClient
    self.homeDirectory = homeDirectory ?? FileManager.default.homeDirectoryForCurrentUser
    self.templateDirectory =
      templateDirectory ?? URL(fileURLWithPath: "/Users/nick/Code/NLF/Standards/ClaudeTemplates")
  }

  func run() async throws {
    let standardsURL = homeDirectory.appendingPathComponent("Standards")

    // 1. Find or create ~/Standards
    try createDirectoryIfNeeded(at: standardsURL)
    print("✓ ~/Standards directory ready")

    // 2. Find or create ~/Standards/CLAUDE.md
    try await setupCLAUDETemplate(in: standardsURL)

    // 3. Set up Claude agents
    try await setupClaudeAgents(in: standardsURL)

    // 4. Set up Claude commands
    try await setupClaudeCommands(in: standardsURL)

    // 5. Set up Claude skills
    try await setupClaudeSkills(in: standardsURL)

    // 6. Fetch projects from API
    print("Fetching projects from Sagebrush API...")
    let projects = try await apiClient.fetchProjects()
    print("✓ Found \(projects.count) projects")

    // 7. Create project directories
    for project in projects {
      let projectURL = standardsURL.appendingPathComponent(project.name)
      try createDirectoryIfNeeded(at: projectURL)
      print("✓ Created ~/Standards/\(project.name)")
    }

    print("\n✓ Setup complete!")
  }

  private func createDirectoryIfNeeded(at url: URL) throws {
    var isDirectory: ObjCBool = false
    if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
      if isDirectory.boolValue {
        return  // Directory already exists
      } else {
        throw CommandError.setupFailed("\(url.path) exists but is not a directory")
      }
    }

    do {
      try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    } catch {
      throw CommandError.setupFailed(
        "Failed to create directory \(url.path): \(error.localizedDescription)")
    }
  }

  private func setupCLAUDETemplate(in standardsURL: URL) async throws {
    let claudeURL = standardsURL.appendingPathComponent("CLAUDE.md")

    // Check if CLAUDE.md already exists
    if FileManager.default.fileExists(atPath: claudeURL.path) {
      print("✓ ~/Standards/CLAUDE.md already exists")
      return
    }

    // Find source template
    let templateURL = templateDirectory.appendingPathComponent("CLAUDE.md")

    guard FileManager.default.fileExists(atPath: templateURL.path) else {
      throw CommandError.setupFailed("CLAUDE.md template not found at: \(templateURL.path)")
    }

    // Copy template
    do {
      try FileManager.default.copyItem(at: templateURL, to: claudeURL)
      print("✓ Created ~/Standards/CLAUDE.md")
    } catch {
      throw CommandError.setupFailed("Failed to copy CLAUDE.md: \(error.localizedDescription)")
    }
  }

  private func setupClaudeAgents(in standardsURL: URL) async throws {
    // Create ~/Standards/.claude/agents directory
    let claudeAgentsURL =
      standardsURL
      .appendingPathComponent(".claude")
      .appendingPathComponent("agents")
    try createDirectoryIfNeeded(at: claudeAgentsURL)

    // List of agents to copy
    let agents = [
      "markdown-formatter.md", "legal-writer.md", "law-school-professor.md", "commiter.md",
    ]

    for agentFile in agents {
      let destURL = claudeAgentsURL.appendingPathComponent(agentFile)

      // Check if agent already exists
      if FileManager.default.fileExists(atPath: destURL.path) {
        print("✓ ~/Standards/.claude/agents/\(agentFile) already exists")
        continue
      }

      // Find source agent
      let sourceURL =
        templateDirectory
        .appendingPathComponent("agents")
        .appendingPathComponent(agentFile)

      guard FileManager.default.fileExists(atPath: sourceURL.path) else {
        print("⚠️  \(agentFile) not found at: \(sourceURL.path), skipping")
        continue
      }

      // Copy agent
      do {
        try FileManager.default.copyItem(at: sourceURL, to: destURL)
        print("✓ Created ~/Standards/.claude/agents/\(agentFile)")
      } catch {
        print("⚠️  Failed to copy \(agentFile): \(error.localizedDescription)")
      }
    }
  }

  private func setupClaudeCommands(in standardsURL: URL) async throws {
    // Create ~/Standards/.claude/commands directory
    let claudeCommandsURL =
      standardsURL
      .appendingPathComponent(".claude")
      .appendingPathComponent("commands")
    try createDirectoryIfNeeded(at: claudeCommandsURL)

    // Set up format-markdown command
    let formatMarkdownDestURL = claudeCommandsURL.appendingPathComponent("format-markdown.md")

    // Check if command already exists
    if FileManager.default.fileExists(atPath: formatMarkdownDestURL.path) {
      print("✓ ~/Standards/.claude/commands/format-markdown.md already exists")
    } else {
      // Find source command
      let commandTemplateURL =
        templateDirectory
        .appendingPathComponent("commands")
        .appendingPathComponent("format-markdown.md")

      guard FileManager.default.fileExists(atPath: commandTemplateURL.path) else {
        throw CommandError.setupFailed(
          "format-markdown.md command not found at: \(commandTemplateURL.path)")
      }

      // Copy command
      do {
        try FileManager.default.copyItem(at: commandTemplateURL, to: formatMarkdownDestURL)
        print("✓ Created ~/Standards/.claude/commands/format-markdown.md")
      } catch {
        throw CommandError.setupFailed(
          "Failed to copy format-markdown.md: \(error.localizedDescription)")
      }
    }
  }

  private func setupClaudeSkills(in standardsURL: URL) async throws {
    // Create ~/Standards/.claude/skills directory
    let claudeSkillsURL =
      standardsURL
      .appendingPathComponent(".claude")
      .appendingPathComponent("skills")
    try createDirectoryIfNeeded(at: claudeSkillsURL)

    // List of skills to copy (directories)
    let skills = ["sagebrush-standard"]

    for skillName in skills {
      let skillDestDir = claudeSkillsURL.appendingPathComponent(skillName)
      let skillSourceDir =
        templateDirectory
        .appendingPathComponent("skills")
        .appendingPathComponent(skillName)

      // Check if skill source directory exists
      var isDirectory: ObjCBool = false
      guard FileManager.default.fileExists(atPath: skillSourceDir.path, isDirectory: &isDirectory),
        isDirectory.boolValue
      else {
        print("⚠️  Skill directory not found: \(skillSourceDir.path), skipping")
        continue
      }

      // Check if skill already exists
      if FileManager.default.fileExists(atPath: skillDestDir.path) {
        print("✓ ~/Standards/.claude/skills/\(skillName) already exists")
        continue
      }

      // Copy skill directory
      do {
        try FileManager.default.copyItem(at: skillSourceDir, to: skillDestDir)
        print("✓ Created ~/Standards/.claude/skills/\(skillName)")
      } catch {
        print("⚠️  Failed to copy skill \(skillName): \(error.localizedDescription)")
      }
    }
  }
}
