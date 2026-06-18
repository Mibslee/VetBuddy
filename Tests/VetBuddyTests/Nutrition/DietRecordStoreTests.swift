import XCTest
@testable import VetBuddy

final class DietRecordStoreTests: XCTestCase {

    private var defaults: UserDefaults!
    private var store: DietRecordStore!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "DietRecordStoreTests")!
        defaults.removePersistentDomain(forName: "DietRecordStoreTests")
        store = DietRecordStore(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "DietRecordStoreTests")
        store = nil
        defaults = nil
        super.tearDown()
    }

    func testSummarizeCalculatesMacrosFromPer100gValues() {
        let entries = [
            DietLogEntry(mealType: .breakfast, foodName: "鸡蛋", grams: 100, proteinPer100g: 13, carbsPer100g: 1, fatPer100g: 10),
            DietLogEntry(mealType: .lunch, foodName: "米饭", grams: 200, proteinPer100g: 2.6, carbsPer100g: 25, fatPer100g: 0.3)
        ]

        let summary = DietAnalyzer.summarize(entries)

        XCTAssertEqual(summary.proteinG, 18.2, accuracy: 0.01)
        XCTAssertEqual(summary.carbsG, 51.0, accuracy: 0.01)
        XCTAssertEqual(summary.fatG, 10.6, accuracy: 0.01)
    }

    func testAnalyzeMarksNutrientsAgainstTargets() {
        let requirements = NutritionRequirements(
            bmr: 1200,
            tdee: 1600,
            proteinG: 60,
            carbsG: 180,
            fatG: 50,
            waterML: 1800,
            adjustments: []
        )
        let entries = [
            DietLogEntry(mealType: .lunch, foodName: "鸡胸肉", grams: 200, proteinPer100g: 25, carbsPer100g: 0, fatPer100g: 2),
            DietLogEntry(mealType: .dinner, foodName: "米饭", grams: 400, proteinPer100g: 2.6, carbsPer100g: 25, fatPer100g: 0.3)
        ]

        let analysis = DietAnalyzer.analyze(entries: entries, requirements: requirements)

        XCTAssertEqual(analysis.protein.status, .onTrack)
        XCTAssertEqual(analysis.carbs.status, .low)
        XCTAssertEqual(analysis.fat.status, .low)
    }

    func testStoreLoadsOnlyEntriesForRequestedDate() {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        store.addEntry(DietLogEntry(date: today, mealType: .breakfast, foodName: "牛奶", grams: 250, proteinPer100g: 3.2, carbsPer100g: 5, fatPer100g: 3))
        store.addEntry(DietLogEntry(date: yesterday, mealType: .breakfast, foodName: "鸡蛋", grams: 100, proteinPer100g: 13, carbsPer100g: 1, fatPer100g: 10))

        let entries = store.loadEntries(for: today)

        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.foodName, "牛奶")
    }

    func testRepeatEntriesCopiesEntriesToTodayAndReturnsCount() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let source = [
            DietLogEntry(date: yesterday, mealType: .breakfast, foodName: "鸡蛋", grams: 50, proteinPer100g: 13, carbsPer100g: 1, fatPer100g: 10),
            DietLogEntry(date: yesterday, mealType: .breakfast, foodName: "牛奶", grams: 250, proteinPer100g: 3.2, carbsPer100g: 5, fatPer100g: 3)
        ]

        let count = store.repeatEntries(source)
        let todayEntries = store.loadEntries()

        XCTAssertEqual(count, 2)
        XCTAssertEqual(todayEntries.count, 2)
        XCTAssertEqual(Set(todayEntries.map(\.foodName)), Set(["鸡蛋", "牛奶"]))
    }
}
