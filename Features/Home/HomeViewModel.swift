import Foundation

/// ViewModel for the home dashboard.
final class HomeViewModel: ObservableObject {

    @Published var todayPlan: TrainingPlan?
    @Published var assessment: AssessmentResult?
    @Published var streak: Int = 0
    @Published var healthSummary: DailySummary?
    @Published var healthKitStatus: HealthKitPermissionStatus = .notDetermined
    @Published var recentCheckins: [DailyCheckin] = []
    @Published var latestFeedback: TrainingFeedback?

    private let planService = TrainingPlanService()
    private let recordStore = TrainingRecordStore.shared
    private let feedbackStore = TrainingFeedbackStore()
    private let healthKitService: HealthKitService
    private let permissionManager: HealthKitPermissionManager
    private let assessmentService: AssessmentService

    init(
        healthKitService: HealthKitService = HealthKitService(),
        permissionManager: HealthKitPermissionManager = HealthKitPermissionManager(),
        assessmentService: AssessmentService = AssessmentService()
    ) {
        self.healthKitService = healthKitService
        self.permissionManager = permissionManager
        self.assessmentService = assessmentService
    }

    // MARK: - Data Loading

    func loadAll() async {
        await loadTodayPlan()
        await loadStreak()
        await loadRecentCheckins()
        await refreshHealthData()
        await MainActor.run {
            latestFeedback = feedbackStore.latest()
        }
    }

    func loadTodayPlan() async {
        let assessment = assessmentService.loadLatestAssessment()
        let plan: TrainingPlan?
        if assessment?.riskLevel == .redFlag {
            plan = nil
        } else {
            let level = assessment?.fitnessLevel ?? .L1
            plan = planService.loadOrCreateDailyPlan(for: level)
        }
        await MainActor.run {
            self.assessment = assessment
            todayPlan = plan
        }
    }

    func refreshHealthData() async {
        await MainActor.run {
            healthKitStatus = permissionManager.checkCurrentStatus()
        }
        await healthKitService.refreshAll()
        await MainActor.run {
            healthSummary = healthKitService.todaySummary
        }
    }

    func forceRefreshHealthData() async {
        await healthKitService.refreshAll(force: true)
        await MainActor.run {
            healthSummary = healthKitService.todaySummary
            healthKitStatus = permissionManager.checkCurrentStatus()
        }
    }

    func requestHealthKit() async {
        let status = await permissionManager.requestAuthorization()
        await MainActor.run {
            healthKitStatus = status
        }
        if status == .authorized {
            await forceRefreshHealthData()
        }
    }

    @MainActor
    func saveManualHealth(steps: Int?, heartRate: Double?, weight: Double?) {
        healthKitService.saveManualSummary(steps: steps, heartRate: heartRate, weight: weight)
        healthSummary = healthKitService.todaySummary
    }

    func loadStreak() async {
        let count = await recordStore.consecutiveStreak()
        await MainActor.run {
            streak = count
        }
    }

    func loadRecentCheckins() async {
        let all = await recordStore.allCheckins()
        let recent = Array(all.prefix(3))
        await MainActor.run {
            recentCheckins = recent
        }
    }

    // MARK: - Computed

    var exerciseCount: Int {
        todayPlan?.exercises.count ?? 0
    }

    var isTrainingLocked: Bool {
        assessment?.riskLevel == .redFlag
    }

    var hasAssessment: Bool {
        assessment != nil
    }

    var targetDuration: Int {
        todayPlan?.targetDurationMinutes ?? 0
    }

    var nextTrainingHint: String {
        guard let latestFeedback else {
            return "按计划完成即可，任何不适都可以跳过动作。"
        }
        if latestFeedback.discomfort == .dizzy {
            return "上次记录头晕。今天训练前先确认状态，必要时暂停并咨询医生。"
        }
        if latestFeedback.discomfort != .none {
            return "上次记录\(latestFeedback.discomfort.displayName)。今天降低强度，相关动作不舒服就跳过。"
        }
        if latestFeedback.effort == .tooHard {
            return "上次感觉太累。今天建议慢一点，组间休息可以更长。"
        }
        if latestFeedback.effort == .easy {
            return "上次感觉轻松。今天保持稳定完成，不急着加量。"
        }
        return "上次强度正好。今天按当前计划继续。"
    }

    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        switch hour {
        case 5..<12: timeGreeting = "早上好"
        case 12..<18: timeGreeting = "下午好"
        default: timeGreeting = "晚上好"
        }
        return timeGreeting + "，老铁"
    }

    var streakProgress: Double {
        guard streak > 0 else { return 0 }
        return min(Double(streak) / 7.0, 1.0)
    }
}
