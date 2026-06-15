import Foundation
import HealthKit

final class HealthKitPermissionManager: ObservableObject {

    @Published var status: HealthKitPermissionStatus = .notDetermined

    private let store = HKHealthStore()
    private let defaults: UserDefaults

    private enum Keys {
        static let readAuthorizationRequested = "vb_hk_read_authorization_requested"
    }

    private let readTypes: Set<HKObjectType> = {
        var types = Set<HKObjectType>()
        if let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount) {
            types.insert(stepCount)
        }
        if let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) {
            types.insert(heartRate)
        }
        if let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass) {
            types.insert(bodyMass)
        }
        return types
    }()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.status = checkCurrentStatus()
    }

    // MARK: - Authorization

    func requestAuthorization() async -> HealthKitPermissionStatus {
        guard HKHealthStore.isHealthDataAvailable() else {
            await MainActor.run { status = .denied }
            return .denied
        }

        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            defaults.set(true, forKey: Keys.readAuthorizationRequested)
            let current: HealthKitPermissionStatus = .authorized
            await MainActor.run { status = current }
            return current
        } catch {
            await MainActor.run { status = .denied }
            return .denied
        }
    }

    func checkCurrentStatus() -> HealthKitPermissionStatus {
        guard HKHealthStore.isHealthDataAvailable() else {
            return .notDetermined
        }

        // HealthKit does not expose reliable read-authorization status.
        // A successful read authorization request is the best user-facing signal.
        return defaults.bool(forKey: Keys.readAuthorizationRequested) ? .authorized : .notDetermined
    }
}
