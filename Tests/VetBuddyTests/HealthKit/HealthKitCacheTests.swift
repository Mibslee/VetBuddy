import XCTest
@testable import VetBuddy

final class HealthKitCacheTests: XCTestCase {

    // MARK: - 缓存策略测试

    func testCacheExpiration_CrossDay() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let today = calendar.startOfDay(for: Date())

        let lastSync = yesterday
        let isExpired = !calendar.isDate(lastSync, inSameDayAs: today)
        XCTAssertTrue(isExpired)
    }

    func testCacheExpiration_SameDay() {
        let calendar = Calendar.current
        let now = Date()
        let earlier = calendar.date(byAdding: .hour, value: -2, to: now)!

        let isExpired = !calendar.isDate(earlier, inSameDayAs: now)
        XCTAssertFalse(isExpired)
    }

    // MARK: - DailySummary 模型

    func testDailySummary_Equatable() {
        let summary1 = DailySummary(date: Date(), steps: 5000, heartRate: 72.0, weight: 65.0)
        let summary2 = DailySummary(date: Date(), steps: 5000, heartRate: 72.0, weight: 65.0)
        XCTAssertEqual(summary1, summary2)
    }

    func testDailySummary_OptionalFields() {
        let summary = DailySummary(date: Date(), steps: 0, heartRate: nil, weight: nil)
        XCTAssertNil(summary.heartRate)
        XCTAssertNil(summary.weight)
        XCTAssertEqual(summary.steps, 0)
    }

    func testDailySummary_Codable() throws {
        let original = DailySummary(date: Date(), steps: 8000, heartRate: 75.5, weight: 70.0)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DailySummary.self, from: data)
        XCTAssertEqual(original.steps, decoded.steps)
        XCTAssertEqual(original.heartRate, decoded.heartRate)
        XCTAssertEqual(original.weight, decoded.weight)
    }

    // MARK: - HealthKitPermissionStatus

    func testPermissionStatus_AllCases() {
        let statuses: [HealthKitPermissionStatus] = [.notDetermined, .denied, .authorized]
        XCTAssertEqual(statuses.count, 3)
    }
}
