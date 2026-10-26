import Foundation
import StoreKit

// MARK: - Selah+ subscriptions (StoreKit 2)
// Products must exist in App Store Connect (or the local SelahProducts.storekit
// file selected in the scheme) for prices to load.

@MainActor
final class StoreManager: ObservableObject {
    static let shared = StoreManager()

    static let monthlyID = "selah.plus.monthly"
    static let yearlyID = "selah.plus.yearly"

    @Published var monthly: Product?
    @Published var yearly: Product?
    @Published var purchasing = false

    private var updatesTask: Task<Void, Never>?

    func start(store: UserStore) {
        guard updatesTask == nil else { return }
        updatesTask = Task {
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                    await refreshEntitlements(store: store)
                }
            }
        }
        Task {
            await loadProducts()
            await refreshEntitlements(store: store)
        }
    }

    func loadProducts() async {
        let products = (try? await Product.products(for: [Self.monthlyID, Self.yearlyID])) ?? []
        monthly = products.first { $0.id == Self.monthlyID }
        yearly = products.first { $0.id == Self.yearlyID }
    }

    /// Returns true when the purchase completed and entitlement is active.
    func purchase(_ product: Product, store: UserStore) async throws -> Bool {
        purchasing = true
        defer { purchasing = false }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else { return false }
            await transaction.finish()
            store.isPremium = true
            return true
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restore(store: UserStore) async {
        try? await AppStore.sync()
        await refreshEntitlements(store: store)
    }

    func refreshEntitlements(store: UserStore) async {
        var active = false
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement, transaction.revocationDate == nil {
                active = true
            }
        }
        #if DEBUG
        // Keep the dev toggle usable when no sandbox purchase exists.
        if active { store.isPremium = true }
        #else
        store.isPremium = active
        #endif
    }
}
