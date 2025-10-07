import Fluent
import Foundation
import StandardsDAL
import Testing
import Vapor

@Suite("Comprehensive Model Tests - Create All Records Together")
struct ComprehensiveModelTests {

    @Test("Create all models in a single transaction")
    func testCreateAllRecordsTogether() async throws {
        try await TestUtilities.withApp { app, db in
            // 1. Create a Person
            let person = TestUtilities.createTestPerson(name: "John Doe", email: "john@example.com")
            try await person.save(on: db)
            let personID = try person.requireID()
            #expect(personID > 0, "Person should be created with valid ID")

            // 2. Create a Jurisdiction
            let jurisdiction = TestUtilities.createTestJurisdiction(
                name: "California",
                code: "CA",
                type: .state
            )
            try await jurisdiction.save(on: db)
            let jurisdictionID = try jurisdiction.requireID()
            #expect(jurisdictionID > 0, "Jurisdiction should be created with valid ID")

            // 3. Create an EntityType
            let entityType = TestUtilities.createTestEntityType(
                jurisdictionID: jurisdictionID,
                name: "C Corporation"
            )
            try await entityType.save(on: db)
            let entityTypeID = try entityType.requireID()
            #expect(entityTypeID > 0, "EntityType should be created with valid ID")

            // 4. Create an Entity
            let entity = TestUtilities.createTestEntity(
                name: "Acme Corp",
                legalEntityTypeID: entityTypeID
            )
            try await entity.save(on: db)
            let entityID = try entity.requireID()
            #expect(entityID > 0, "Entity should be created with valid ID")

            // 5. Create a User
            let user = User()
            user.$person.id = personID
            user.sub = "auth0|123456"
            user.role = .customer
            try await user.save(on: db)
            let userID = try user.requireID()
            #expect(userID > 0, "User should be created with valid ID")

            // 6. Create a ShareClass
            let shareClass = ShareClass()
            shareClass.$entity.id = entityID
            shareClass.name = "Class A Common"
            shareClass.priority = 1
            shareClass.description = "Voting common stock"
            try await shareClass.save(on: db)
            let shareClassID = try shareClass.requireID()
            #expect(shareClassID > 0, "ShareClass should be created with valid ID")

            // 7. Create a Credential
            let credential = TestUtilities.createTestCredential(
                personID: personID,
                jurisdictionID: jurisdictionID,
                licenseNumber: "CA12345"
            )
            try await credential.save(on: db)
            let credentialID = try credential.requireID()
            #expect(credentialID > 0, "Credential should be created with valid ID")

            // 8. Create a Project
            let project = TestUtilities.createTestProject(codename: "ProjectAlpha")
            try await project.save(on: db)
            let projectID = try project.requireID()
            #expect(projectID > 0, "Project should be created with valid ID")

            // 9. Create a Disclosure
            let disclosure = Disclosure()
            disclosure.$credential.id = credentialID
            disclosure.$project.id = projectID
            disclosure.disclosedAt = Date()
            disclosure.active = true
            try await disclosure.save(on: db)
            let disclosureID = try disclosure.requireID()
            #expect(disclosureID > 0, "Disclosure should be created with valid ID")

            // 10. Create a RelationshipLog
            let relationshipLog = RelationshipLog(
                projectID: projectID,
                credentialID: credentialID,
                body: "Attorney-client relationship established",
                relationships: ["type": "attorney-client"]
            )
            try await relationshipLog.save(on: db)
            let relationshipLogID = try relationshipLog.requireID()
            #expect(relationshipLogID > 0, "RelationshipLog should be created with valid ID")

            // 11. Create an Address for the Person
            let personAddress = TestUtilities.createTestAddressForPerson(
                personID: personID,
                street: "123 Main St",
                city: "San Francisco",
                state: "CA",
                zip: "94102",
                country: "USA"
            )
            try await personAddress.save(on: db)
            let personAddressID = try personAddress.requireID()
            #expect(personAddressID > 0, "Person Address should be created with valid ID")

            // 12. Create an Address for the Entity
            let entityAddress = TestUtilities.createTestAddressForEntity(
                entityID: entityID,
                street: "456 Corporate Blvd",
                city: "Palo Alto",
                state: "CA",
                zip: "94301",
                country: "USA"
            )
            try await entityAddress.save(on: db)
            let entityAddressID = try entityAddress.requireID()
            #expect(entityAddressID > 0, "Entity Address should be created with valid ID")

            // 13. Create a Mailbox
            let mailbox = Mailbox()
            mailbox.$address.id = personAddressID
            mailbox.mailboxNumber = 42
            mailbox.isActive = true
            try await mailbox.save(on: db)
            let mailboxID = try mailbox.requireID()
            #expect(mailboxID > 0, "Mailbox should be created with valid ID")

            // 14. Create a PersonEntityRole
            let personEntityRole = PersonEntityRole()
            personEntityRole.$person.id = personID
            personEntityRole.$entity.id = entityID
            personEntityRole.role = .admin
            try await personEntityRole.save(on: db)
            let personEntityRoleID = try personEntityRole.requireID()
            #expect(personEntityRoleID > 0, "PersonEntityRole should be created with valid ID")

            // 15. Create a Question
            let question = Question(
                prompt: "What is your company name?",
                questionType: .string,
                code: "COMPANY_NAME",
                helpText: "Enter the legal name of your company"
            )
            try await question.save(on: db)
            let questionID = try question.requireID()
            #expect(questionID > 0, "Question should be created with valid ID")

            // 16. Create a Blob
            let blob = Blob()
            blob.objectStorageUrl = "s3://bucket/path/to/file.pdf"
            blob.referencedBy = .answers
            blob.referencedById = 1
            try await blob.save(on: db)
            let blobID = try blob.requireID()
            #expect(blobID > 0, "Blob should be created with valid ID")

            // Verify all records exist
            let fetchedPerson = try await Person.find(personID, on: db)
            #expect(fetchedPerson != nil, "Person should be retrievable")
            #expect(fetchedPerson?.email == "john@example.com", "Person email should match")

            let fetchedJurisdiction = try await Jurisdiction.find(jurisdictionID, on: db)
            #expect(fetchedJurisdiction != nil, "Jurisdiction should be retrievable")
            #expect(fetchedJurisdiction?.code == "CA", "Jurisdiction code should match")

            let fetchedEntity = try await Entity.find(entityID, on: db)
            #expect(fetchedEntity != nil, "Entity should be retrievable")
            #expect(fetchedEntity?.name == "Acme Corp", "Entity name should match")

            let fetchedUser = try await User.find(userID, on: db)
            #expect(fetchedUser != nil, "User should be retrievable")
            #expect(fetchedUser?.role == .customer, "User role should match")

            let fetchedShareClass = try await ShareClass.find(shareClassID, on: db)
            #expect(fetchedShareClass != nil, "ShareClass should be retrievable")
            #expect(fetchedShareClass?.priority == 1, "ShareClass priority should match")

            let fetchedCredential = try await Credential.find(credentialID, on: db)
            #expect(fetchedCredential != nil, "Credential should be retrievable")
            #expect(fetchedCredential?.licenseNumber == "CA12345", "Credential license should match")

            let fetchedProject = try await Project.find(projectID, on: db)
            #expect(fetchedProject != nil, "Project should be retrievable")
            #expect(fetchedProject?.codename == "ProjectAlpha", "Project codename should match")

            let fetchedDisclosure = try await Disclosure.find(disclosureID, on: db)
            #expect(fetchedDisclosure != nil, "Disclosure should be retrievable")
            #expect(fetchedDisclosure?.active == true, "Disclosure should be active")

            let fetchedRelationshipLog = try await RelationshipLog.find(relationshipLogID, on: db)
            #expect(fetchedRelationshipLog != nil, "RelationshipLog should be retrievable")

            let fetchedPersonAddress = try await Address.find(personAddressID, on: db)
            #expect(fetchedPersonAddress != nil, "Person Address should be retrievable")
            #expect(fetchedPersonAddress?.city == "San Francisco", "Address city should match")

            let fetchedEntityAddress = try await Address.find(entityAddressID, on: db)
            #expect(fetchedEntityAddress != nil, "Entity Address should be retrievable")

            let fetchedMailbox = try await Mailbox.find(mailboxID, on: db)
            #expect(fetchedMailbox != nil, "Mailbox should be retrievable")
            #expect(fetchedMailbox?.mailboxNumber == 42, "Mailbox number should match")

            let fetchedPersonEntityRole = try await PersonEntityRole.find(personEntityRoleID, on: db)
            #expect(fetchedPersonEntityRole != nil, "PersonEntityRole should be retrievable")

            let fetchedQuestion = try await Question.find(questionID, on: db)
            #expect(fetchedQuestion != nil, "Question should be retrievable")
            #expect(fetchedQuestion?.code == "COMPANY_NAME", "Question code should match")

            let fetchedBlob = try await Blob.find(blobID, on: db)
            #expect(fetchedBlob != nil, "Blob should be retrievable")
        }
    }
}
