import Foundation

public enum MarketplaceSampleData {
    public static func engineers() -> [Engineer] {
        [
            Engineer(
                id: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
                name: "Maya Chen",
                skills: [.network, .security, .accountAccess],
                currentLocation: GeoPoint(latitude: 37.7749, longitude: -122.4194)
            ),
            Engineer(
                id: UUID(uuidString: "22222222-2222-2222-2222-222222222222") ?? UUID(),
                name: "Noah Patel",
                skills: [.hardware, .software],
                currentLocation: GeoPoint(latitude: 37.7849, longitude: -122.4094)
            ),
            Engineer(
                id: UUID(uuidString: "33333333-3333-3333-3333-333333333333") ?? UUID(),
                name: "Ava Rodriguez",
                skills: [.software, .network, .security],
                currentLocation: GeoPoint(latitude: 37.7649, longitude: -122.4294)
            )
        ]
    }

    public static func supportLocations() -> [SupportLocation] {
        [
            SupportLocation(
                label: "Downtown Office",
                point: GeoPoint(latitude: 37.7793, longitude: -122.4192)
            ),
            SupportLocation(
                label: "Warehouse",
                point: GeoPoint(latitude: 37.8044, longitude: -122.2712)
            ),
            SupportLocation(
                label: "Home Office",
                point: GeoPoint(latitude: 37.7652, longitude: -122.2416)
            )
        ]
    }
}
