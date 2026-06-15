import XCTest
@testable import VetBuddy

final class NutritionAdvisorTests: XCTestCase {

    private func makeTestContent() -> NutritionContent {
        NutritionContent(
            generalDisclaimer: "本建议不替代医生诊疗",
            proteinDisclaimer: "蛋白粉不是必须",
            postWorkoutTip: "练完后半小时内补充蛋白质",
            ckdTiers: [
                CKDTier(level: .none, label: "健康", proteinRange: "1.0-1.2", proteinUnit: "g/kg/天", description: "正常摄入", preferredSources: ["鸡蛋", "鱼"]),
                CKDTier(level: .stage3, label: "CKD 3期", proteinRange: "0.8-1.0", proteinUnit: "g/kg/天", description: "减少蛋白", preferredSources: ["豆腐"])
            ],
            foods: [
                FoodItem(name: "鸡蛋", proteinPer100g: "13g", rank: 1, notes: "易消化", bestFor: "all"),
                FoodItem(name: "豆腐", proteinPer100g: "8g", rank: 2, notes: "CKD优选", bestFor: "ckd")
            ],
            carbTips: [
                CarbTip(avoid: "白米饭", replace: "糙米", reason: "GI更低")
            ],
            sampleMeals: SampleDayMeal(
                breakfast: SampleDayMeal.MealSlot(time: "7:30", items: "鸡蛋2个", protein: "~14g"),
                lunch: SampleDayMeal.MealSlot(time: "12:00", items: "鸡胸肉", protein: "~25g"),
                snack: SampleDayMeal.MealSlot(time: "15:30", items: "酸奶", protein: "~8g"),
                dinner: SampleDayMeal.MealSlot(time: "18:00", items: "清蒸鱼", protein: "~20g")
            ),
            motivationalQuotes: ["加油！", "你很棒！"]
        )
    }

    private func makeAssessment(hasCKD: Bool = false, hasDiabetes: Bool = false) -> AssessmentResult {
        AssessmentResult(
            date: Date(),
            riskLevel: .standard,
            fitnessLevel: .L2,
            hasHeartDisease: false,
            hasCKD: hasCKD,
            hasDiabetes: hasDiabetes,
            ageRange: "60-65"
        )
    }

    // MARK: - CKD 分层建议

    func testRecommend_Healthy_NoCKD() {
        let content = makeTestContent()
        let result = makeAssessment()
        let advice = NutritionAdvisor.recommend(for: result, content: content)
        XCTAssertEqual(advice.ckdTier.level, .none)
        XCTAssertTrue(advice.proteinTarget.contains("1.0-1.2"))
    }

    func testRecommend_CKD_Stage3() {
        let content = makeTestContent()
        let result = makeAssessment(hasCKD: true)
        let advice = NutritionAdvisor.recommend(for: result, content: content)
        XCTAssertEqual(advice.ckdTier.level, .stage3)
    }

    // MARK: - 食物推荐

    func testRecommend_FoodsFiltered() {
        let content = makeTestContent()
        let result = makeAssessment()
        let advice = NutritionAdvisor.recommend(for: result, content: content)
        XCTAssertFalse(advice.preferredFoods.isEmpty)
    }

    func testRecommend_CarbTipsIncluded() {
        let content = makeTestContent()
        let result = makeAssessment()
        let advice = NutritionAdvisor.recommend(for: result, content: content)
        XCTAssertFalse(advice.carbTips.isEmpty)
    }

    // MARK: - 糖尿病标记

    func testRecommend_DiabetesFlag() {
        let content = makeTestContent()
        let result = makeAssessment(hasDiabetes: true)
        let advice = NutritionAdvisor.recommend(for: result, content: content)
        XCTAssertTrue(advice.hasDiabetes)
        XCTAssertTrue(advice.disclaimer.contains("糖尿病"))
    }

    // MARK: - 免责声明

    func testRecommend_DisclaimerIncluded() {
        let content = makeTestContent()
        let result = makeAssessment()
        let advice = NutritionAdvisor.recommend(for: result, content: content)
        XCTAssertFalse(advice.disclaimer.isEmpty)
        XCTAssertFalse(advice.postWorkoutTip.isEmpty)
    }

    // MARK: - 激励语

    func testRecommend_RandomQuote() {
        let content = makeTestContent()
        let result = makeAssessment()
        let advice = NutritionAdvisor.recommend(for: result, content: content)
        XCTAssertFalse(advice.randomQuote.isEmpty)
    }
}
