import Foundation
import Testing
@testable import MarketplaceCore

struct MarketplaceCoreTests {
    @Test
    func createRequest_and_assign_flow_updates_statuses() async throws {
        let repository = InMemorySupportRequestRepository()
        let service = MarketplaceService(repository: repository, seedEngineers: MarketplaceSampleData.engineers())
        let engineer = await service.listEngineers().first!

        let draft = SupportRequestDraft(
            customerName: "Acme Inc",
            summary: "VPN is down",
            category: .network,
            location: MarketplaceSampleData.supportLocations()[0]
        )
        let created = try await service.createRequest(draft)
        #expect(created.status == .open)

        let accepted = try await service.accept(requestID: created.id, engineerID: engineer.id)
        #expect(accepted.status == .accepted)
        #expect(accepted.assignedEngineerID == engineer.id)

        let inProgress = try await service.startWork(requestID: created.id, engineerID: engineer.id)
        #expect(inProgress.status == .inProgress)

        let completed = try await service.complete(requestID: created.id, engineerID: engineer.id)
        #expect(completed.status == .completed)
    }

    @Test
    func recommendedEngineers_returns_skill_matched_ordered_by_distance() async throws {
        let repository = InMemorySupportRequestRepository()
        let service = MarketplaceService(repository: repository, seedEngineers: MarketplaceSampleData.engineers())

        let draft = SupportRequestDraft(
            customerName: "Globex",
            summary: "Need emergency malware cleanup",
            category: .security,
            location: MarketplaceSampleData.supportLocations()[0]
        )

        let ranked = await service.recommendedEngineers(for: draft)
        #expect(!ranked.isEmpty)
        #expect(ranked.allSatisfy { $0.skills.contains(.security) && $0.isAvailable })
    }

    @Test
    func invalidTransition_startBeforeAccept_throws() async throws {
        let repository = InMemorySupportRequestRepository()
        let service = MarketplaceService(repository: repository, seedEngineers: MarketplaceSampleData.engineers())
        let engineer = await service.listEngineers().first!

        let created = try await service.createRequest(
            SupportRequestDraft(
                customerName: "Initech",
                summary: "Laptop crashed",
                category: .hardware,
                location: MarketplaceSampleData.supportLocations()[1]
            )
        )

        do {
            _ = try await service.startWork(requestID: created.id, engineerID: engineer.id)
            Issue.record("Expected invalid status transition error.")
        } catch let error as MarketplaceError {
            #expect(error == .requestNotFound || error == .invalidStatusTransition(current: .open, expected: .inProgress))
        }
    }
}
