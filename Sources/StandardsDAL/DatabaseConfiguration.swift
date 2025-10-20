import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import Foundation
import Logging
import Vapor

/// Configuration utility for setting up the database with all migrations
public struct StandardsDALConfiguration {

  /// Configure the database and run all migrations
  /// Uses ENV environment variable to determine database:
  /// - ENV=production: PostgreSQL
  /// - Otherwise: SQLite (in-memory for testing, file-based for development)
  public static func configure(_ app: Application) async throws {
    let env = Environment.get("ENV")?.lowercased() ?? "development"
    let isProduction = env == "production"

    // Configure database driver based on environment
    if isProduction {
      // Production: Use PostgreSQL
      let hostname = Environment.get("DATABASE_HOST") ?? "localhost"
      let port = Environment.get("DATABASE_PORT").flatMap(Int.init) ?? 5432
      let username = Environment.get("DATABASE_USERNAME") ?? "postgres"
      let password = Environment.get("DATABASE_PASSWORD") ?? ""
      let database = Environment.get("DATABASE_NAME") ?? "standards"

      // Use new SQLPostgresConfiguration API
      let config = SQLPostgresConfiguration(
        hostname: hostname,
        port: port,
        username: username,
        password: password,
        database: database,
        tls: .disable
      )

      app.databases.use(
        DatabaseConfigurationFactory.postgres(configuration: config),
        as: .psql
      )

      app.logger.info("Database configured: PostgreSQL at \(hostname):\(port)/\(database)")
    } else {
      // Development/Testing: Use SQLite
      // Use in-memory for testing environment, file-based for development
      let isTestEnvironment = env == "testing" || app.environment == .testing

      if isTestEnvironment {
        app.databases.use(DatabaseConfigurationFactory.sqlite(.memory), as: .sqlite)
        app.logger.info("Database configured: SQLite (in-memory)")
      } else {
        let dbPath = Environment.get("DATABASE_PATH") ?? "db/standards.sqlite"
        app.databases.use(DatabaseConfigurationFactory.sqlite(.file(dbPath)), as: .sqlite)
        app.logger.info("Database configured: SQLite at \(dbPath)")
      }
    }

    // Add all migrations in order
    app.migrations.add(CreatePeople())
    app.migrations.add(CreateUsers())
    app.migrations.add(CreateJurisdictions())
    app.migrations.add(CreateEntityTypes())
    app.migrations.add(CreateEntities())
    app.migrations.add(CreateShareClasses())
    app.migrations.add(CreateBlobs())
    app.migrations.add(CreateProjects())
    app.migrations.add(CreateCredentials())
    app.migrations.add(CreateRelationshipLogs())
    app.migrations.add(CreateDisclosures())
    app.migrations.add(CreateQuestions())
    app.migrations.add(CreateAddresses())
    app.migrations.add(CreateMailboxes())
    app.migrations.add(CreatePersonEntityRoles())

    // Run migrations
    try await app.autoMigrate()
    app.logger.info("Database migrations completed")
  }

  /// Configure database for testing with SQLite (in-memory)
  /// Sets ENV=testing to force in-memory SQLite
  public static func configureForTesting(_ app: Application) async throws {
    // Ensure testing environment
    setenv("ENV", "testing", 1)
    try await configure(app)
  }

  /// Configure database for production with PostgreSQL
  /// Sets ENV=production to force PostgreSQL
  public static func configureForProduction(_ app: Application) async throws {
    // Ensure production environment
    setenv("ENV", "production", 1)
    try await configure(app)
  }
}
