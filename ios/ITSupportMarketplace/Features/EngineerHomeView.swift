import SwiftUI
import MarketplaceCore

struct EngineerHomeView: View {
    @ObservedObject var viewModel: MarketplaceViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GroupBox("Engineer Console") {
                Picker("Engineer", selection: $viewModel.selectedEngineerID) {
                    ForEach(viewModel.engineers) { engineer in
                        Text(engineer.name).tag(engineer.id as UUID?)
                    }
                }
                .onChange(of: viewModel.selectedEngineerID) { _, _ in
                    Task { await viewModel.refresh() }
                }
            }

            GroupBox("Open Requests") {
                if viewModel.openRequests.isEmpty {
                    Text("No open requests.")
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(viewModel.openRequests) { request in
                                RequestCard(request: request, statusText: viewModel.statusText(for: request)) {
                                    Button("Accept") {
                                        Task { await viewModel.accept(request.id) }
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 220)
                }
            }

            GroupBox("Assigned To Me") {
                if viewModel.engineerRequests.isEmpty {
                    Text("No assigned jobs.")
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(viewModel.engineerRequests) { request in
                                RequestCard(request: request, statusText: viewModel.statusText(for: request)) {
                                    if request.status == .accepted {
                                        Button("Start Work") {
                                            Task { await viewModel.start(request.id) }
                                        }
                                    } else if request.status == .inProgress {
                                        Button("Complete") {
                                            Task { await viewModel.complete(request.id) }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 220)
                }
            }
        }
    }
}
