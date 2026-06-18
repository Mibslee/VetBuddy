import XCTest
@testable import VetBuddy

final class NutritionDynamicContentTests: XCTestCase {

    func testDailyFocusHasEnoughRotationContent() {
        XCTAssertGreaterThanOrEqual(NutritionDynamicContent.dailyFocusCards.count, 100)
    }

    func testRecipeSetsHaveEnoughRotationContentAndNutritionEstimates() {
        XCTAssertGreaterThanOrEqual(NutritionDynamicContent.recipeSets.count, 50)
        XCTAssertTrue(
            NutritionDynamicContent.recipeSets.allSatisfy { set in
                set.meals.count == 3 && set.meals.allSatisfy { !$0.nutritionEstimate.isEmpty }
            }
        )
    }

    func testCommonFoodCatalogExpandedForChineseDietLogging() {
        XCTAssertGreaterThanOrEqual(FoodPortionCatalog.commonFoods.count, 45)
        XCTAssertTrue(FoodPortionCatalog.commonFoods.allSatisfy { $0.gramsPerServing > 0 })
    }
}
