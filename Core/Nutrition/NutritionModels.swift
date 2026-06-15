import Foundation

// MARK: - Nutrition Content (decoded from JSON)

struct NutritionContent: Equatable, Sendable {
    let generalDisclaimer: String
    let proteinDisclaimer: String
    let postWorkoutTip: String
    let ckdTiers: [CKDTier]
    let foods: [FoodItem]
    let carbTips: [CarbTip]
    let sampleMeals: SampleDayMeal
    let motivationalQuotes: [String]
}

// MARK: - CKD Tier

struct CKDTier: Codable, Equatable, Sendable {
    let level: CKDLevel
    let label: String
    let proteinRange: String
    let proteinUnit: String
    let description: String
    let preferredSources: [String]
}

// MARK: - Food Item

struct FoodItem: Codable, Equatable, Identifiable, Sendable {
    var id: String { name }
    let name: String
    let proteinPer100g: String
    let rank: Int
    let notes: String
    let bestFor: String
}

// MARK: - Carb Tip

struct CarbTip: Codable, Equatable, Sendable {
    let avoid: String
    let replace: String
    let reason: String
}

// MARK: - Sample Day Meal

struct SampleDayMeal: Codable, Equatable, Sendable {
    let breakfast: MealSlot
    let lunch: MealSlot
    let snack: MealSlot
    let dinner: MealSlot

    struct MealSlot: Codable, Equatable, Sendable {
        let time: String
        let items: String
        let protein: String
    }
}

// MARK: - Nutrition Requirements (calculated from personal metrics)

struct NutritionRequirements: Equatable, Sendable {
    let bmr: Int
    let tdee: Int
    let proteinG: Int
    let carbsG: Int
    let fatG: Int
    let waterML: Int
    let adjustments: [String]
}

// MARK: - Nutrition Advice (computed for a specific user)

struct NutritionAdvice: Equatable, Sendable {
    let ckdTier: CKDTier
    let proteinTarget: String
    let preferredFoods: [FoodItem]
    let carbTips: [CarbTip]
    let sampleMeal: SampleDayMeal
    let disclaimer: String
    let postWorkoutTip: String
    let hasDiabetes: Bool
    let randomQuote: String
    let requirements: NutritionRequirements?
}
