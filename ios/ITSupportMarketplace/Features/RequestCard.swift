import SwiftUI
import MarketplaceCore

struct RequestCard<Actions: View>: View {
    let request: SupportRequest
    let statusText: String
    @ViewBuilder let actions: () -> Actions

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(request.summary)
                .font(.headline)
            Text("Customer: \(request.customerName)")
                .font(.subheadline)
            Text("Category: \(request.category.rawValue.capitalized)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Location: \(request.location.label)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Status: \(statusText)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                actions()
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
