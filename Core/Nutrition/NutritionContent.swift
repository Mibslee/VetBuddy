import Foundation

struct NutritionContentLoader {

    /// Loads nutrition advice from the app bundle JSON file.
    static func load() -> NutritionContent? {
        guard let url = Bundle.main.url(forResource: "nutrition_advice", withExtension: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(RawContent.self, from: data)
            return NutritionContent(
                generalDisclaimer: decoded.generalDisclaimer,
                proteinDisclaimer: decoded.proteinDisclaimer,
                postWorkoutTip: decoded.postWorkoutTip,
                ckdTiers: decoded.ckdTiers,
                foods: decoded.foods,
                carbTips: decoded.carbTips,
                sampleMeals: decoded.sampleMeals,
                motivationalQuotes: decoded.motivationalQuotes
            )
        } catch {
            return nil
        }
    }

    /// Sample content for previews and testing.
    static let sampleAdvice = NutritionContent(
        generalDisclaimer: "本建议不替代医生诊疗。如有肾病或糖尿病，请咨询医生后再调整饮食。",
        proteinDisclaimer: "蛋白粉/补剂不是必须，日常饮食优先。",
        postWorkoutTip: "练完后半小时内喝一杯牛奶 + 吃两个鸡蛋，效果最好。别超过1小时。",
        ckdTiers: [
            CKDTier(
                level: .none,
                label: "健康（无肾脏疾病）",
                proteinRange: "1.0-1.2",
                proteinUnit: "g/kg/天",
                description: "正常蛋白质摄入，每日食物多样性≥12种",
                preferredSources: ["鸡蛋", "鱼/禽", "瘦肉", "豆制品", "牛奶"]
            ),
            CKDTier(
                level: .stage3,
                label: "CKD 3期（eGFR 30-59）",
                proteinRange: "0.8-1.0",
                proteinUnit: "g/kg/天",
                description: "减少蛋白质摄入，优选植物蛋白",
                preferredSources: ["豆腐", "豆制品", "鸡蛋（限量）"]
            )
        ],
        foods: [
            FoodItem(name: "鸡蛋（全蛋）", proteinPer100g: "13g", rank: 1, notes: "易消化、烹饪简单", bestFor: "all"),
            FoodItem(name: "鸡胸肉", proteinPer100g: "23-25g", rank: 1, notes: "需切小块或剁碎", bestFor: "all"),
            FoodItem(name: "豆腐/豆制品", proteinPer100g: "8g", rank: 2, notes: "CKD患者优选", bestFor: "ckd"),
        ],
        carbTips: [
            CarbTip(avoid: "白米饭", replace: "糙米/杂粮饭", reason: "白米GI约73，糙米GI约55"),
            CarbTip(avoid: "含糖饮料", replace: "白开水/淡茶", reason: "一杯可乐约54g精制糖"),
        ],
        sampleMeals: SampleDayMeal(
            breakfast: SampleDayMeal.MealSlot(time: "7:30", items: "鸡蛋2个 + 牛奶250ml + 全麦面包1片", protein: "~22g"),
            lunch: SampleDayMeal.MealSlot(time: "12:00", items: "鸡胸肉100g + 杂粮饭200g + 蒸西兰花", protein: "~40g"),
            snack: SampleDayMeal.MealSlot(time: "15:30", items: "无糖酸奶200g + 杏仁一小把", protein: "~10g"),
            dinner: SampleDayMeal.MealSlot(time: "18:00", items: "清蒸鱼100g + 糙米饭100g + 焯青菜", protein: "~30g")
        ),
        motivationalQuotes: [
            "今天也是元气满满的一天！",
            "一小步，一大步！",
            "你比昨天的自己更棒！",
            "坚持就是胜利，加油！",
            "每天动一动，身体更轻松！"
        ]
    )
}

// MARK: - Raw JSON Decoding

private struct RawContent: Decodable {
    let generalDisclaimer: String
    let proteinDisclaimer: String
    let postWorkoutTip: String
    let ckdTiers: [CKDTier]
    let foods: [FoodItem]
    let carbTips: [CarbTip]
    let sampleMeals: SampleDayMeal
    let motivationalQuotes: [String]
}
