import Foundation

public protocol MatchingEngine: Sendable {
    func rankEngineers(for draft: SupportRequestDraft, engineers: [Engineer]) -> [Engineer]
}

public struct DistanceBasedMatchingEngine: MatchingEngine {
    public init() {}

    public func rankEngineers(for draft: SupportRequestDraft, engineers: [Engineer]) -> [Engineer] {
        engineers
            .filter { $0.isAvailable && $0.skills.contains(draft.category) }
            .sorted {
                let lhsDistance = distanceKm(from: $0.currentLocation, to: draft.location.point)
                let rhsDistance = distanceKm(from: $1.currentLocation, to: draft.location.point)
                return lhsDistance < rhsDistance
            }
    }

    private func distanceKm(from start: GeoPoint, to end: GeoPoint) -> Double {
        let latDistance = start.latitude - end.latitude
        let lonDistance = start.longitude - end.longitude
        let euclidean = (latDistance * latDistance + lonDistance * lonDistance).squareRoot()
        return euclidean * 111.0
    }
}

public actor MarketplaceService {
    private let repository: SupportRequestRepository
    private let matchingEngine: MatchingEngine
    private var engineersByID: [UUID: Engineer]

    public init(
        repository: SupportRequestRepository,
        matchingEngine: MatchingEngine = DistanceBasedMatchingEngine(),
        seedEngineers: [Engineer] = []
    ) {
        self.repository = repository
        self.matchingEngine = matchingEngine
        self.engineersByID = Dictionary(uniqueKeysWithValues: seedEngineers.map { ($0.id, $0) })
    }

    public func upsertEngineers(_ engineers: [Engineer]) {
        for engineer in engineers {
            engineersByID[engineer.id] = engineer
        }
    }

    public func listEngineers() -> [Engineer] {
        engineersByID.values.sorted { $0.name < $1.name }
    }

    public func createRequest(_ draft: SupportRequestDraft) async throws -> SupportRequest {
        let customer = draft.customerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let summary = draft.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !customer.isEmpty else {
            throw MarketplaceError.invalidInput("Customer name is required.")
        }
        guard !summary.isEmpty else {
            throw MarketplaceError.invalidInput("Issue summary is required.")
        }

        let request = SupportRequest(
            customerName: customer,
            summary: summary,
            category: draft.category,
            location: draft.location
        )
        try await repository.insert(request)
        return request
    }

    public func openRequests() async throws -> [SupportRequest] {
        try await repository.list().filter { $0.status == .open }
    }

    public func requests(for customerName: String) async throws -> [SupportRequest] {
        try await repository.list().filter { $0.customerName.caseInsensitiveCompare(customerName) == .orderedSame }
    }

    public func requests(for engineerID: UUID) async throws -> [SupportRequest] {
        try await repository.list().filter { $0.assignedEngineerID == engineerID }
    }

    public func recommendedEngineers(for draft: SupportRequestDraft) -> [Engineer] {
        matchingEngine.rankEngineers(for: draft, engineers: Array(engineersByID.values))
    }

    public func accept(requestID: UUID, engineerID: UUID) async throws -> SupportRequest {
        guard var request = try await repository.get(id: requestID) else {
            throw MarketplaceError.requestNotFound
        }
        guard var engineer = engineersByID[engineerID] else {
            throw MarketplaceError.engineerNotFound
        }
        guard request.status == .open else {
            throw MarketplaceError.invalidStatusTransition(current: request.status, expected: .accepted)
        }
        guard request.assignedEngineerID == nil else {
            throw MarketplaceError.requestAlreadyAssigned
        }
        guard engineer.isAvailable else {
            throw MarketplaceError.engineerUnavailable
        }

        request.status = .accepted
        request.assignedEngineerID = engineer.id
        engineer.isAvailable = false
        engineersByID[engineerID] = engineer
        try await repository.update(request)
        return request
    }

    public func startWork(requestID: UUID, engineerID: UUID) async throws -> SupportRequest {
        guard var request = try await repository.get(id: requestID) else {
            throw MarketplaceError.requestNotFound
        }
        guard request.assignedEngineerID == engineerID else {
            throw MarketplaceError.requestNotFound
        }
        guard request.status == .accepted else {
            throw MarketplaceError.invalidStatusTransition(current: request.status, expected: .inProgress)
        }
        request.status = .inProgress
        try await repository.update(request)
        return request
    }

    public func complete(requestID: UUID, engineerID: UUID) async throws -> SupportRequest {
        guard var request = try await repository.get(id: requestID) else {
            throw MarketplaceError.requestNotFound
        }
        guard request.assignedEngineerID == engineerID else {
            throw MarketplaceError.requestNotFound
        }
        guard request.status == .inProgress else {
            throw MarketplaceError.invalidStatusTransition(current: request.status, expected: .completed)
        }
        request.status = .completed
        try await repository.update(request)

        guard var engineer = engineersByID[engineID] else {
            throw MarketplaceError.engineerNotFound
        }
        engineer.isAvailable = true
        engineersByID[engineID] = engineer
        return request
    }

    public func cancel(requestID: UUID, by customerName: String) async throws -> SupportRequest {
        guard var request = try await repository.get(id: requestID) else {
            throw MarketplaceError.requestNotFound
        }
        guard request.customerName.caseInsensitiveCompare(customerName) == .orderedSame else {
            throw MarketplaceError.requestNotFound
        }
        guard request.status == .open else {
            throw MarketplaceError.invalidStatusTransition(current: request.status, expected: .cancelled)
        }
        request.status = .cancelled
        try await repository.update(request)
        return request
    }
}
