# IT Support Marketplace (Uber-style iOS Concept)

This repository now contains a starter implementation for an **Uber-like marketplace app for IT support**:

- **Customers** create support requests (network/hardware/software/security/account access).
- **Engineers** act like drivers in Uber: they view open jobs, accept them, start work, and complete service.
- A small **matching engine** ranks nearby, skilled engineers.

## Structure

- `Sources/MarketplaceCore`: testable domain and service logic.
- `Tests/MarketplaceCoreTests`: lifecycle and matching tests.
- `ios/ITSupportMarketplace`: SwiftUI iOS app screens/view-model.

## Domain flow

`open -> accepted -> inProgress -> completed`

The customer can cancel only while the request is `open`.

## Run tests

`swift test`

## Open iOS app code

The SwiftUI app code is under `ios/ITSupportMarketplace`.  
Create an Xcode iOS App project and copy these files in, or attach this package as a local dependency and import `MarketplaceCore`.