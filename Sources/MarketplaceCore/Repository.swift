import Foundation

public protocol SupportRequestRepository: Sendable {
    func insert(_ request: SupportRequest) async throws
    func update(_ request: SupportRequest) async throws
    func list() async throws -> [SupportRequest]
    func get(id: UUID) async throws -> SupportRequest?
}

public enum MarketplaceError: LocalizedError, Equatable {
    case invalidInput(String)
    case requestNotFound
    case engineerNotFound
    case engineerUnavailable
    case invalidStatusTransition(current: SupportRequestStatus, expected: SupportRequestStatus)
    case requestAlreadyAssigned

    public var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return message
        case .requestNotFound:
            return "Support request was not found."
        case .engineerNotFound:
            return "Engineer was not found."
        case .engineerUnavailable:
            return "Engineer is unavailable."
        case .invalidStatusTransition(let current, let expected):
            return "Invalid status transition from \(current.rawValue) to \(expected.rawValue)."
        case .requestAlreadyAssigned:
            return "Support request is already assigned."
        }
    }
}

public actor InMemorySupportRequestRepository: SupportRequestRepository {
    private var storage: [UUID: SupportRequest] = [:]

    public init() {}

    public func insert(_ request: SupportRequest) async throws {
        storage[request.id] = request
    }

    public func update(_ request: SupportRequest) async throws {
        storage[request.id] = request
    }

    public func list() async throws -> [SupportRequest] {
        storage.values.sorted { $0.createdAt > $1.createdAt }
    }

    public func get(id: UUID) async throws -> SupportRequest? {
        storage[id]
    }
}
