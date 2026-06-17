import Foundation

struct NutritionDailyFocus: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let tips: [String]
}

struct SeniorRecipeSet: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let tag: String
    let meals: [SeniorRecipe]
}

struct SeniorRecipe: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let tag: String
    let items: String
    let notes: String
}

enum NutritionDynamicContent {
    static let dailyFocusCards: [NutritionDailyFocus] = [
        NutritionDailyFocus(
            id: "protein_first",
            title: "今日重点：先把蛋白吃够",
            subtitle: "老年人常见问题不是吃太少主食，而是每餐蛋白太薄。",
            tips: ["早餐加 1 个鸡蛋或 1 杯奶/豆浆。", "午晚餐至少有一掌心鱼、禽、肉、蛋或豆制品。", "胃口差时先吃蛋白，再吃主食。"]
        ),
        NutritionDailyFocus(
            id: "salt_control",
            title: "今日重点：少盐但不寡淡",
            subtitle: "用香味替代咸味，血压和心血管负担更稳。",
            tips: ["少用咸菜、腊肉、火腿、浓汤底。", "用葱姜蒜、醋、香菇、番茄提味。", "酱油、蚝油也算盐，少量即可。"]
        ),
        NutritionDailyFocus(
            id: "stable_carbs",
            title: "今日重点：主食稳一点",
            subtitle: "主食不必取消，关键是份量和搭配。",
            tips: ["白米饭减到半碗，搭配杂粮、山药或红薯。", "少喝白粥和甜饮，饱得快但营养薄。", "糖尿病用户按医生建议监测血糖反应。"]
        ),
        NutritionDailyFocus(
            id: "soft_texture",
            title: "今日重点：软烂好咀嚼",
            subtitle: "吃得进去，比纸面上完美更重要。",
            tips: ["肉切小块、剁馅或做丸子。", "鱼去刺，豆腐、蛋羹、炖菜更友好。", "蔬菜煮软但别煮到完全没口感。"]
        )
    ]

    static let recipeSets: [SeniorRecipeSet] = [
        SeniorRecipeSet(
            id: "balanced_soft",
            title: "软烂均衡一日餐",
            tag: "牙口友好",
            meals: [
                SeniorRecipe(id: "egg_custard_breakfast", title: "鸡蛋羹早餐", tag: "早餐", items: "鸡蛋羹 + 无糖豆浆/牛奶 + 燕麦南瓜粥 + 焯青菜", notes: "粥里配蛋奶豆，比单喝白粥更有蛋白。"),
                SeniorRecipe(id: "fish_tofu_lunch", title: "鱼片豆腐午餐", tag: "午餐", items: "清蒸鱼片 + 番茄豆腐汤 + 半碗杂粮饭 + 两份时蔬", notes: "鱼肉去刺，豆腐补充优质蛋白。"),
                SeniorRecipe(id: "shrimp_yam_dinner", title: "虾仁山药晚餐", tag: "晚餐", items: "虾仁豆腐煲 + 山药/红薯 + 香菇青菜 + 少量水果", notes: "晚餐不过量，主食保留小份。")
            ]
        ),
        SeniorRecipeSet(
            id: "blood_pressure_friendly",
            title: "清淡控盐一日餐",
            tag: "少盐",
            meals: [
                SeniorRecipe(id: "milk_oat_breakfast", title: "牛奶燕麦早餐", tag: "早餐", items: "牛奶燕麦 + 水煮蛋 + 黄瓜/番茄", notes: "不加糖，坚果只放少量。"),
                SeniorRecipe(id: "chicken_mushroom_lunch", title: "香菇鸡肉午餐", tag: "午餐", items: "香菇蒸鸡 + 杂粮饭半碗 + 冬瓜海带汤 + 绿叶菜", notes: "靠香菇、葱姜提味，少放酱油。"),
                SeniorRecipe(id: "tomato_tofu_dinner", title: "番茄豆腐晚餐", tag: "晚餐", items: "番茄豆腐煲 + 清炒小白菜 + 红薯半个", notes: "避免咸菜、腊肉、浓汤底。")
            ]
        ),
        SeniorRecipeSet(
            id: "protein_boost",
            title: "蛋白优先一日餐",
            tag: "力量维护",
            meals: [
                SeniorRecipe(id: "double_protein_breakfast", title: "双蛋白早餐", tag: "早餐", items: "鸡蛋 + 无糖酸奶 + 小份全麦馒头 + 番茄", notes: "适合训练日，肾病用户不要自行加量。"),
                SeniorRecipe(id: "lean_pork_lunch", title: "瘦肉豆腐午餐", tag: "午餐", items: "瘦肉豆腐炖白菜 + 半碗米饭 + 蒸南瓜", notes: "瘦肉切薄片或剁碎，减少咀嚼负担。"),
                SeniorRecipe(id: "fish_soup_dinner", title: "鱼汤晚餐", tag: "晚餐", items: "鱼片青菜汤 + 山药 + 凉拌软豆腐", notes: "汤要少盐，重点吃鱼肉和豆腐，不只喝汤。")
            ]
        ),
        SeniorRecipeSet(
            id: "diabetes_care",
            title: "稳糖搭配一日餐",
            tag: "控碳",
            meals: [
                SeniorRecipe(id: "egg_veg_breakfast", title: "蛋菜早餐", tag: "早餐", items: "鸡蛋 + 无糖豆浆 + 小份燕麦 + 青菜", notes: "少喝稀粥，不用果汁替代水果。"),
                SeniorRecipe(id: "mixed_rice_lunch", title: "杂粮午餐", tag: "午餐", items: "杂粮饭半碗 + 清蒸鱼 + 菌菇青菜 + 番茄汤", notes: "先吃菜和蛋白，再吃主食。"),
                SeniorRecipe(id: "yam_dinner", title: "山药晚餐", tag: "晚餐", items: "山药小份 + 鸡肉丸汤 + 两份蔬菜", notes: "血糖异常者以医生或营养师建议为准。")
            ]
        )
    ]
}
