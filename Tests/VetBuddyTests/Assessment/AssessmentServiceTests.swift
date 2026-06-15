import XCTest
@testable import VetBuddy

final class AssessmentServiceTests: XCTestCase {

    private var service: AssessmentService!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "AssessmentServiceTests")!
        defaults.removePersistentDomain(forName: "AssessmentServiceTests")
        service = AssessmentService(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "AssessmentServiceTests")
        defaults = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Helper

    private func makeSampleResult(
        riskLevel: RiskLevel = .standard,
        fitnessLevel: FitnessLevel = .L2
    ) -> AssessmentResult {
        AssessmentResult(
            date: Date(timeIntervalSince1970: 1_700_000_000),
            riskLevel: riskLevel,
            fitnessLevel: fitnessLevel,
            hasHeartDisease: false,
            hasCKD: false,
            hasDiabetes: false,
            ageRange: AgeRange.range65to70.rawValue
        )
    }

    private func makeSampleAnswers() -> [Answer] {
        [
            Answer(questionId: 1, value: AgeRange.range65to70.rawValue),
            Answer(questionId: 2, value: TriChoice.no.rawValue),
            Answer(questionId: 4, value: TriChoice.no.rawValue),
            Answer(questionId: 5, value: TriChoice.no.rawValue),
            Answer(questionId: 7, value: ActivityLevel.occasional.rawValue),
            Answer(questionId: 8, value: TriChoice.no.rawValue),
            Answer(questionId: 9, value: TriChoice.no.rawValue),
            Answer(questionId: 10, value: TriChoice.no.rawValue)
        ]
    }

    // MARK: - Save and Load

    func test_saveAndLoad_保存后能正确加载() {
        // Arrange
        let result = makeSampleResult()
        let answers = makeSampleAnswers()

        // Act
        service.saveAssessment(result, answers: answers)
        let loaded = service.loadLatestAssessment()

        // Assert
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.riskLevel, .standard)
        XCTAssertEqual(loaded?.fitnessLevel, .L2)
        XCTAssertEqual(loaded?.ageRange, AgeRange.range65to70.rawValue)
    }

    func test_saveAndLoad_保存的答案能正确加载() {
        // Arrange
        let result = makeSampleResult()
        let answers = makeSampleAnswers()

        // Act
        service.saveAssessment(result, answers: answers)
        let loaded = service.loadSavedAnswers()

        // Assert
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.count, answers.count)
    }

    func test_saveAndLoad_覆盖保存使用最新数据() {
        // Arrange
        let first = makeSampleResult(riskLevel: .standard)
        let second = makeSampleResult(riskLevel: .caution)
        let answers = makeSampleAnswers()

        // Act
        service.saveAssessment(first, answers: answers)
        service.saveAssessment(second, answers: answers)
        let loaded = service.loadLatestAssessment()

        // Assert
        XCTAssertEqual(loaded?.riskLevel, .caution)
    }

    // MARK: - hasCompletedAssessment

    func test_hasCompleted_初始状态为false() {
        // Assert
        XCTAssertFalse(service.hasCompletedAssessment())
    }

    func test_hasCompleted_保存后为true() {
        // Arrange
        let result = makeSampleResult()

        // Act
        service.saveAssessment(result, answers: [])

        // Assert
        XCTAssertTrue(service.hasCompletedAssessment())
    }

    func test_hasCompleted_清除后为false() {
        // Arrange
        let result = makeSampleResult()
        service.saveAssessment(result, answers: [])

        // Act
        service.clearAssessment()

        // Assert
        XCTAssertFalse(service.hasCompletedAssessment())
    }

    // MARK: - Clear

    func test_clear_清除所有数据() {
        // Arrange
        let result = makeSampleResult()
        let answers = makeSampleAnswers()
        service.saveAssessment(result, answers: answers)

        // Act
        service.clearAssessment()

        // Assert
        XCTAssertNil(service.loadLatestAssessment())
        XCTAssertNil(service.loadSavedAnswers())
        XCTAssertFalse(service.hasCompletedAssessment())
    }

    // MARK: - Load When Empty

    func test_loadLatest_无数据时返回nil() {
        // Act
        let loaded = service.loadLatestAssessment()

        // Assert
        XCTAssertNil(loaded)
    }

    func test_loadAnswers_无数据时返回nil() {
        // Act
        let loaded = service.loadSavedAnswers()

        // Assert
        XCTAssertNil(loaded)
    }

    // MARK: - Version Tracking

    func test_savedVersion_保存后记录版本号() {
        // Arrange
        let result = makeSampleResult()

        // Act
        service.saveAssessment(result, answers: [])

        // Assert
        XCTAssertEqual(service.savedVersion(), QuestionBank.version)
    }

    func test_savedVersion_清除后版本为0() {
        // Arrange
        service.saveAssessment(makeSampleResult(), answers: [])

        // Act
        service.clearAssessment()

        // Assert
        XCTAssertEqual(service.savedVersion(), 0)
    }

    // MARK: - Red Flag Result Round-Trip

    func test_saveAndLoad_红旗结果正确持久化() {
        // Arrange
        let result = makeSampleResult(riskLevel: .redFlag, fitnessLevel: .L1)

        // Act
        service.saveAssessment(result, answers: [])
        let loaded = service.loadLatestAssessment()

        // Assert
        XCTAssertEqual(loaded?.riskLevel, .redFlag)
        XCTAssertEqual(loaded?.fitnessLevel, .L1)
    }

    func test_saveAndLoad_心脏病标记正确持久化() {
        // Arrange
        var result = makeSampleResult()
        result = AssessmentResult(
            date: result.date,
            riskLevel: result.riskLevel,
            fitnessLevel: result.fitnessLevel,
            hasHeartDisease: true,
            hasCKD: result.hasCKD,
            hasDiabetes: result.hasDiabetes,
            ageRange: result.ageRange
        )

        // Act
        service.saveAssessment(result, answers: [])
        let loaded = service.loadLatestAssessment()

        // Assert
        XCTAssertTrue(loaded?.hasHeartDisease ?? false)
    }
}
