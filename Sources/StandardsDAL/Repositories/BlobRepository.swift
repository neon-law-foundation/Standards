import Fluent
import Foundation
import Vapor

public struct BlobRepository: Sendable {

    private let database: Database

    public init(database: Database) {
        self.database = database
    }

    public func find(id: Int32) async throws -> Blob? {
        try await Blob.find(id, on: database)
    }

    public func findAll() async throws -> [Blob] {
        try await Blob.query(on: database).all()
    }

    public func findByReference(referencedBy: BlobReferencedBy, referencedById: Int32) async throws -> [Blob] {
        try await Blob.query(on: database)
            .filter(\.$referencedBy == referencedBy)
            .filter(\.$referencedById == referencedById)
            .all()
    }

    public func create(model: Blob) async throws -> Blob {
        try await model.save(on: database)
        return model
    }

    public func update(model: Blob) async throws -> Blob {
        try await model.save(on: database)
        return model
    }

    public func delete(id: Int32) async throws {
        guard let blob = try await find(id: id) else {
            throw RepositoryError.notFound
        }
        try await blob.delete(on: database)
    }
}
