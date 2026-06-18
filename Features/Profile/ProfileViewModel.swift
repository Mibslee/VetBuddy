import Foundation
import SwiftUI

/// ViewModel for the profile/settings screen.
final class ProfileViewModel: ObservableObject {

    @Published var assessment: AssessmentResult?
    @Published var healthKitStatus: HealthKitPermissionStatus = .notDetermined
    @Published var soundEnabled: Bool = true
    @Published var rhythmVoiceEnabled: Bool = true
    @Published var safetyVoiceEnabled: Bool = true
    @Published var speechRate: Double = 0.43
    @Published var familySummary = FamilySummary.empty

    private let assessmentService: AssessmentService
    private let permissionManager: HealthKitPermissionManager
    private let trainingStore: TrainingRecordStore
    private let dietStore: DietRecordStore

    init(
        assessmentService: AssessmentService = AssessmentService(),
        permissionManager: HealthKitPermissionManager = HealthKitPermissionManager(),
        trainingStore: TrainingRecordStore = .shared,
        dietStore: DietRecordStore = DietRecordStore()
    ) {
        self.assessmentService = assessmentService
        self.permissionManager = permissionManager
        self.trainingStore = trainingStore
        self.dietStore = dietStore
    }

    func loadProfile() {
        assessment = assessmentService.loadLatestAssessment()
        healthKitStatus = permissionManager.checkCurrentStatus()
        soundEnabled = UserAppSettings.soundEnabled
        rhythmVoiceEnabled = UserAppSettings.rhythmVoiceEnabled
        safetyVoiceEnabled = UserAppSettings.safetyVoiceEnabled
        speechRate = UserAppSettings.speechRate
    }

    func loadFamilySummary() async {
        let checkins = await trainingStore.allCheckins()
        let recentSeven = checkins.filter {
            let dayDelta = Calendar.current.dateComponents([.day], from: $0.date, to: Date()).day ?? 99
            return dayDelta >= 0 && dayDelta < 7
        }
        let todayDiet = dietStore.loadEntries()
        let summary = DietAnalyzer.summarize(todayDiet)
        await MainActor.run {
            familySummary = FamilySummary(
                trainingDays: recentSeven.count,
                latestTrainingText: recentSeven.first.map {
                    "\($0.completedExerciseCount)/\($0.totalExerciseCount) 个动作，\(max(1, $0.totalDurationSeconds / 60)) 分钟"
                } ?? "近 7 天暂无训练记录",
                todayMealCount: todayDiet.count,
                todayProteinG: summary.proteinG
            )
        }
    }

    func resetAssessment() {
        assessmentService.clearAssessment()
        assessment = nil
    }

    func toggleSound() {
        soundEnabled.toggle()
        UserAppSettings.soundEnabled = soundEnabled
    }

    func toggleRhythmVoice() {
        rhythmVoiceEnabled.toggle()
        UserAppSettings.rhythmVoiceEnabled = rhythmVoiceEnabled
    }

    func toggleSafetyVoice() {
        safetyVoiceEnabled.toggle()
        UserAppSettings.safetyVoiceEnabled = safetyVoiceEnabled
    }

    func setSpeechRate(_ rate: Double) {
        speechRate = rate
        UserAppSettings.speechRate = rate
    }

    func requestHealthKit() async {
        let status = await permissionManager.requestAuthorization()
        await MainActor.run {
            healthKitStatus = status
        }
    }

    // MARK: - Display Helpers

    var riskLevelText: String {
        guard let assessment else { return "未评估" }
        switch assessment.riskLevel {
        case .standard: return "标准模式"
        case .caution: return "谨慎模式"
        case .redFlag: return "红旗禁止"
        }
    }

    var fitnessLevelText: String {
        guard let assessment else { return "未评估" }
        switch assessment.fitnessLevel {
        case .L1: return "L1 入门级"
        case .L2: return "L2 进阶级"
        case .L3: return "L3 活跃级"
        }
    }

    var healthKitStatusText: String {
        switch healthKitStatus {
        case .authorized: return "已连接"
        case .denied: return "已拒绝"
        case .notDetermined: return "未授权"
        }
    }

    var healthKitStatusColor: Color {
        switch healthKitStatus {
        case .authorized: return .vbSuccess
        case .denied: return .vbWarning
        case .notDetermined: return .vbSecondaryText
        }
    }

}

struct FamilySummary: Equatable {
    let trainingDays: Int
    let latestTrainingText: String
    let todayMealCount: Int
    let todayProteinG: Double

    static let empty = FamilySummary(
        trainingDays: 0,
        latestTrainingText: "暂无训练记录",
        todayMealCount: 0,
        todayProteinG: 0
    )
}
