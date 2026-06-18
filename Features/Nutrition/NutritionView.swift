import SwiftUI

/// Nutrition advice screen showing protein targets, food lists,
/// carb tips, and sample meal plans.
struct NutritionView: View {

    @StateObject private var viewModel = NutritionViewModel()
    @State private var showAddDietEntry = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isRedFlag {
                        redFlagBanner
                    }

                    if let advice = viewModel.advice {
                        dietTrackingSection
                        nutritionTodayCard(advice)
                        chineseRecipeSection
                        healthSwapSection(advice)
                        if let req = advice.requirements {
                            nutritionRequirementsCard(req)
                        }
                        nutritionBasicsSection(advice)
                        foodChoiceSection(advice)
                        postWorkoutTip(advice)
                        disclaimerSection(advice)
                    } else if viewModel.isLoading {
                        ProgressView("加载中...")
                            .frame(minHeight: 200)
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color.vbCream.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .task { await viewModel.loadAdvice() }
            .sheet(isPresented: $showAddDietEntry) {
                AddDietEntryView(
                    commonFoods: viewModel.commonFoodOptions,
                    recentEntries: viewModel.recentDietEntries,
                    onSaveFood: { food, mealType, servings in
                        viewModel.addFoodPortion(food, mealType: mealType, servings: servings)
                        showAddDietEntry = false
                    }, onRepeatEntry: { entry in
                        viewModel.repeatDietEntry(entry)
                        showAddDietEntry = false
                    }, onRepeatYesterdayMeal: { mealType in
                        viewModel.repeatYesterdayMeal(mealType)
                        showAddDietEntry = false
                    }, onSaveCustom: { mealType, foodName, grams, protein, carbs, fat in
                        viewModel.addDietEntry(
                            mealType: mealType,
                            foodName: foodName,
                            grams: grams,
                            proteinPer100g: protein,
                            carbsPer100g: carbs,
                            fatPer100g: fat
                        )
                        showAddDietEntry = false
                    })
            }
        }
    }

    // MARK: - Red Flag Banner

    private var redFlagBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.vbWarning)
                .font(.system(size: 24))
            Text("您的健康评估结果为红旗禁止，建议咨询医生后再开始运动")
                .vbBody()
                .foregroundStyle(Color.vbWarning)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbWarning.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Nutrition Requirements

    private func nutritionRequirementsCard(_ req: NutritionRequirements) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "flame.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.vbAccent)
                Text("每日营养需求")
                    .vbHeadline()
                Spacer()
                Text("BMR \(req.bmr) kcal")
                    .vbCaption()
            }

            // Calorie target
            HStack {
                Text("总热量")
                    .vbBody()
                Spacer()
                Text("\(req.tdee)")
                    .font(VBFont.title)
                    .foregroundStyle(Color.vbAccent)
                Text("kcal/天")
                    .vbCaption()
            }

            Divider()

            // Macro breakdown
            HStack(spacing: 0) {
                macroItem(label: "蛋白质", value: "\(req.proteinG)g", color: .vbAccent)
                macroItem(label: "碳水", value: "\(req.carbsG)g", color: .vbDistantMountain)
                macroItem(label: "脂肪", value: "\(req.fatG)g", color: .vbSuccess)
            }

            // Water
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.blue)
                Text("饮水")
                    .vbBody()
                Spacer()
                Text("\(req.waterML) ml")
                    .font(VBFont.headline)
                    .foregroundStyle(.blue)
            }

            // Adjustments
            if !req.adjustments.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(req.adjustments, id: \.self) { adj in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(Color.vbWarning)
                                .font(.system(size: 14))
                                .padding(.top, 2)
                            Text(adj)
                                .vbCaption()
                                .foregroundStyle(Color.vbSecondaryText)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func macroItem(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(VBFont.headline)
                .foregroundStyle(color)
            Text(label)
                .vbCaption()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Senior Plate

    private var seniorPlateSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "circle.grid.cross.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.vbAccent)
                Text("老年友好餐盘")
                    .vbHeadline()
                Spacer()
                Text("每餐参考")
                    .vbCaption()
                    .foregroundStyle(Color.vbSecondaryText)
            }

            HStack(spacing: 10) {
                platePortion(title: "1/2", subtitle: "蔬菜 + 少量水果", color: Color.vbSuccess)
                platePortion(title: "1/4", subtitle: "鱼禽蛋奶豆", color: Color.vbAccent)
                platePortion(title: "1/4", subtitle: "全谷薯类主食", color: Color.vbDistantMountain)
            }

            VStack(alignment: .leading, spacing: 8) {
                compactTip("每天尽量吃到 12 种以上食物，每周 25 种以上。")
                compactTip("少盐少油，优先蒸、煮、炖、焯，少煎炸和重口味酱料。")
                compactTip("牙口差时，把肉切碎、鱼去刺、蔬菜煮软，保留营养也更好入口。")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func platePortion(title: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(VBFont.headline)
                .foregroundStyle(color)
            Text(subtitle)
                .vbCaption()
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.vbSecondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.86)
        }
        .frame(maxWidth: .infinity, minHeight: 76)
        .padding(8)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func compactTip(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.vbSuccess)
                .padding(.top, 2)
            Text(text)
                .vbCaption()
                .foregroundStyle(Color.vbSecondaryText)
        }
    }

    // MARK: - Diet Tracking

    private var dietTrackingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.clipboard.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.vbAccent)
                Text("饮食记录与分析")
                    .vbHeadline()
                Spacer()
                Button {
                    showAddDietEntry = true
                } label: {
                    Label("添加食物", systemImage: "plus")
                        .font(VBFont.body)
                }
                .foregroundStyle(Color.vbAccent)
                .frame(minHeight: 44)
            }

            if let analysis = viewModel.dietAnalysis {
                dietAnalysisCard(analysis)
            } else {
                missingWeightCard
            }

            if let notice = viewModel.dietNotice {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.vbSuccess)
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.top, 2)
                    Text(notice)
                        .font(VBFont.caption)
                        .foregroundStyle(Color.vbSecondaryText)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.vbSuccess.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            if viewModel.dietEntries.isEmpty {
                Text("还没有记录。可以直接选择鸡蛋、牛奶、米饭、鱼肉等常见食物，系统会按份数自动估算蛋白质、碳水和脂肪。")
                    .vbBody()
                    .foregroundStyle(Color.vbSecondaryText)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.dietEntries) { entry in
                        dietEntryRow(entry)
                    }
                }
            }

            Text("饮食分析仅用于日常记录和估算，不构成医学建议；肾病、糖尿病、心血管疾病或体重快速变化时，请以医生或营养师意见为准。")
                .vbCaption()
                .foregroundStyle(Color.vbWarning)
                .padding(.top, 2)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func dietAnalysisCard(_ analysis: DietMacroAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                macroSummaryValue(label: "热量", value: "\(analysis.summary.calories)", unit: "kcal")
                macroSummaryValue(label: "蛋白质", value: formatGrams(analysis.summary.proteinG), unit: "g")
                macroSummaryValue(label: "碳水", value: formatGrams(analysis.summary.carbsG), unit: "g")
                macroSummaryValue(label: "脂肪", value: formatGrams(analysis.summary.fatG), unit: "g")
            }

            ForEach(analysis.nutrients, id: \.name) { nutrient in
                macroAnalysisRow(nutrient)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("下一餐参考")
                    .font(VBFont.caption)
                    .foregroundStyle(Color.vbSecondaryText)
                Text(macroGapText(analysis))
                    .font(VBFont.body)
                    .foregroundStyle(Color.vbMainText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.vbCardBackground.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(analysis.message)
                .vbBody()
                .foregroundStyle(Color.vbSecondaryText)
        }
        .padding(14)
        .background(Color.vbSurfaceVariant.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var missingWeightCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "scalemass")
                .foregroundStyle(Color.vbAccent)
                .font(.system(size: 22))
            Text("录入或同步体重后，可按评估结果计算每日目标，并分析今日摄入是否匹配。")
                .vbBody()
                .foregroundStyle(Color.vbSecondaryText)
        }
        .padding(14)
        .background(Color.vbSurfaceVariant.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func macroSummaryValue(label: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .vbCaption()
                .foregroundStyle(Color.vbSecondaryText)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(VBFont.headline)
                    .foregroundStyle(Color.vbMainText)
                Text(unit)
                    .vbCaption()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func macroAnalysisRow(_ nutrient: MacroNutrientAnalysis) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(nutrient.name)
                    .vbBody()
                Text("\(formatGrams(nutrient.actualG))g / 目标 \(nutrient.targetG)g")
                    .vbCaption()
                    .foregroundStyle(Color.vbSecondaryText)
            }
            Spacer()
            Text(nutrient.status.displayName)
                .font(VBFont.caption)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(statusColor(nutrient.status))
                .clipShape(Capsule())
        }
    }

    private func macroGapText(_ analysis: DietMacroAnalysis) -> String {
        let gaps = analysis.nutrients.compactMap { nutrient -> String? in
            let delta = Double(nutrient.targetG) - nutrient.actualG
            if delta > 5 {
                return "\(nutrient.name)还差约 \(formatGrams(delta))g"
            }
            if delta < -5 {
                return "\(nutrient.name)已超约 \(formatGrams(abs(delta)))g"
            }
            return nil
        }

        if gaps.isEmpty {
            return "今天主要营养基本贴近目标，下一餐保持清淡均衡即可。"
        }
        return gaps.joined(separator: "，") + "。"
    }

    private func dietEntryRow(_ entry: DietLogEntry) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.foodName)
                    .vbBody()
                Text("\(entry.mealType.displayName) · \(formatGrams(entry.grams))g · 蛋白 \(formatGrams(entry.proteinG))g / 碳水 \(formatGrams(entry.carbsG))g / 脂肪 \(formatGrams(entry.fatG))g")
                    .vbCaption()
                    .foregroundStyle(Color.vbSecondaryText)
                    .lineLimit(2)
            }
            Spacer()
            Button {
                viewModel.deleteDietEntry(entry)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.vbWarning)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("删除 \(entry.foodName)")
        }
        .padding(12)
        .background(Color.vbCream.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func statusColor(_ status: MacroStatus) -> Color {
        switch status {
        case .low: return Color.vbWarning
        case .onTrack: return Color.vbSuccess
        case .high: return Color.orange
        }
    }

    private func formatGrams(_ value: Double) -> String {
        if value.rounded() == value {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }

    private func nutritionTodayCard(_ advice: NutritionAdvice) -> some View {
        let focus = viewModel.currentDailyFocus

        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("「\(advice.randomQuote)」")
                        .font(VBFont.headline)
                        .foregroundStyle(Color.vbAccent)
                        .italic()

                    Text(focus.title)
                        .font(VBFont.title)
                        .foregroundStyle(Color.vbMainText)

                    Text(focus.subtitle)
                        .vbBody()
                        .foregroundStyle(Color.vbSecondaryText)
                }

                Spacer()

                Button {
                    viewModel.refreshDailyNutritionContent()
                } label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.vbAccent)
                        .frame(width: 48, height: 48)
                }
                .accessibilityLabel("换一组饮食建议")
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(focus.tips, id: \.self) { tip in
                    compactTip(tip)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func motivationalQuote(_ quote: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Text("「\(quote)」")
                    .font(VBFont.headline)
                    .foregroundStyle(Color.vbAccent)
                    .italic()

                Spacer()

                Button {
                    viewModel.refreshQuote()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.vbAccent)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("换一句")
            }

        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Chinese Recipes

    private var chineseRecipeSection: some View {
        let recipeSet = viewModel.currentRecipeSet

        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "menucard.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.vbAccent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("一日膳食参考")
                        .vbHeadline()
                    Text(recipeSet.title)
                        .vbCaption()
                        .foregroundStyle(Color.vbSecondaryText)
                }
                Spacer()
                Button {
                    viewModel.refreshDailyNutritionContent()
                } label: {
                    Label("换一套", systemImage: "arrow.triangle.2.circlepath")
                        .font(VBFont.caption)
                        .foregroundStyle(Color.vbAccent)
                }
                .frame(minHeight: 36)
            }

            Text(recipeSet.nutritionSummary)
                .font(VBFont.caption)
                .foregroundStyle(Color.vbAccent)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(recipeSet.meals) { recipe in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(recipe.title)
                            .font(VBFont.headline)
                            .foregroundStyle(Color.vbMainText)
                        Spacer()
                        Text(recipe.tag)
                            .vbCaption()
                            .foregroundStyle(Color.vbAccent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.vbAccent.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    Text(recipe.items)
                        .vbBody()
                        .foregroundStyle(Color.vbMainText)

                    Text(recipe.notes)
                        .vbCaption()
                        .foregroundStyle(Color.vbSecondaryText)

                    Text(recipe.nutritionEstimate)
                        .vbCaption()
                        .foregroundStyle(Color.vbAccent)
                }
                .padding(12)
                .background(Color.vbSurfaceVariant.opacity(0.48))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            Text(NutritionDynamicContent.sourceNote + " 营养值会随食材重量和烹调方式变化。")
                .vbCaption()
                .foregroundStyle(Color.vbSecondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func healthSwapSection(_ advice: NutritionAdvice) -> some View {
        let swaps = healthAwareSwaps(advice)

        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.vbAccent)
                Text("按健康状态微调")
                    .vbHeadline()
            }

            ForEach(swaps, id: \.self) { swap in
                compactTip(swap)
            }

            Text("这些是日常选择提醒，不替代医生、营养师给出的疾病饮食处方。")
                .vbCaption()
                .foregroundStyle(Color.vbWarning)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func healthAwareSwaps(_ advice: NutritionAdvice) -> [String] {
        var swaps = [
            "胃口差时先保证优质蛋白：鸡蛋羹、鱼片粥、豆腐汤、无糖酸奶都比只喝白粥更稳。",
            "血压或心血管风险高时，少用咸菜、腊肉、火腿、浓汤底，改用葱姜蒜、醋、香菇提味。",
            "便秘或活动少时，把白米饭的一部分换成燕麦、杂粮、红薯，并搭配绿叶菜和足量饮水。"
        ]

        if advice.hasDiabetes {
            swaps.insert("糖尿病用户把主食分散到三餐，优先杂粮饭、荞麦面、山药，少喝粥和果汁。", at: 0)
        }

        if advice.ckdTier.level != .none {
            swaps.insert("肾病用户不要自行高蛋白增肌，蛋白总量和豆制品、奶类、肉类份量按医生建议调整。", at: 0)
        }

        return swaps
    }

    // MARK: - Nutrition Basics

    private func nutritionBasicsSection(_ advice: NutritionAdvice) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "circle.grid.cross.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.vbAccent)
                Text("基础原则与蛋白目标")
                    .vbHeadline()
                Spacer()
                Text("低优先级参考")
                    .vbCaption()
                    .foregroundStyle(Color.vbSecondaryText)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("每日蛋白质目标")
                    .vbCaption()
                    .foregroundStyle(Color.vbSecondaryText)
                Text(advice.proteinTarget)
                .font(VBFont.headline)
                .foregroundStyle(Color.vbAccent)
                Text(advice.ckdTier.description)
                    .vbCaption()
                    .foregroundStyle(Color.vbSecondaryText)
            }

            HStack(spacing: 10) {
                platePortion(title: "1/2", subtitle: "蔬菜 + 少量水果", color: Color.vbSuccess)
                platePortion(title: "1/4", subtitle: "鱼禽蛋奶豆", color: Color.vbAccent)
                platePortion(title: "1/4", subtitle: "全谷薯类主食", color: Color.vbDistantMountain)
            }

            VStack(alignment: .leading, spacing: 8) {
                compactTip("每天尽量吃到 12 种以上食物，每周 25 种以上。")
                compactTip("少盐少油，优先蒸、煮、炖、焯，少煎炸和重口味酱料。")
                compactTip("牙口差时，把肉切碎、鱼去刺、蔬菜煮软。")
                compactTip("肾脏健康等级：\(advice.ckdTier.label)，\(advice.ckdTier.proteinRange) \(advice.ckdTier.proteinUnit)。")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Food Choices

    private func foodChoiceSection(_ advice: NutritionAdvice) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.vbAccent)
                Text("常见食物与替换")
                    .vbHeadline()
            }

            ForEach(advice.preferredFoods) { food in
                HStack {
                    Text(rankBadge(food.rank))
                        .font(VBFont.headline)
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.vbAccent)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(food.name)
                            .vbBody()
                        Text(food.notes)
                            .vbCaption()
                    }

                    Spacer()

                    Text(food.proteinPer100g)
                        .font(VBFont.headline)
                        .foregroundStyle(Color.vbAccent)
                    Text("/100g")
                        .vbCaption()
                }
                .padding(.vertical, 4)

                if food.id != advice.preferredFoods.last?.id {
                    Divider()
                }
            }

            Divider()

            ForEach(advice.carbTips, id: \.avoid) { tip in
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 4) {
                        Text("避免")
                            .vbCaption()
                            .foregroundStyle(Color.vbWarning)
                        Text(tip.avoid)
                            .vbBody()
                            .foregroundStyle(Color.vbWarning)
                            .strikethrough()
                    }
                    .frame(maxWidth: .infinity)

                    Image(systemName: "arrow.right")
                        .foregroundStyle(Color.vbSecondaryText)
                        .padding(.top, 16)

                    VStack(spacing: 4) {
                        Text("替换为")
                            .vbCaption()
                            .foregroundStyle(Color.vbSuccess)
                        Text(tip.replace)
                            .vbBody()
                            .foregroundStyle(Color.vbSuccess)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(12)
                .background(Color.vbCardBackground.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func rankBadge(_ rank: Int) -> String {
        switch rank {
        case 1: return "1"
        case 2: return "2"
        case 3: return "3"
        default: return "\(rank)"
        }
    }

    // MARK: - Post-Workout Tip

    private func postWorkoutTip(_ advice: NutritionAdvice) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.vbAccent)
            Text(advice.postWorkoutTip)
                .vbBody()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbAccent.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Disclaimer

    private func disclaimerSection(_ advice: NutritionAdvice) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .foregroundStyle(Color.vbWarning)
                Text("免责声明")
                    .vbCaption()
                    .foregroundStyle(Color.vbWarning)
            }
            Text(advice.disclaimer)
                .vbCaption()
                .foregroundStyle(Color.vbSecondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbWarning.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 100)
            Image(systemName: "leaf.circle")
                .font(.system(size: 64))
                .foregroundStyle(Color.vbSecondaryText)
            Text("请先完成健康评估")
                .vbHeadline()
                .foregroundStyle(Color.vbSecondaryText)
            Text("完成评估后可获取个性化饮食建议")
                .vbBody()
                .foregroundStyle(Color.vbSecondaryText)
            Spacer(minLength: 100)
        }
    }
}

