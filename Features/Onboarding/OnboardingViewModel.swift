import Foundation
import SwiftUI

/// ViewModel for the health questionnaire (onboarding flow).
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published State

    @Published var currentIndex: Int = 0
    @Published var answers: [Int: String] = [:]
    @Published var isComplete: Bool = false

    // MARK: - Computed

    /// Questions visible to the user, filtered by conditional logic.
    /// Re-evaluated on every access since `answers` is @Published.
    var visibleQuestions: [Question] {
        QuestionBank.questions.filter { question in
            guard question.isConditional,
                  let parentId = question.parentQuestionId,
                  let required = question.parentRequiredAnswer else {
                return true
            }
            return answers[parentId] == required
        }
    }

    /// Human-readable progress string, e.g. "第 3 题 / 共 8 题".
    var progressText: String {
        let total = visibleQuestions.count
        guard total > 0 else { return "" }
        let current = min(currentIndex + 1, total)
        return "第 \(current) 题 / 共 \(total) 题"
    }

    /// Whether the current question has been answered.
    var isCurrentQuestionAnswered: Bool {
        guard currentIndex < visibleQuestions.count else { return false }
        let question = visibleQuestions[currentIndex]
        return answers[question.id] != nil
    }

    /// Whether we are on the last question.
    var isLastQuestion: Bool {
        currentIndex == visibleQuestions.count - 1
    }

    var answerList: [Answer] {
        let visibleQuestionIds = Set(visibleQuestions.map(\.id))
        return answers
            .filter { visibleQuestionIds.contains($0.key) }
            .map { Answer(questionId: $0.key, value: $0.value) }
            .sorted { $0.questionId < $1.questionId }
    }

    // MARK: - Actions

    func selectAnswer(questionId: Int, value: String) {
        var newAnswers = answers
        newAnswers[questionId] = value
        removeStaleConditionalAnswers(parentId: questionId, from: &newAnswers)
        answers = newAnswers
        clampCurrentIndex()
    }

    func moveToNext() {
        guard !isLastQuestion else { return }
        withAnimation {
            currentIndex += 1
        }
    }

    func moveToPrevious() {
        guard currentIndex > 0 else { return }
        withAnimation {
            currentIndex -= 1
        }
    }

    func completeAssessment() -> AssessmentResult {
        let result = AssessmentEvaluator.evaluate(answerList)
        isComplete = true
        return result
    }

    func reset() {
        currentIndex = 0
        answers = [:]
        isComplete = false
    }

    // MARK: - Conditional Answer Hygiene

    private func removeStaleConditionalAnswers(parentId: Int, from answers: inout [Int: String]) {
        let childQuestions = QuestionBank.questions.filter { $0.parentQuestionId == parentId }
        for child in childQuestions {
            let shouldRemainVisible = child.parentRequiredAnswer == answers[parentId]
            if !shouldRemainVisible {
                answers.removeValue(forKey: child.id)
                removeStaleConditionalAnswers(parentId: child.id, from: &answers)
            }
        }
    }

    private func clampCurrentIndex() {
        let lastIndex = max(visibleQuestions.count - 1, 0)
        if currentIndex > lastIndex {
            currentIndex = lastIndex
        }
    }
}

// MARK: - Animation Helper

private func withAnimation(_ body: () -> Void) {
    SwiftUI.withAnimation(.easeInOut(duration: 0.3), body)
}
