import SwiftUI

enum AppTab: String, CaseIterable, Sendable {
    case home, training, nutrition, profile

    var label: String {
        switch self {
        case .home: "首页"
        case .training: "训练"
        case .nutrition: "饮食"
        case .profile: "我的"
        }
    }

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .training: "figure.walk"
        case .nutrition: "leaf.fill"
        case .profile: "person.fill"
        }
    }
}

final class AppRouter: ObservableObject, @unchecked Sendable {

    @Published var path = NavigationPath()
    @Published var selectedTab: AppTab = .home
    @Published var showOnboarding: Bool

    private let defaults: UserDefaults
    private let assessmentService: AssessmentService

    init(
        defaults: UserDefaults = .standard,
        assessmentService: AssessmentService? = nil
    ) {
        self.defaults = defaults
        let service = assessmentService ?? AssessmentService(defaults: defaults)
        self.assessmentService = service
        self.showOnboarding = !service.hasCompletedAssessment()
    }

    // MARK: - Navigation

    func navigateToTraining() {
        selectedTab = .training
    }

    func showOnboardingFlow() {
        showOnboarding = true
    }

    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    // MARK: - Assessment Completion

    func completeAssessment() {
        showOnboarding = false
    }

    func resetAssessment() {
        defaults.removeObject(forKey: Keys.hasCompletedAssessment)
        assessmentService.clearAssessment()
        showOnboarding = true
    }

    var hasCompletedAssessment: Bool {
        assessmentService.hasCompletedAssessment()
    }

    // MARK: - Keys

    private enum Keys {
        static let hasCompletedAssessment = "hasCompletedAssessment"
    }
}
