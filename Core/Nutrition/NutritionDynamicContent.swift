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

    var nutritionSummary: String {
        meals.map(\.nutritionEstimate).joined(separator: "；")
    }
}

struct SeniorRecipe: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let tag: String
    let items: String
    let notes: String
    let nutritionEstimate: String
}

enum NutritionDynamicContent {
    static let sourceNote = "内容依据《中国居民膳食指南(2022)》老年人膳食原则整理，并按常见食物成分做粗略估算。"

    static let dailyFocusCards: [NutritionDailyFocus] = makeDailyFocusCards()

    static let recipeSets: [SeniorRecipeSet] = makeRecipeSets()

    private static func makeDailyFocusCards() -> [NutritionDailyFocus] {
        let themes: [(String, String, [String])] = [
            ("蛋白优先", "老年人要重视鱼、禽、蛋、瘦肉、奶、大豆及其制品。", ["每餐先安排一份优质蛋白。", "牙口差时优先选择蛋羹、豆腐、鱼片、肉末。", "肾病用户不要自行增加蛋白总量。"]),
            ("食物多样", "每天尽量吃到 12 种以上食物，每周 25 种以上。", ["主食、蔬菜、蛋白、水果、奶豆都要出现。", "同类食物轮换，不长期只吃一两样。", "胃口差时少量多餐更容易做到多样。"]),
            ("控盐提味", "少盐不等于没味道，可用天然香味替代咸味。", ["少用咸菜、腊肉、火腿、浓汤底。", "用葱姜蒜、醋、番茄、香菇提味。", "酱油、蚝油、豆瓣酱也要计入盐。"]),
            ("稳住主食", "主食不必取消，关键是粗细搭配和份量。", ["白米饭可替换一部分为杂粮、燕麦、红薯、山药。", "糖尿病用户少喝粥和果汁。", "先吃菜和蛋白，再吃主食更稳。"]),
            ("蔬菜够量", "深色蔬菜、菌菇类能增加膳食纤维和微量营养素。", ["每餐尽量有一到两拳蔬菜。", "牙口差可切碎煮软，不必生吃。", "焯拌、清炒、炖汤都比重油更稳。"]),
            ("奶豆补钙", "奶类、大豆制品是老年人常用的蛋白和钙来源。", ["每天可安排牛奶、酸奶或无糖豆浆。", "豆腐、豆干、豆腐脑适合软食。", "乳糖不耐受可选低乳糖奶或酸奶。"]),
            ("饮水规律", "口渴感变弱时，也要主动少量多次饮水。", ["晨起、两餐之间、运动后少量饮水。", "心肾疾病限水者按医生要求。", "少用甜饮、浓茶、酒替代水。"]),
            ("软烂好入口", "能吃下去、吃得安全，比纸面完美更重要。", ["肉切薄片、剁馅或做丸子。", "鱼去刺，蔬菜切短煮软。", "避免太硬、太黏、太烫的食物。"]),
            ("少油烹调", "蒸、煮、炖、焯、快炒更适合日常长期坚持。", ["少做油炸、干锅、红烧重油菜。", "坚果虽好但脂肪高，一小把即可。", "汤面和汤粉要注意隐藏油盐。"]),
            ("加餐有营养", "加餐不是零食放开吃，而是补足当天薄弱项。", ["可选无糖酸奶、牛奶、鸡蛋、水果。", "饼干、糕点、糖果不适合作为常规加餐。", "晚间加餐宜少量，避免影响睡眠。"])
        ]

        let situations: [(String, String)] = [
            ("早餐", "把一天的蛋白和饮水开个好头。"),
            ("午餐", "保证能量和优质蛋白，不只吃主食。"),
            ("晚餐", "清淡但不要过度减少蛋白。"),
            ("训练日", "运动前后注意水分和蛋白补充。"),
            ("胃口差", "少量多餐，先吃高营养密度食物。"),
            ("牙口差", "把食材切小、煮软、去骨去刺。"),
            ("血压偏高", "重点减少盐和加工肉。"),
            ("血糖波动", "重点稳住主食份量和进餐顺序。"),
            ("便秘", "增加蔬菜、全谷薯类和饮水。"),
            ("外出就餐", "少汤汁、少酱料，优先清蒸炖煮。"),
            ("独居", "准备易保存又有蛋白的食物。")
        ]

        return situations.flatMap { situation in
            themes.map { theme in
                NutritionDailyFocus(
                    id: "\(situation.0)_\(theme.0)",
                    title: "今日重点：\(situation.0) · \(theme.0)",
                    subtitle: situation.1 + theme.1,
                    tips: theme.2
                )
            }
        }
    }

