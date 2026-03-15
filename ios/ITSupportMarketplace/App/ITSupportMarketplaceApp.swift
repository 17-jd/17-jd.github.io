import SwiftUI

@main
struct ITSupportMarketplaceApp: App {
    @StateObject private var viewModel = MarketplaceViewModel()

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: viewModel)
        }
    }
}
