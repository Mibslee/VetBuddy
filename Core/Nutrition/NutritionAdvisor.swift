import Foundation

enum NutritionAdvisor {

    /// Generates personalized nutrition advice based on the user's assessment result.
    static func recommend(
        for result: AssessmentResult,
        content: NutritionContent,
        weightKG: Double? = nil,
        sex: BiologicalSex = .unspecified,
        heightCM: Double? = nil
    ) -> NutritionAdvice {
        let ckdLevel: CKDLevel = result.hasCKD ? result.ckdLevel : .none
        let tier = content.ckdTiers.first { $0.level == ckdLevel }
            ?? content.ckdTiers.first { $0.level == .stage3 && ckdLevel == .unknown }
            ?? content.ckdTiers.first { $0.level == .none }
            ?? content.ckdTiers[0]

        let proteinTarget = "\(tier.proteinRange) \(tier.proteinUnit)"

        let preferredFoods = content.foods.filter { food in
            if ckdLevel == .none {
                return food.bestFor == "all"
            }
            return food.bestFor == "all" || food.bestFor == "ckd"
        }.sorted { $0.rank < $1.rank }

        var disclaimer = content.generalDisclaimer
        disclaimer += "\n" + content.proteinDisclaimer
        if result.hasDiabetes {
            disclaimer += "\n注意：您有糖尿病，需额外关注碳水摄入量，建议咨询内分泌科医生。"
        }
        if result.ckdLevel == .unknown {
            disclaimer += "\n注意：您不确定肾病分期，蛋白质建议按保守范围展示，请优先咨询肾内科医生。"
        }

        let quote = content.motivationalQuotes.randomElement() ?? "加油！"

        // Calculate nutrition requirements if weight is available
        let requirements: NutritionRequirements? = {
            guard let weight = weightKG, weight > 0 else { return nil }
            return NutritionCalculator.calculate(
                weightKG: weight,
                ageRange: result.ageRange,
                sex: sex,
                heightCM: heightCM,
                fitnessLevel: result.fitnessLevel,
                hasDiabetes: result.hasDiabetes,
                hasCKD: result.hasCKD,
                hasHeartDisease: result.hasHeartDisease
            )
        }()

        return NutritionAdvice(
            ckdTier: tier,
            proteinTarget: proteinTarget,
            preferredFoods: preferredFoods,
            carbTips: content.carbTips,
            sampleMeal: content.sampleMeals,
            disclaimer: disclaimer,
            postWorkoutTip: content.postWorkoutTip,
            hasDiabetes: result.hasDiabetes,
            randomQuote: quote,
            requirements: requirements
        )
    }
}