private struct AddDietEntryView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var mealType: MealType = .breakfast
    @State private var selectedFoodID: String
    @State private var servings = "1"
    @State private var useCustomInput = false
    @State private var foodName = ""
    @State private var grams = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""

    let commonFoods: [CommonFoodPortion]
    let recentEntries: [DietLogEntry]
    let onSaveFood: (CommonFoodPortion, MealType, Double) -> Void
    let onRepeatEntry: (DietLogEntry) -> Void
    let onRepeatYesterdayMeal: (MealType) -> Void
    let onSaveCustom: (MealType, String, Double, Double, Double, Double) -> Void

    init(
        commonFoods: [CommonFoodPortion],
        recentEntries: [DietLogEntry],
        onSaveFood: @escaping (CommonFoodPortion, MealType, Double) -> Void,
        onRepeatEntry: @escaping (DietLogEntry) -> Void,
        onRepeatYesterdayMeal: @escaping (MealType) -> Void,
        onSaveCustom: @escaping (MealType, String, Double, Double, Double, Double) -> Void
    ) {
        self.commonFoods = commonFoods
        self.recentEntries = recentEntries
        self.onSaveFood = onSaveFood
        self.onRepeatEntry = onRepeatEntry
        self.onRepeatYesterdayMeal = onRepeatYesterdayMeal
        self.onSaveCustom = onSaveCustom
        _selectedFoodID = State(initialValue: commonFoods.first?.id ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("手动输入营养", isOn: $useCustomInput)
                } footer: {
                    Text("优先使用常见食物估算。包装食品或特殊食物再手动输入。")
                }

                if !useCustomInput {
                    recentFoodSection
                    repeatYesterdaySection
                    quickFoodSection
                }

                if useCustomInput {
                    customFoodSection
                }
            }
            .navigationTitle("记录饮食")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedFoodID) { _, _ in
                if let food = selectedFood {
                    mealType = food.defaultMealType
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .font(VBFont.body)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if useCustomInput {
                            onSaveCustom(
                                mealType,
                                foodName,
                                parsed(grams),
                                parsed(protein),
                                parsed(carbs),
                                parsed(fat)
                            )
                        } else if let food = selectedFood {
                            onSaveFood(food, mealType, parsed(servings))
                        }
                    }
                    .font(VBFont.body)
                    .disabled(!canSave)
                }
            }
        }
    }

    @ViewBuilder
    private var recentFoodSection: some View {
        if !recentEntries.isEmpty {
            Section("最近常吃") {
                ForEach(recentEntries.prefix(5)) { entry in
                    Button {
                        onRepeatEntry(entry)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(entry.foodName)
                                    .foregroundStyle(Color.vbMainText)
                                Text("\(entry.mealType.displayName) · \(formatGrams(entry.grams))g · 蛋白 \(formatGrams(entry.proteinG))g")
                                    .font(VBFont.caption)
                                    .foregroundStyle(Color.vbSecondaryText)
                            }
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color.vbAccent)
                        }
                    }
                }
            }
        }
    }

    private var repeatYesterdaySection: some View {
        Section {
            Picker("复制昨天的", selection: $mealType) {
                ForEach(MealType.allCases) { meal in
                    Text(meal.displayName).tag(meal)
                }
            }

            Button {
                onRepeatYesterdayMeal(mealType)
            } label: {
                Label("添加昨天\(mealType.displayName)", systemImage: "clock.arrow.circlepath")
                    .foregroundStyle(Color.vbAccent)
            }
        } header: {
            Text("快速复制")
        } footer: {
            Text("如果昨天这一餐没有记录，返回后会在饮食页提示。")
        }
    }

    @ViewBuilder
    private var quickFoodSection: some View {
        Group {
            Section("常见食物") {
                Picker("食物", selection: $selectedFoodID) {
                    ForEach(commonFoods) { food in
                        Text(food.name).tag(food.id)
                    }
                }

                Picker("餐次", selection: $mealType) {
                    ForEach(MealType.allCases) { meal in
                        Text(meal.displayName).tag(meal)
                    }
                }

                TextField("份数，例如 1 或 0.5", text: $servings)
                    .keyboardType(.decimalPad)
            }

            if let food = selectedFood {
                Section {
                    nutrientPreview(food)
                } header: {
                    Text("自动估算")
                } footer: {
                    Text(food.note + " 营养值为常见食物估算，实际以食材和烹调方式为准。")
                }
            }
        }
    }

    @ViewBuilder
    private var customFoodSection: some View {
        Group {
            Section("食物") {
                Picker("餐次", selection: $mealType) {
                    ForEach(MealType.allCases) { meal in
                        Text(meal.displayName).tag(meal)
                    }
                }

                TextField("食物名称，例如 鸡蛋", text: $foodName)
                TextField("食用重量 g，例如 100", text: $grams)
                    .keyboardType(.decimalPad)
            }

            Section("每 100g 营养") {
                TextField("蛋白质 g，例如 13", text: $protein)
                    .keyboardType(.decimalPad)
                TextField("碳水 g，例如 1.1", text: $carbs)
                    .keyboardType(.decimalPad)
                TextField("脂肪 g，例如 10", text: $fat)
                    .keyboardType(.decimalPad)
            }

            Section {
                Text("可参考食品包装营养成分表或常见食物数据库填写。结果为估算值，不构成医学建议。")
                    .font(VBFont.body)
                    .foregroundStyle(Color.vbSecondaryText)
            }
        }
    }

    private func nutrientPreview(_ food: CommonFoodPortion) -> some View {
        let count = parsed(servings)
        let grams = food.gramsPerServing * max(count, 0)
        let protein = grams * food.proteinPer100g / 100
        let carbs = grams * food.carbsPer100g / 100
        let fat = grams * food.fatPer100g / 100

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(food.servingName)约 \(formatGrams(food.gramsPerServing))g")
                    .font(VBFont.headline)
                Spacer()
                Text("共 \(formatGrams(grams))g")
                    .vbCaption()
                    .foregroundStyle(Color.vbSecondaryText)
            }

            HStack(spacing: 12) {
                previewMacro("蛋白", protein)
                previewMacro("碳水", carbs)
                previewMacro("脂肪", fat)
            }
        }
    }

    private func previewMacro(_ label: String, _ value: Double) -> some View {
        VStack(spacing: 4) {
            Text(formatGrams(value))
                .font(VBFont.headline)
                .foregroundStyle(Color.vbAccent)
            Text(label + "g")
                .font(VBFont.caption)
                .foregroundStyle(Color.vbSecondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var selectedFood: CommonFoodPortion? {
        commonFoods.first { $0.id == selectedFoodID }
    }

    private var canSave: Bool {
        if useCustomInput {
            return !foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && parsed(grams) > 0
        }
        return selectedFood != nil && parsed(servings) > 0
    }

    private func parsed(_ text: String) -> Double {
        Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private func formatGrams(_ value: Double) -> String {
        if value.rounded() == value {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }
}

// MARK: - Preview

#Preview("Nutrition View") {
    NutritionView()
}
