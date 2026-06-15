import XCTest
@testable import VetBuddy

final class AppRouterTests: XCTestCase {

    private var defaults: UserDefaults!
    private var assessmentService: AssessmentService!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "AppRouterTests")!
        defaults.removePersistentDomain(forName: "AppRouterTests")
        assessmentService = AssessmentService(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "AppRouterTests")
        assessmentService = nil
        defaults = nil
        super.tearDown()
    }

    func test_init_showsOnboardingUntilAssessmentResultIsSaved() {
        defaults.set(true, forKey: "hasCompletedAssessment")

        let router = AppRouter(defaults: defaults, assessmentService: assessmentService)

        XCTAssertTrue(router.showOnboarding)
        XCTAssertFalse(router.hasCompletedAssessment)
    }

    func test_init_hidesOnboardingAfterAssessmentResultIsSaved() {
        let result = AssessmentResult(
            date: Date(),
            riskLevel: .standard,
            fitnessLevel: .L1,
            hasHeartDisease: false,
            hasCKD: false,
            hasDiabetes: false,
            ageRange: AgeRange.range60to65.rawValue
        )
        assessmentService.saveAssessment(result, answers: [])

        let router = AppRouter(defaults: defaults, assessmentService: assessmentService)

        XCTAssertFalse(router.showOnboarding)
        XCTAssertTrue(router.hasCompletedAssessment)
    }

    func test_resetAssessmentClearsSavedAssessment() {
        let result = AssessmentResult(
            date: Date(),
            riskLevel: .caution,
            fitnessLevel: .L1,
            hasHeartDisease: false,
            hasCKD: true,
            hasDiabetes: false,
            ageRange: AgeRange.range70to75.rawValue
        )
        assessmentService.saveAssessment(result, answers: [])
        let router = AppRouter(defaults: defaults, assessmentService: assessmentService)

        router.resetAssessment()

        XCTAssertTrue(router.showOnboarding)
        XCTAssertFalse(router.hasCompletedAssessment)
        XCTAssertNil(assessmentService.loadLatestAssessment())
    }
}
