import Foundation

/// ViewModel for the nutrition advice screen.
@MainActor
final class NutritionViewModel: ObservableObject {

    @Published var advice: NutritionAdvice?
    @Published var isLoading: Bool = false
    @Published var isRedFlag: Bool = false
    @Published var dietEntries: [DietLogEntry] = []
    @Published var dietAnalysis: DietMacroAnalysis?

    private let assessmentService: AssessmentService
    private let healthKitService: HealthKitService
    private let dietStore: DietRecordStore

    init(
        assessmentService: AssessmentService = AssessmentService(),
        healthKitService: HealthKitService = HealthKitService(),
        dietStore: DietRecordStore = DietRecordStore()
    ) {
        self.assessmentService = assessmentService
        self.healthKitService = healthKitService
        self.dietStore = dietStore
    }

    func loadAdvice() async {
        isLoading = true
        defer { isLoading = false }

        guard let assessment = assessmentService.loadLatestAssessment() else {
            return
        }

        isRedFlag = assessment.riskLevel == .redFlag
        await healthKitService.refreshAll()
        let weight = healthKitService.todaySummary?.weight

        guard let content = NutritionContentLoader.load() else {
            advice = NutritionAdvisor.recommend(
                for: assessment,
                content: NutritionContentLoader.sampleAdvice,
                weightKG: weight
            )
            reloadDietEntries()
            return
        }

        advice = NutritionAdvisor.recommend(for: assessment, content: content, weightKG: weight)
        reloadDietEntries()
    }

    func refreshQuote() {
        guard let current = advice else { return }
        let content = NutritionContentLoader.load() ?? NutritionContentLoader.sampleAdvice
        let newQuote = content.motivationalQuotes.randomElement() ?? "加油！"
        advice = NutritionAdvice(
            ckdTier: current.ckdTier,
            proteinTarget: current.proteinTarget,
            preferredFoods: current.preferredFoods,
            carbTips: current.carbTips,
            sampleMeal: current.sampleMeal,
            disclaimer: current.disclaimer,
            postWorkoutTip: current.postWorkoutTip,
            hasDiabetes: current.hasDiabetes,
            randomQuote: newQuote,
            requirements: current.requirements
        )
    }

    func addDietEntry(
        mealType: MealType,
        foodName: String,
        grams: Double,
        proteinPer100g: Double,
        carbsPer100g: Double,
        fatPer100g: Double
    ) {
        let trimmedName = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, grams > 0 else { return }

        let entry = DietLogEntry(
            mealType: mealType,
            foodName: trimmedName,
            grams: grams,
            proteinPer100g: max(proteinPer100g, 0),
            carbsPer100g: max(carbsPer100g, 0),
            fatPer100g: max(fatPer100g, 0)
        )
        dietStore.addEntry(entry)
        reloadDietEntries()
    }

    func deleteDietEntry(_ entry: DietLogEntry) {
        dietStore.deleteEntry(id: entry.id)
        reloadDietEntries()
    }

    func reloadDietEntries() {
        dietEntries = dietStore.loadEntries()
        if let requirements = advice?.requirements {
            dietAnalysis = DietAnalyzer.analyze(entries: dietEntries, requirements: requirements)
        } else {
            dietAnalysis = nil
        }
    }
}
