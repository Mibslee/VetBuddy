import Foundation

/// Calculates daily nutrition requirements using Mifflin-St Jeor equation
/// and standard macronutrient distribution ratios.
///
/// Data sources:
/// - BMR: Mifflin MD et al., Am J Clin Nutr, 1990
/// - Activity multipliers: ACSM Guidelines for Exercise Testing, 11th Ed
/// - Chinese DRI 2023: Chinese Nutrition Society
/// - CKD protein: KDIGO 2024 Clinical Practice Guideline
/// - Diabetes carbs: ADA Standards of Care 2025
/// - Heart disease: AHA Dietary Guidelines 2021
enum NutritionCalculator {

    // MARK: - Public

    static func calculate(
        weightKG: Double,
        ageRange: String,
        isMale: Bool,
        fitnessLevel: FitnessLevel,
        hasDiabetes: Bool,
        hasCKD: Bool,
        hasHeartDisease: Bool
    ) -> NutritionRequirements {
        let age = midpointAge(ageRange)
        let heightCM = defaultHeight(isMale: isMale, age: age)

        let bmr = mifflinStJeor(weightKG: weightKG, heightCM: heightCM, age: age, isMale: isMale)
        let activityMultiplier = multiplierForFitness(fitnessLevel)
        let tdee = Int(Double(bmr) * activityMultiplier)

        var adjustments: [String] = []

        // Base macros (moderate activity default)
        var proteinRatio = 0.20
        var carbsRatio = 0.50
        var fatRatio = 0.30

        // Health adjustments
        if hasCKD {
            // KDIGO: 0.6-0.8 g/kg for CKD stage 3+, 0.8 g/kg for stage 1-2
            let proteinG = Int(weightKG * 0.7)
            proteinRatio = Double(proteinG) / Double(tdee) * 4.0
            carbsRatio = 0.55
            fatRatio = 1.0 - proteinRatio - carbsRatio
            adjustments.append("CKD: 蛋白质限制至 0.7g/kg（KDIGO 2024）")
        }

        if hasDiabetes {
            // ADA 2025: carbs 45-50% but favor low GI
            carbsRatio = min(carbsRatio, 0.45)
            proteinRatio = max(proteinRatio, 0.20)
            fatRatio = 1.0 - proteinRatio - carbsRatio
            adjustments.append("糖尿病: 碳水降至 45%，优选低 GI 食物（ADA 2025）")
        }

        if hasHeartDisease {
            // AHA: limit saturated fat <7% total calories, sodium <1500mg
            fatRatio = min(fatRatio, 0.25)
            proteinRatio = max(proteinRatio, 0.20)
            carbsRatio = 1.0 - proteinRatio - fatRatio
            adjustments.append("心血管: 脂肪降至 25%，钠 <1500mg/天（AHA 2021）")
        }

        let proteinG = hasCKD ? Int(weightKG * 0.7) : max(Int(Double(tdee) * proteinRatio / 4.0), Int(weightKG * 1.0))
        let carbsG = Int(Double(tdee) * carbsRatio / 4.0)
        let fatG = Int(Double(tdee) * fatRatio / 9.0)
        let waterML = Int(weightKG * 30) // 30ml/kg, Chinese DRI

        return NutritionRequirements(
            bmr: bmr,
            tdee: tdee,
            proteinG: proteinG,
            carbsG: carbsG,
            fatG: fatG,
            waterML: waterML,
            adjustments: adjustments
        )
    }

    // MARK: - BMR (Mifflin-St Jeor)

    /// Mifflin-St Jeor equation (1990), considered most accurate for elderly.
    /// Reference: Mifflin MD et al., "A new predictive equation for resting energy
    /// expenditure in healthy individuals.", Am J Clin Nutr. 1990;51(2):241-7.
    private static func mifflinStJeor(
        weightKG: Double, heightCM: Double, age: Int, isMale: Bool
    ) -> Int {
        if isMale {
            return Int(10 * weightKG + 6.25 * heightCM - 5 * Double(age) + 5)
        } else {
            return Int(10 * weightKG + 6.25 * heightCM - 5 * Double(age) - 161)
        }
    }

    // MARK: - Activity Multipliers

    /// ACSM standard activity multipliers mapped to fitness levels.
    /// L1 = sedentary/light (1.3), L2 = moderate (1.5), L3 = active (1.7)
    private static func multiplierForFitness(_ level: FitnessLevel) -> Double {
        switch level {
        case .L1: return 1.3  // Sedentary to light activity
        case .L2: return 1.5  // Moderate activity (3-5 days/week)
        case .L3: return 1.7  // Active (6-7 days/week)
        }
    }

    // MARK: - Helpers

    /// Parse "60-70" → 65, "70+" → 75, fallback → 70
    private static func midpointAge(_ range: String) -> Int {
        switch range {
        case AgeRange.range60to65.rawValue:
            return 63
        case AgeRange.range65to70.rawValue:
            return 68
        case AgeRange.range70to75.rawValue:
            return 73
        case AgeRange.range75plus.rawValue:
            return 78
        default:
            break
        }

        let cleaned = range.replacingOccurrences(of: " ", with: "")
        if cleaned.hasSuffix("+") {
            let num = cleaned.dropLast()
            return (Int(num) ?? 70) + 5
        }
        let parts = cleaned.split(separator: "-")
        if parts.count == 2, let lo = Int(parts[0]), let hi = Int(parts[1]) {
            return (lo + hi) / 2
        }
        return Int(cleaned) ?? 70
    }

    /// Default height assumption for elderly Chinese.
    /// Source: Chinese DRIs 2023, Table 2-1 (average by age group).
    /// Male 60-70: ~165cm, Female 60-70: ~155cm.
    private static func defaultHeight(isMale: Bool, age: Int) -> Double {
        if isMale {
            return age >= 70 ? 162.0 : 165.0
        } else {
            return age >= 70 ? 150.0 : 155.0
        }
    }
}
