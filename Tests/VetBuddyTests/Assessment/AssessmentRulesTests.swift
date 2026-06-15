import XCTest
@testable import VetBuddy

final class AssessmentRulesTests: XCTestCase {

    // MARK: - Helper

    private func makeAnswers(_ pairs: [(Int, String)]) -> [Answer] {
        pairs.map { Answer(questionId: $0.0, value: $0.1) }
    }

    /// Default healthy answers: no risk factors, sedentary activity.
    private func defaultAnswers() -> [Answer] {
        makeAnswers([
            (1, AgeRange.range65to70.rawValue),
            (2, TriChoice.no.rawValue),
            (4, TriChoice.no.rawValue),
            (5, TriChoice.no.rawValue),
            (7, ActivityLevel.sedentary.rawValue),
            (8, TriChoice.no.rawValue),
            (9, TriChoice.no.rawValue),
            (10, TriChoice.no.rawValue)
        ])
    }

    /// Replaces the answer for a given questionId, or appends if not found.
    private func replaceAnswer(in answers: [Answer], questionId: Int, value: String) -> [Answer] {
        var result = answers.filter { $0.questionId != questionId }
        result.append(Answer(questionId: questionId, value: value))
        return result
    }

    // MARK: - Red Flag Tests

    func test_redFlag_心脏病触发红旗() {
        // Arrange
        let answers = replaceAnswer(in: defaultAnswers(), questionId: 4, value: TriChoice.yes.rawValue)

        // Act
        let risk = AssessmentEvaluator.determineRiskLevel(answers)

        // Assert
        XCTAssertEqual(risk, .redFlag)
    }

    func test_redFlag_近期髋部手术触发红旗() {
        // Arrange
        var answers = replaceAnswer(in: defaultAnswers(), questionId: 5, value: TriChoice.yes.rawValue)
        answers = replaceAnswer(in: answers, questionId: 6, value: SurgeryRecency.under6Months.rawValue)

        // Act
        let risk = AssessmentEvaluator.determineRiskLevel(answers)

        // Assert
        XCTAssertEqual(risk, .redFlag)
    }

    func test_redFlag_未控制高血压触发红旗() {
        // Arrange
        var answers = replaceAnswer(in: defaultAnswers(), questionId: 2, value: TriChoice.yes.rawValue)
        answers.append(Answer(questionId: 3, value: TriChoice.no.rawValue))

        // Act
        let risk = AssessmentEvaluator.determineRiskLevel(answers)

        // Assert
        XCTAssertEqual(risk, .redFlag)
    }

    func test_redFlag_所有红旗条件同时满足仍为红旗() {
        // Arrange
        let answers = makeAnswers([
            (1, AgeRange.range75plus.rawValue),
            (2, TriChoice.yes.rawValue),
            (3, TriChoice.no.rawValue),
            (4, TriChoice.yes.rawValue),
            (5, TriChoice.yes.rawValue),
            (6, SurgeryRecency.under6Months.rawValue),
            (7, ActivityLevel.sedentary.rawValue),
            (8, TriChoice.yes.rawValue),
            (9, TriChoice.yes.rawValue),
            (10, TriChoice.yes.rawValue)
        ])

        // Act
        let result = AssessmentEvaluator.evaluate(answers)

        // Assert
        XCTAssertEqual(result.riskLevel, .redFlag)
        XCTAssertTrue(result.hasHeartDisease)
        XCTAssertTrue(result.hasCKD)
        XCTAssertTrue(result.hasDiabetes)
    }

    // MARK: - Caution Tests

    func test_caution_药物控制高血压触发谨慎() {
        // Arrange
        var answers = replaceAnswer(in: defaultAnswers(), questionId: 2, value: TriChoice.yes.rawValue)
        answers.append(Answer(questionId: 3, value: TriChoice.yes.rawValue))

        // Act
        let risk = AssessmentEvaluator.determineRiskLevel(answers)

        // Assert
        XCTAssertEqual(risk, .caution)
    }

    func test_caution_手术6到12个月触发谨慎() {
        // Arrange
        var answers = replaceAnswer(in: defaultAnswers(), questionId: 5, value: TriChoice.yes.rawValue)
        answers.append(Answer(questionId: 6, value: SurgeryRecency.sixTo12Months.rawValue))

        // Act
        let risk = AssessmentEvaluator.determineRiskLevel(answers)

        // Assert
        XCTAssertEqual(risk, .caution)
    }

    func test_caution_慢性肾病触发谨慎() {
        // Arrange
        let answers = replaceAnswer(in: defaultAnswers(), questionId: 8, value: TriChoice.yes.rawValue)

        // Act
        let risk = AssessmentEvaluator.determineRiskLevel(answers)

        // Assert
        XCTAssertEqual(risk, .caution)
    }

