import Foundation
import SwiftUI

/// ViewModel for the profile/settings screen.
final class ProfileViewModel: ObservableObject {

    @Published var assessment: AssessmentResult?
    @Published var healthKitStatus: HealthKitPermissionStatus = .notDetermined
    @Published var soundEnabled: Bool = true

    private let assessmentService: AssessmentService
    private let permissionManager: HealthKitPermissionManager

    init(
        assessmentService: AssessmentService = AssessmentService(),
        permissionManager: HealthKitPermissionManager = HealthKitPermissionManager()
    ) {
        self.assessmentService = assessmentService
        self.permissionManager = permissionManager
    }

    func loadProfile() {
        assessment = assessmentService.loadLatestAssessment()
        healthKitStatus = permissionManager.checkCurrentStatus()
        if UserDefaults.standard.object(forKey: Keys.soundEnabled) == nil {
            soundEnabled = true
        } else {
            soundEnabled = UserDefaults.standard.bool(forKey: Keys.soundEnabled)
        }
    }

    func resetAssessment() {
        assessmentService.clearAssessment()
        assessment = nil
    }

    func toggleSound() {
        soundEnabled.toggle()
        UserDefaults.standard.set(soundEnabled, forKey: Keys.soundEnabled)
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

    // MARK: - Keys

    private enum Keys {
        static let soundEnabled = "vb_sound_enabled"
    }
}
