import Foundation

public enum UserRole: String, CaseIterable, Sendable {
    case customer
    case engineer
}

public enum SupportCategory: String, CaseIterable, Codable, Sendable {
    case network
    case hardware
    case software
    case security
    case accountAccess
}

public enum SupportRequestStatus: String, Codable, Sendable {
    case open
    case accepted
    case inProgress
    case completed
    case cancelled
}

public struct GeoPoint: Codable, Equatable, Hashable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct SupportLocation: Codable, Equatable, Hashable, Sendable {
    public let label: String
    public let point: GeoPoint

    public init(label: String, point: GeoPoint) {
        self.label = label
        self.point = point
    }
}

public struct SupportRequestDraft: Equatable, Sendable {
    public let customerName: String
    public let summary: String
    public let category: SupportCategory
    public let location: SupportLocation

    public init(customerName: String, summary: String, category: SupportCategory, location: SupportLocation) {
        self.customerName = customerName
        self.summary = summary
        self.category = category
        self.location = location
    }
}

public struct SupportRequest: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let customerName: String
    public let summary: String
    public let category: SupportCategory
    public let location: SupportLocation
    public let createdAt: Date
    public var status: SupportRequestStatus
    public var assignedEngineerID: UUID?

    public init(
        id: UUID = UUID(),
        customerName: String,
        summary: String,
        category: SupportCategory,
        location: SupportLocation,
        createdAt: Date = Date(),
        status: SupportRequestStatus = .open,
        assignedEngineerID: UUID? = nil
    ) {
        self.id = id
        self.customerName = customerName
        self.summary = summary
        self.category = category
        self.location = location
        self.createdAt = createdAt
        self.status = status
        self.assignedEngineerID = assignedEngineerID
    }
}

public struct Engineer: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let skills: [SupportCategory]
    public let currentLocation: GeoPoint
    public var isAvailable: Bool

    public init(
        id: UUID = UUID(),
        name: String,
        skills: [SupportCategory],
        currentLocation: GeoPoint,
        isAvailable: Bool = true
    ) {
        self.id = id
        self.name = name
        self.skills = skills
        self.currentLocation = currentLocation
        self.isAvailable = isAvailable
    }
}