    // MARK: - Standard + Fitness Level Tests

    func test_standardL1_几乎不活动() {
        // Arrange
        let answers = makeAnswers([
            (1, AgeRange.range60to65.rawValue),
            (2, TriChoice.no.rawValue),
            (4, TriChoice.no.rawValue),
            (5, TriChoice.no.rawValue),
            (7, ActivityLevel.sedentary.rawValue),
            (8, TriChoice.no.rawValue),
            (9, TriChoice.no.rawValue),
            (10, TriChoice.no.rawValue)
        ])

        // Act
        let result = AssessmentEvaluator.evaluate(answers)

        // Assert
        XCTAssertEqual(result.riskLevel, .standard)
        XCTAssertEqual(result.fitnessLevel, .L1)
    }

    func test_standardL2_偶尔散步() {
        // Arrange
        var answers = defaultAnswers()
        answers = answers.filter { $0.questionId != 7 }
        answers.append(Answer(questionId: 7, value: ActivityLevel.occasional.rawValue))

        // Act
        let result = AssessmentEvaluator.evaluate(answers)

        // Assert
        XCTAssertEqual(result.riskLevel, .standard)
        XCTAssertEqual(result.fitnessLevel, .L2)
    }

    func test_standardL3_经常散步() {
        // Arrange
        var answers = defaultAnswers()
        answers = answers.filter { $0.questionId != 7 }
        answers.append(Answer(questionId: 7, value: ActivityLevel.regular.rawValue))

        // Act
        let result = AssessmentEvaluator.evaluate(answers)

        // Assert
        XCTAssertEqual(result.riskLevel, .standard)
        XCTAssertEqual(result.fitnessLevel, .L3)
    }

    func test_standardL3_规律运动() {
        // Arrange
        var answers = defaultAnswers()
        answers = answers.filter { $0.questionId != 7 }
        answers.append(Answer(questionId: 7, value: ActivityLevel.active.rawValue))

        // Act
        let result = AssessmentEvaluator.evaluate(answers)

        // Assert
        XCTAssertEqual(result.riskLevel, .standard)
        XCTAssertEqual(result.fitnessLevel, .L3)
    }

    // MARK: - CKD Level Tests

    func test_ckdLevel_确认有肾病() {
        // Arrange
        let answers = makeAnswers([(8, TriChoice.yes.rawValue)])

        // Act
        let level = AssessmentEvaluator.determineCKDLevel(answers)

        // Assert
        XCTAssertEqual(level, .stage3)
    }

    func test_ckdLevel_无肾病() {
        // Arrange
        let answers = makeAnswers([(8, TriChoice.no.rawValue)])

        // Act
        let level = AssessmentEvaluator.determineCKDLevel(answers)

        // Assert
        XCTAssertEqual(level, .none)
    }

    func test_ckdLevel_不确定() {
        // Arrange
        let answers = makeAnswers([(8, TriChoice.unsure.rawValue)])

        // Act
        let level = AssessmentEvaluator.determineCKDLevel(answers)

        // Assert
        XCTAssertEqual(level, .unknown)
    }

    func test_ckdLevel_未作答默认无() {
        // Arrange
        let answers: [Answer] = []

        // Act
        let level = AssessmentEvaluator.determineCKDLevel(answers)

        // Assert
        XCTAssertEqual(level, .none)
    }

    // MARK: - Conditional Question Visibility

    func test_conditional_Q3仅在Q2为是时显示() {
        // Arrange
        let vm1 = OnboardingViewModel()
        vm1.answers[2] = TriChoice.yes.rawValue
        let vm2 = OnboardingViewModel()
        vm2.answers[2] = TriChoice.no.rawValue

        // Act
        let visibleIds1 = vm1.visibleQuestions.map(\.id)
        let visibleIds2 = vm2.visibleQuestions.map(\.id)

        // Assert
        XCTAssertTrue(visibleIds1.contains(3), "Q3 应在 Q2=是 时显示")
        XCTAssertFalse(visibleIds2.contains(3), "Q3 不应在 Q2=否 时显示")
    }

    func test_conditional_Q6仅在Q5为是时显示() {
        // Arrange
        let vm1 = OnboardingViewModel()
        vm1.answers[5] = TriChoice.yes.rawValue
        let vm2 = OnboardingViewModel()
        vm2.answers[5] = TriChoice.no.rawValue

        // Act
        let visibleIds1 = vm1.visibleQuestions.map(\.id)
        let visibleIds2 = vm2.visibleQuestions.map(\.id)

        // Assert
        XCTAssertTrue(visibleIds1.contains(6), "Q6 应在 Q5=是 时显示")
        XCTAssertFalse(visibleIds2.contains(6), "Q6 不应在 Q5=否 时显示")
    }

