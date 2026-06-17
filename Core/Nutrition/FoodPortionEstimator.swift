import Foundation

struct CommonFoodPortion: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let defaultMealType: MealType
    let servingName: String
    let gramsPerServing: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let note: String

    func entry(mealType: MealType, servings: Double, date: Date = Date()) -> DietLogEntry {
        DietLogEntry(
            date: date,
            mealType: mealType,
            foodName: servings == 1 ? name : "\(name) x\(servingsText(servings))",
            grams: gramsPerServing * servings,
            proteinPer100g: proteinPer100g,
            carbsPer100g: carbsPer100g,
            fatPer100g: fatPer100g
        )
    }

    private func servingsText(_ servings: Double) -> String {
        if servings.rounded() == servings {
            return String(format: "%.0f", servings)
        }
        return String(format: "%.1f", servings)
    }
}

enum FoodPortionCatalog {
    static let commonFoods: [CommonFoodPortion] = [
        CommonFoodPortion(id: "egg", name: "鸡蛋", defaultMealType: .breakfast, servingName: "1 个", gramsPerServing: 50, proteinPer100g: 13.0, carbsPer100g: 1.1, fatPer100g: 10.0, note: "适合早餐或加餐，牙口差可做鸡蛋羹。"),
        CommonFoodPortion(id: "milk", name: "牛奶", defaultMealType: .breakfast, servingName: "1 杯", gramsPerServing: 250, proteinPer100g: 3.3, carbsPer100g: 5.0, fatPer100g: 3.6, note: "乳糖不耐受可换无糖酸奶或低乳糖奶。"),
        CommonFoodPortion(id: "soy_milk", name: "无糖豆浆", defaultMealType: .breakfast, servingName: "1 杯", gramsPerServing: 250, proteinPer100g: 3.0, carbsPer100g: 1.2, fatPer100g: 1.6, note: "选择无糖，肾病用户按医嘱控制豆制品。"),
        CommonFoodPortion(id: "tofu", name: "北豆腐", defaultMealType: .lunch, servingName: "半盒", gramsPerServing: 100, proteinPer100g: 12.2, carbsPer100g: 3.0, fatPer100g: 4.8, note: "炖汤、蒸煮更适合老年人口味。"),
        CommonFoodPortion(id: "fish", name: "清蒸鱼肉", defaultMealType: .lunch, servingName: "1 掌心", gramsPerServing: 100, proteinPer100g: 18.0, carbsPer100g: 0.0, fatPer100g: 4.0, note: "注意去刺，少放盐和酱油。"),
        CommonFoodPortion(id: "chicken", name: "鸡胸/鸡腿去皮肉", defaultMealType: .lunch, servingName: "1 掌心", gramsPerServing: 100, proteinPer100g: 20.0, carbsPer100g: 0.0, fatPer100g: 5.0, note: "切小块或做肉丸更好咀嚼。"),
        CommonFoodPortion(id: "shrimp", name: "虾仁", defaultMealType: .dinner, servingName: "1 小碗", gramsPerServing: 100, proteinPer100g: 18.6, carbsPer100g: 0.0, fatPer100g: 1.4, note: "痛风或肾病用户按医嘱控制。"),
        CommonFoodPortion(id: "lean_pork", name: "瘦猪肉", defaultMealType: .lunch, servingName: "1 掌心", gramsPerServing: 75, proteinPer100g: 20.3, carbsPer100g: 1.5, fatPer100g: 6.2, note: "优先蒸煮炖，少做红烧重油。"),
        CommonFoodPortion(id: "rice", name: "米饭", defaultMealType: .lunch, servingName: "半碗", gramsPerServing: 100, proteinPer100g: 2.6, carbsPer100g: 25.9, fatPer100g: 0.3, note: "糖尿病用户可减量并搭配蔬菜和蛋白。"),
        CommonFoodPortion(id: "mixed_rice", name: "杂粮饭", defaultMealType: .lunch, servingName: "半碗", gramsPerServing: 100, proteinPer100g: 3.5, carbsPer100g: 23.0, fatPer100g: 0.8, note: "比白米饭更有饱腹感。"),
        CommonFoodPortion(id: "oatmeal", name: "燕麦粥", defaultMealType: .breakfast, servingName: "1 小碗", gramsPerServing: 180, proteinPer100g: 2.5, carbsPer100g: 12.0, fatPer100g: 1.5, note: "不要额外加糖。"),
        CommonFoodPortion(id: "sweet_potato", name: "红薯", defaultMealType: .dinner, servingName: "半个", gramsPerServing: 100, proteinPer100g: 1.6, carbsPer100g: 20.1, fatPer100g: 0.2, note: "可替代部分米饭。"),
        CommonFoodPortion(id: "yam", name: "山药", defaultMealType: .dinner, servingName: "1 段", gramsPerServing: 100, proteinPer100g: 1.9, carbsPer100g: 12.4, fatPer100g: 0.2, note: "软糯易入口，仍按主食计算。"),
        CommonFoodPortion(id: "greens", name: "绿叶菜", defaultMealType: .lunch, servingName: "1 碗", gramsPerServing: 200, proteinPer100g: 2.0, carbsPer100g: 3.5, fatPer100g: 0.3, note: "少油快炒、焯拌或煮汤。"),
        CommonFoodPortion(id: "tomato", name: "番茄", defaultMealType: .dinner, servingName: "1 个", gramsPerServing: 150, proteinPer100g: 0.9, carbsPer100g: 3.3, fatPer100g: 0.2, note: "适合搭配鸡蛋或豆腐。"),
        CommonFoodPortion(id: "yogurt", name: "无糖酸奶", defaultMealType: .snack, servingName: "1 杯", gramsPerServing: 150, proteinPer100g: 3.5, carbsPer100g: 5.0, fatPer100g: 3.0, note: "注意选择无糖或低糖。"),
        CommonFoodPortion(id: "apple", name: "苹果", defaultMealType: .snack, servingName: "半个", gramsPerServing: 100, proteinPer100g: 0.3, carbsPer100g: 13.5, fatPer100g: 0.2, note: "水果不替代正餐蛋白。"),
        CommonFoodPortion(id: "walnut", name: "核桃仁", defaultMealType: .snack, servingName: "2 个核桃", gramsPerServing: 15, proteinPer100g: 14.9, carbsPer100g: 9.6, fatPer100g: 58.8, note: "脂肪高，少量即可。")
    ]
}
