import XCTest
@testable import VetBuddy

final class NutritionCalculatorTests: XCTestCase {

    func testCalculate_FemaleTargetLowerThanMaleForSameWeightAgeAndLevel() {
        let male = NutritionCalculator.calculate(
            weightKG: 65,
            ageRange: AgeRange.range65to70.rawValue,
            sex: .male,
            fitnessLevel: .L1,
            hasDiabetes: false,
            hasCKD: false,
            hasHeartDisease: false
        )

        let female = NutritionCalculator.calculate(
            weightKG: 65,
            ageRange: AgeRange.range65to70.rawValue,
            sex: .female,
            fitnessLevel: .L1,
            hasDiabetes: false,
            hasCKD: false,
            hasHeartDisease: false
        )

        XCTAssertLessThan(female.tdee, male.tdee)
        XCTAssertLessThan(female.carbsG, male.carbsG)
    }

    func testCalculate_UnspecifiedSexUsesMiddleEstimate() {
        let male = NutritionCalculator.calculate(
            weightKG: 65,
            ageRange: AgeRange.range65to70.rawValue,
            sex: .male,
            fitnessLevel: .L1,
            hasDiabetes: false,
            hasCKD: false,
            hasHeartDisease: false
        )

        let female = NutritionCalculator.calculate(
            weightKG: 65,
            ageRange: AgeRange.range65to70.rawValue,
            sex: .female,
            fitnessLevel: .L1,
            hasDiabetes: false,
            hasCKD: false,
            hasHeartDisease: false
        )

        let unspecified = NutritionCalculator.calculate(
            weightKG: 65,
            ageRange: AgeRange.range65to70.rawValue,
            sex: .unspecified,
            fitnessLevel: .L1,
            hasDiabetes: false,
            hasCKD: false,
            hasHeartDisease: false
        )

        XCTAssertGreaterThan(unspecified.tdee, female.tdee)
        XCTAssertLessThan(unspecified.tdee, male.tdee)
    }
}
