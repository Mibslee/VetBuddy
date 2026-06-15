import Foundation
import HealthKit
import Combine

final class HealthKitService: ObservableObject {

    @Published var todaySummary: DailySummary?
    @Published var isLoading = false

    private let store = HKHealthStore()

    private enum CacheKeys {
        static let lastSyncDate = "vb_hk_lastSyncDate"
        static let cachedSteps = "vb_hk_cachedSteps"
        static let cachedHeartRate = "vb_hk_cachedHeartRate"
        static let cachedWeight = "vb_hk_cachedWeight"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Public API

    func fetchTodaySummary() async throws -> DailySummary {
        let steps: Int
        let heartRate: Double?
        let weight: Double?

        do {
            steps = try await fetchSteps()
        } catch {
            steps = 0
        }

        do {
            heartRate = try await fetchHeartRate()
        } catch {
            heartRate = nil
        }

        do {
            weight = try await fetchLatestWeight()
        } catch {
            weight = nil
        }

        let summary = DailySummary(
            date: Date(),
            steps: steps,
            heartRate: heartRate,
            weight: weight
        )

        cacheSummary(summary)
        return summary
    }

    func fetchSteps() async throws -> Int {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthDataError.notAvailable
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: HealthDataError.queryFailed(error.localizedDescription))
                    return
                }
                let count = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(count))
            }
            store.execute(query)
        }
    }

    func fetchHeartRate() async throws -> Double? {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            throw HealthDataError.notAvailable
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: hrType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: HealthDataError.queryFailed(error.localizedDescription))
                    return
                }
                let bpm = result?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                continuation.resume(returning: bpm)
            }
            store.execute(query)
        }
    }

    func fetchLatestWeight() async throws -> Double? {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            throw HealthDataError.notAvailable
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: weightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error {
                    continuation.resume(throwing: HealthDataError.queryFailed(error.localizedDescription))
                    return
                }
                guard let sample = results?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                let kg = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                continuation.resume(returning: kg)
            }
            store.execute(query)
        }
    }

    @MainActor
    func refreshAll(force: Bool = false) async {
        isLoading = true
        defer { isLoading = false }

        guard HKHealthStore.isHealthDataAvailable() else {
            todaySummary = loadCachedSummary()
            return
        }

        if !force, let cached = loadCachedIfFresh() {
            todaySummary = cached
            return
        }

        do {
            todaySummary = try await fetchTodaySummary()
        } catch {
            todaySummary = loadCachedSummary()
        }
    }

    @MainActor
    func saveManualSummary(steps: Int?, heartRate: Double?, weight: Double?) {
        let current = todaySummary ?? loadCachedSummary()
        let summary = DailySummary(
            date: Date(),
            steps: steps ?? current?.steps ?? 0,
            heartRate: heartRate ?? current?.heartRate,
            weight: weight ?? current?.weight
        )
        cacheSummary(summary)
        todaySummary = summary
    }

    // MARK: - Cache

    private func cacheSummary(_ summary: DailySummary) {
        defaults.set(Date(), forKey: CacheKeys.lastSyncDate)
        defaults.set(summary.steps, forKey: CacheKeys.cachedSteps)
        if let hr = summary.heartRate {
            defaults.set(hr, forKey: CacheKeys.cachedHeartRate)
        }
        if let w = summary.weight {
            defaults.set(w, forKey: CacheKeys.cachedWeight)
        }
    }

    private func loadCachedSummary() -> DailySummary? {
        guard let lastSync = defaults.object(forKey: CacheKeys.lastSyncDate) as? Date else {
            return nil
        }
        return DailySummary(
            date: lastSync,
            steps: defaults.integer(forKey: CacheKeys.cachedSteps),
            heartRate: defaults.object(forKey: CacheKeys.cachedHeartRate) as? Double,
            weight: defaults.object(forKey: CacheKeys.cachedWeight) as? Double
        )
    }

    private func loadCachedIfFresh() -> DailySummary? {
        guard let lastSync = defaults.object(forKey: CacheKeys.lastSyncDate) as? Date else {
            return nil
        }
        let isSameDay = Calendar.current.isDateInToday(lastSync)
        guard isSameDay else { return nil }
        return loadCachedSummary()
    }
}
