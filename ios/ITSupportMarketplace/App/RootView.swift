import SwiftUI

struct RootView: View {
    @ObservedObject var viewModel: MarketplaceViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Role", selection: $viewModel.activeRole) {
                    ForEach(AppRole.allCases, id: \.self) { role in
                        Text(role.title).tag(role)
                    }
                }
                .pickerStyle(.segmented)

                if viewModel.activeRole == .customer {
                    CustomerHomeView(viewModel: viewModel)
                } else {
                    EngineerHomeView(viewModel: viewModel)
                }
            }
            .padding()
            .navigationTitle("IT Support Marketplace")
            .task {
                await viewModel.bootstrapIfNeeded()
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}