    private static func makeRecipeSets() -> [SeniorRecipeSet] {
        let breakfasts: [SeniorRecipe] = [
            recipe("egg_custard_oat", "鸡蛋羹燕麦早餐", "早餐", "鸡蛋羹 + 牛奶燕麦 + 焯青菜", "蛋羹软嫩，燕麦不额外加糖。", "约 420 kcal，蛋白 23g，碳水 48g，脂肪 14g"),
            recipe("soy_milk_bun", "豆浆馒头早餐", "早餐", "无糖豆浆 + 全麦馒头半个 + 水煮蛋 + 番茄", "适合常规早餐，主食不过量。", "约 390 kcal，蛋白 21g，碳水 50g，脂肪 11g"),
            recipe("fish_congee", "鱼片菜粥早餐", "早餐", "鱼片青菜粥 + 鸡蛋 + 小份水果", "粥里加鱼和蛋，避免只喝白粥。", "约 430 kcal，蛋白 26g，碳水 55g，脂肪 10g"),
            recipe("yogurt_yam", "酸奶山药早餐", "早餐", "无糖酸奶 + 蒸山药 + 鸡蛋 + 黄瓜", "山药按主食算，酸奶选低糖。", "约 360 kcal，蛋白 20g，碳水 42g，脂肪 10g"),
            recipe("tofu_brain", "豆腐脑软食早餐", "早餐", "少盐豆腐脑 + 鸡蛋 + 小花卷 + 青菜", "卤汁少盐，适合牙口一般者。", "约 410 kcal，蛋白 24g，碳水 46g，脂肪 13g"),
            recipe("milk_pumpkin", "牛奶南瓜早餐", "早餐", "牛奶 + 蒸南瓜 + 鸡蛋 + 少量坚果", "坚果少量即可，南瓜替代部分主食。", "约 380 kcal，蛋白 19g，碳水 40g，脂肪 16g"),
            recipe("shrimp_noodle", "虾仁汤面早餐", "早餐", "小份汤面 + 虾仁 + 青菜 + 鸡蛋", "汤少喝，面量控制。", "约 460 kcal，蛋白 28g，碳水 58g，脂肪 12g"),
            recipe("millet_egg", "小米蛋奶早餐", "早餐", "小米粥 + 牛奶 + 鸡蛋 + 拌菠菜", "小米粥搭配蛋奶，营养更完整。", "约 430 kcal，蛋白 22g，碳水 56g，脂肪 12g"),
            recipe("corn_soy", "玉米豆浆早餐", "早餐", "玉米半根 + 无糖豆浆 + 鸡蛋 + 番茄", "玉米当主食，不再叠加大量馒头。", "约 350 kcal，蛋白 19g，碳水 43g，脂肪 10g"),
            recipe("lean_pork_wonton", "瘦肉小馄饨早餐", "早餐", "瘦肉小馄饨 + 青菜 + 无糖酸奶", "汤底少盐，馄饨份量小。", "约 480 kcal，蛋白 27g，碳水 60g，脂肪 14g")
        ]

        let lunches: [SeniorRecipe] = [
            recipe("fish_tofu_lunch", "鱼片豆腐午餐", "午餐", "清蒸鱼片 + 番茄豆腐汤 + 半碗杂粮饭 + 青菜", "鱼肉去刺，豆腐补充优质蛋白。", "约 620 kcal，蛋白 42g，碳水 68g，脂肪 18g"),
            recipe("chicken_mushroom", "香菇蒸鸡午餐", "午餐", "香菇蒸鸡 + 杂粮饭 + 冬瓜汤 + 小白菜", "用香菇葱姜提味，少放酱油。", "约 650 kcal，蛋白 40g，碳水 72g，脂肪 19g"),
            recipe("lean_pork_tofu", "瘦肉豆腐午餐", "午餐", "瘦肉豆腐炖白菜 + 半碗米饭 + 蒸南瓜", "瘦肉切薄或剁碎，减少咀嚼负担。", "约 640 kcal，蛋白 38g，碳水 76g，脂肪 18g"),
            recipe("shrimp_egg", "虾仁蒸蛋午餐", "午餐", "虾仁蒸蛋 + 山药 + 菌菇青菜 + 少量米饭", "痛风或肾病用户按医嘱控制虾仁。", "约 600 kcal，蛋白 36g，碳水 66g，脂肪 17g"),
            recipe("beef_potato", "牛肉土豆午餐", "午餐", "番茄牛肉土豆 + 青菜 + 小份米饭", "土豆计入主食，红烧少油少盐。", "约 680 kcal，蛋白 39g，碳水 78g，脂肪 22g"),
            recipe("duck_winter_melon", "鸭肉冬瓜午餐", "午餐", "去皮鸭肉冬瓜汤 + 杂粮饭 + 拌菠菜", "重点吃肉和菜，汤少盐。", "约 620 kcal，蛋白 35g，碳水 70g，脂肪 20g"),
            recipe("eggplant_minced", "肉末茄子午餐", "午餐", "少油肉末茄子 + 米饭半碗 + 番茄蛋汤 + 青菜", "茄子吸油，先蒸后拌更稳。", "约 660 kcal，蛋白 33g，碳水 82g，脂肪 20g"),
            recipe("tofu_mushroom", "菌菇豆腐午餐", "午餐", "菌菇豆腐煲 + 鸡蛋 + 红薯 + 绿叶菜", "适合软食，肾病用户按医嘱控豆制品。", "约 590 kcal，蛋白 31g，碳水 68g，脂肪 18g"),
            recipe("steamed_meatball", "清蒸肉丸午餐", "午餐", "清蒸瘦肉丸 + 冬瓜海带 + 杂粮饭 + 青菜", "肉丸比整块肉更易咀嚼。", "约 670 kcal，蛋白 40g，碳水 74g，脂肪 21g"),
            recipe("chicken_noodle", "鸡丝荞麦面午餐", "午餐", "鸡丝荞麦面 + 青菜 + 豆腐干", "面量适中，先吃菜和鸡丝。", "约 640 kcal，蛋白 38g，碳水 80g，脂肪 16g")
        ]

        let dinners: [SeniorRecipe] = [
            recipe("tomato_tofu", "番茄豆腐晚餐", "晚餐", "番茄豆腐煲 + 清炒小白菜 + 红薯半个", "清淡但保留蛋白，不只吃粥。", "约 430 kcal，蛋白 22g，碳水 50g，脂肪 14g"),
            recipe("fish_soup", "鱼片青菜晚餐", "晚餐", "鱼片青菜汤 + 山药 + 凉拌软豆腐", "汤少盐，重点吃鱼肉和豆腐。", "约 470 kcal，蛋白 34g，碳水 43g，脂肪 15g"),
            recipe("chicken_meatball", "鸡肉丸晚餐", "晚餐", "鸡肉丸汤 + 两份蔬菜 + 小份杂粮饭", "肉丸做小，避免太硬。", "约 520 kcal，蛋白 36g，碳水 55g，脂肪 16g"),
            recipe("egg_spinach", "菠菜鸡蛋晚餐", "晚餐", "菠菜鸡蛋汤 + 蒸南瓜 + 豆腐", "菠菜可先焯水，口感更软。", "约 420 kcal，蛋白 25g，碳水 46g，脂肪 14g"),
            recipe("pork_cabbage", "白菜瘦肉晚餐", "晚餐", "白菜瘦肉炖粉条少量 + 青菜 + 小份米饭", "粉条和米饭都算主食，二选一为主。", "约 540 kcal，蛋白 30g，碳水 68g，脂肪 16g"),
            recipe("shrimp_tofu", "虾仁豆腐晚餐", "晚餐", "虾仁豆腐煲 + 西兰花 + 山药", "虾仁去壳切小，少盐。", "约 500 kcal，蛋白 35g，碳水 48g，脂肪 15g"),
            recipe("mushroom_egg", "菌菇蛋花晚餐", "晚餐", "菌菇蛋花汤 + 红薯 + 拌豆腐 + 青菜", "适合胃口一般的晚餐。", "约 450 kcal，蛋白 26g，碳水 52g，脂肪 13g"),
            recipe("steamed_egg_fish", "鱼肉蒸蛋晚餐", "晚餐", "鱼肉蒸蛋 + 软烂青菜 + 小份杂粮饭", "鱼去刺后再蒸蛋。", "约 480 kcal，蛋白 33g，碳水 48g，脂肪 16g"),
            recipe("beef_radish", "萝卜牛肉晚餐", "晚餐", "萝卜牛肉汤 + 青菜 + 小份米饭", "牛肉炖软，汤少盐少油。", "约 560 kcal，蛋白 35g，碳水 56g，脂肪 18g"),
            recipe("soybean_sprout", "豆芽肉丝晚餐", "晚餐", "豆芽肉丝 + 番茄汤 + 蒸玉米半根", "玉米替代主食，肉丝切细。", "约 500 kcal，蛋白 30g，碳水 58g，脂肪 15g")
        ]

        var sets: [SeniorRecipeSet] = []
        for index in 0..<50 {
            let breakfast = breakfasts[index % breakfasts.count]
            let lunch = lunches[(index * 3 + 1) % lunches.count]
            let dinner = dinners[(index * 5 + 2) % dinners.count]
            let tags = ["均衡", "少盐", "软食", "控碳", "高蛋白", "牙口友好", "训练日"]
            sets.append(
                SeniorRecipeSet(
                    id: "senior_day_\(index + 1)",
                    title: "老年友好一日餐 \(index + 1)",
                    tag: tags[index % tags.count],
                    meals: [breakfast, lunch, dinner]
                )
            )
        }
        return sets
    }

    private static func recipe(
        _ id: String,
        _ title: String,
        _ tag: String,
        _ items: String,
        _ notes: String,
        _ nutritionEstimate: String
    ) -> SeniorRecipe {
        SeniorRecipe(
            id: id,
            title: title,
            tag: tag,
            items: items,
            notes: notes,
            nutritionEstimate: nutritionEstimate
        )
    }
}
