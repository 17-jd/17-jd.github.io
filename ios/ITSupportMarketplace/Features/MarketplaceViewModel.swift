import Foundation
import MarketplaceCore

#if canImport(SwiftUI)
import SwiftUI
#endif

enum AppRole: CaseIterable {
    case customer
    case engineer

    var title: String {
        switch self {
        case .customer:
            return "Customer"
        case .engineer:
            return "Engineer"
        }
    }
}

@MainActor
final class MarketplaceViewModel: ObservableObject {
    @Published var activeRole: AppRole = .customer
    @Published var showingError = false
    @Published var errorMessage = ""

    // Customer inputs
    @Published var customerName: String = "Acme Team"
    @Published var issueSummary: String = ""
    @Published var selectedCategory: SupportCategory = .software
    @Published var selectedLocation: SupportLocation = MarketplaceSampleData.supportLocations().first!

    // Engineer state
    @Published var engineers: [Engineer] = []
    @Published var selectedEngineerID: UUID?

    // Lists
    @Published var openRequests: [SupportRequest] = []
    @Published var customerRequests: [SupportRequest] = []
    @Published var engineerRequests: [SupportRequest] = []
    @Published var recommendedEngineers: [Engineer] = []

    private let service: MarketplaceService
    private var didBootstrap = false

    init(
        service: MarketplaceService = MarketplaceService(
            repository: InMemorySupportRequestRepository(),
            seedEngineers: MarketplaceSampleData.engineers()
        )
    ) {
        self.service = service
    }

    func bootstrapIfNeeded() async {
        guard !didBootstrap else { return }
        didBootstrap = true
        await refreshAllData()
    }

    func refresh() async {
        await refreshAllData()
    }

    func submitRequest() async {
        let draft = SupportRequestDraft(
            customerName: customerName,
            summary: issueSummary,
            category: selectedCategory,
            location: selectedLocation
        )
        recommendedEngineers = await service.recommendedEngineers(for: draft)
        do {
            _ = try await service.createRequest(draft)
            issueSummary = ""
            await refreshAllData()
        } catch {
            present(error)
        }
    }

    func cancelRequest(_ requestID: UUID) async {
        do {
            _ = try await service.cancel(requestID: requestID, by: customerName)
            await refreshAllData()
        } catch {
            present(error)
        }
    }

    func accept(_ requestID: UUID) async {
        guard let engineerID = selectedEngineerID else { return }
        do {
            _ = try await service.accept(requestID: requestID, engineerID: engineerID)
            await refreshAllData()
        } catch {
            present(error)
        }
    }

    func start(_ requestID: UUID) async {
        guard let engineerID = selectedEngineerID else { return }
        do {
            _ = try await service.startWork(requestID: requestID, engineerID: engineerID)
            await refreshAllData()
        } catch {
            present(error)
        }
    }

    func complete(_ requestID: UUID) async {
        guard let engineerID = selectedEngineerID else { return }
        do {
            _ = try await service.complete(requestID: requestID, engineerID: engineerID)
            await refreshAllData()
        } catch {
            present(error)
        }
    }

    func statusText(for request: SupportRequest) -> String {
        switch request.status {
        case .open:
            return "Open"
        case .accepted:
            return "Accepted"
        case .inProgress:
            return "In Progress"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }

    var availableLocations: [SupportLocation] {
        MarketplaceSampleData.supportLocations()
    }

    private func refreshAllData() async {
        do {
            engineers = await service.listEngineers()
            if selectedEngineerID == nil {
                selectedEngineerID = engineers.first?.id
            }

            openRequests = try await service.openRequests()
            customerRequests = try await service.requests(for: customerName)

            if let engineerID = selectedEngineerID {
                engineerRequests = try await service.requests(for: engineerID)
            } else {
                engineerRequests = []
            }
        } catch {
            present(error)
        }
    }

    private func present(_ error: Error) {
        errorMessage = error.localizedDescription
        showingError = true
    }
}