    func test_conditional_无条件问题始终显示() {
        // Arrange
        let vm = OnboardingViewModel()

        // Act
        let visibleIds = vm.visibleQuestions.map(\.id)

        // Assert
        let unconditionalIds = [1, 2, 4, 5, 7, 8, 9, 10]
        for id in unconditionalIds {
            XCTAssertTrue(visibleIds.contains(id), "Q\(id) 应始终显示")
        }
    }

    func test_conditional_全部条件问题同时显示() {
        // Arrange
        let vm = OnboardingViewModel()
        vm.answers[2] = TriChoice.yes.rawValue
        vm.answers[5] = TriChoice.yes.rawValue

        // Act
        let visibleIds = vm.visibleQuestions.map(\.id)

        // Assert
        XCTAssertTrue(visibleIds.contains(3), "Q3 应显示")
        XCTAssertTrue(visibleIds.contains(6), "Q6 应显示")
        XCTAssertEqual(visibleIds.count, 10, "全部 10 题应显示")
    }

    func test_conditional_父问题改为否时清除隐藏追问答案() {
        // Arrange
        let vm = OnboardingViewModel()
        vm.selectAnswer(questionId: 5, value: TriChoice.yes.rawValue)
        vm.selectAnswer(questionId: 6, value: SurgeryRecency.under6Months.rawValue)

        // Act
        vm.selectAnswer(questionId: 5, value: TriChoice.no.rawValue)
        let visibleIds = vm.visibleQuestions.map(\.id)
        let answerIds = vm.answerList.map(\.questionId)

        // Assert
        XCTAssertFalse(visibleIds.contains(6), "Q6 不应在 Q5=否 时显示")
        XCTAssertFalse(answerIds.contains(6), "隐藏追问的旧答案不应参与评估")
        XCTAssertEqual(AssessmentEvaluator.evaluate(vm.answerList).riskLevel, .standard)
    }

    // MARK: - Evaluate Integration

    func test_evaluate_健康用户完整评估() {
        // Arrange
        let answers = makeAnswers([
            (1, AgeRange.range60to65.rawValue),
            (2, TriChoice.no.rawValue),
            (4, TriChoice.no.rawValue),
            (5, TriChoice.no.rawValue),
            (7, ActivityLevel.occasional.rawValue),
            (8, TriChoice.no.rawValue),
            (9, TriChoice.no.rawValue),
            (10, TriChoice.no.rawValue)
        ])

        // Act
        let result = AssessmentEvaluator.evaluate(answers)

        // Assert
        XCTAssertEqual(result.riskLevel, .standard)
        XCTAssertEqual(result.fitnessLevel, .L2)
        XCTAssertFalse(result.hasHeartDisease)
        XCTAssertFalse(result.hasCKD)
        XCTAssertFalse(result.hasDiabetes)
        XCTAssertEqual(result.ageRange, AgeRange.range60to65.rawValue)
    }

    func test_evaluate_糖尿病用户正确标记() {
        // Arrange
        let answers = replaceAnswer(in: defaultAnswers(), questionId: 9, value: TriChoice.yes.rawValue)

        // Act
        let result = AssessmentEvaluator.evaluate(answers)

        // Assert
        XCTAssertTrue(result.hasDiabetes)
    }

    // MARK: - Edge Cases

    func test_evaluate_空答案默认L1标准() {
        // Arrange
        let answers: [Answer] = []

        // Act
        let result = AssessmentEvaluator.evaluate(answers)

        // Assert
        XCTAssertEqual(result.riskLevel, .standard)
        XCTAssertEqual(result.fitnessLevel, .L1)
    }

    func test_evaluate_手术超过12个月不影响风险() {
        // Arrange
        var answers = defaultAnswers()
        answers.append(Answer(questionId: 5, value: TriChoice.yes.rawValue))
        answers.append(Answer(questionId: 6, value: SurgeryRecency.over12Months.rawValue))

        // Act
        let risk = AssessmentEvaluator.determineRiskLevel(answers)

        // Assert
        XCTAssertEqual(risk, .standard)
    }

    func test_evaluate_不确定高血压不影响风险() {
        // Arrange
        var answers = defaultAnswers()
        answers.append(Answer(questionId: 2, value: TriChoice.unsure.rawValue))

        // Act
        let risk = AssessmentEvaluator.determineRiskLevel(answers)

        // Assert
        XCTAssertEqual(risk, .standard)
    }
}
