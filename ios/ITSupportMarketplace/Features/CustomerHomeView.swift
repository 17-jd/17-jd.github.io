import SwiftUI
import MarketplaceCore

struct CustomerHomeView: View {
    @ObservedObject var viewModel: MarketplaceViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GroupBox("Request IT Support") {
                VStack(spacing: 10) {
                    TextField("Customer name", text: $viewModel.customerName)
                        .textFieldStyle(.roundedBorder)

                    TextField("Describe your issue", text: $viewModel.issueSummary, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                        .textFieldStyle(.roundedBorder)

                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(SupportCategory.allCases, id: \.self) { category in
                            Text(category.rawValue.capitalized).tag(category)
                        }
                    }

                    Picker("Location", selection: $viewModel.selectedLocation) {
                        ForEach(viewModel.availableLocations, id: \.label) { location in
                            Text(location.label).tag(location)
                        }
                    }

                    Button("Request Engineer") {
                        Task { await viewModel.submitRequest() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.issueSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.top, 4)
            }

            if !viewModel.recommendedEngineers.isEmpty {
                GroupBox("Suggested Engineers") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.recommendedEngineers.prefix(3)) { engineer in
                            Text("\(engineer.name) • \(engineer.skills.map(\.rawValue).joined(separator: ", "))")
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            GroupBox("My Requests") {
                if viewModel.customerRequests.isEmpty {
                    Text("No requests yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(viewModel.customerRequests) { request in
                                RequestCard(request: request, statusText: viewModel.statusText(for: request)) {
                                    if request.status == .open {
                                        Button("Cancel", role: .destructive) {
                                            Task { await viewModel.cancelRequest(request.id) }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 260)
                }
            }
        }
    }
}
