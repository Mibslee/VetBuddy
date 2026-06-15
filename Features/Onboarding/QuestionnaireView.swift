import SwiftUI

/// Health questionnaire view for onboarding.
/// Paged single-question UI designed for 60+ elderly users.
struct QuestionnaireView: View {

    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    let onComplete: (AssessmentResult, [Answer]) -> Void

    var body: some View {
        VStack(spacing: 0) {
            progressBar
            if viewModel.currentIndex < viewModel.visibleQuestions.count {
                questionPage(
                    question: viewModel.visibleQuestions[viewModel.currentIndex],
                    at: viewModel.currentIndex
                )
            }
        }
        .background(Color.vbCream.ignoresSafeArea())
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: 8) {
            Text(viewModel.progressText)
                .font(VBFont.headline)
                .foregroundStyle(Color.vbSecondaryText)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.vbCardBackground)
                        .frame(height: 8)

                    Capsule()
                        .fill(Color.vbAccent)
                        .frame(
                            width: geo.size.width * progressFraction,
                            height: 8
                        )
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentIndex)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 24)
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var progressFraction: CGFloat {
        let total = viewModel.visibleQuestions.count
        guard total > 0 else { return 0 }
        return CGFloat(viewModel.currentIndex + 1) / CGFloat(total)
    }

    // MARK: - Question Page

    private func questionPage(question: Question, at index: Int) -> some View {
        ScrollView {
            VStack(spacing: 32) {
                Text(question.text)
                    .font(VBFont.title)
                    .foregroundStyle(Color.vbMainText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                answerOptions(for: question)

                Spacer(minLength: 24)

                if viewModel.currentIndex > 0 {
                    BigButton("上一题", style: .secondary) {
                        viewModel.moveToPrevious()
                    }
                }

                actionButton(for: question)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Answer Options

    @ViewBuilder
    private func answerOptions(for question: Question) -> some View {
        switch question.type {
        case .ageRange:
            ageRangeOptions(questionId: question.id)
        case .triChoice:
            triChoiceOptions(questionId: question.id)
        case .surgeryRecency:
            surgeryRecencyOptions(questionId: question.id)
        case .activityLevel:
            activityLevelOptions(questionId: question.id)
        case .ckdStage:
            ckdStageOptions(questionId: question.id)
        }
    }

    private func ageRangeOptions(questionId: Int) -> some View {
        VStack(spacing: 16) {
            ForEach(AgeRange.allCases, id: \.self) { range in
                answerButton(
                    text: range.displayText,
                    isSelected: viewModel.answers[questionId] == range.rawValue
                ) {
                    viewModel.selectAnswer(questionId: questionId, value: range.rawValue)
                }
            }
        }
    }

    private func triChoiceOptions(questionId: Int) -> some View {
        let options: [(String, String)] = [
            (TriChoice.yes.rawValue, "是"),
            (TriChoice.no.rawValue, "否"),
            (TriChoice.unsure.rawValue, "不确定")
        ]
        return VStack(spacing: 16) {
            ForEach(options, id: \.0) { value, label in
                answerButton(
                    text: label,
                    isSelected: viewModel.answers[questionId] == value
                ) {
                    viewModel.selectAnswer(questionId: questionId, value: value)
                }
            }
        }
    }

    private func surgeryRecencyOptions(questionId: Int) -> some View {
        let options: [SurgeryRecency] = [.under6Months, .sixTo12Months, .over12Months]
        return VStack(spacing: 16) {
            ForEach(options, id: \.self) { recency in
                answerButton(
                    text: recency.displayText,
                    isSelected: viewModel.answers[questionId] == recency.rawValue
                ) {
                    viewModel.selectAnswer(questionId: questionId, value: recency.rawValue)
                }
            }
        }
    }

    private func activityLevelOptions(questionId: Int) -> some View {
        let options: [ActivityLevel] = [.sedentary, .occasional, .regular, .active]
        return VStack(spacing: 16) {
            ForEach(options, id: \.self) { level in
                answerButton(
                    text: level.displayText,
                    isSelected: viewModel.answers[questionId] == level.rawValue
                ) {
                    viewModel.selectAnswer(questionId: questionId, value: level.rawValue)
                }
            }
        }
    }

    private func ckdStageOptions(questionId: Int) -> some View {
        VStack(spacing: 16) {
            ForEach(CKDStageChoice.allCases, id: \.self) { stage in
                answerButton(
                    text: stage.displayText,
                    isSelected: viewModel.answers[questionId] == stage.rawValue
                ) {
                    viewModel.selectAnswer(questionId: questionId, value: stage.rawValue)
                }
            }
        }
    }

    // MARK: - Answer Button

    private func answerButton(
        text: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(text)
                .font(VBFont.body)
                .foregroundStyle(isSelected ? .white : Color.vbMainText)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(isSelected ? Color.vbAccent : Color.vbCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(
                            isSelected ? Color.clear : Color.vbSecondaryText.opacity(0.3),
                            lineWidth: 1.5
                        )
                )
        }
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Action Button

    @ViewBuilder
    private func actionButton(for question: Question) -> some View {
        if viewModel.isLastQuestion {
            BigButton("完成评估", isDisabled: !viewModel.isCurrentQuestionAnswered) {
                let result = viewModel.completeAssessment()
                onComplete(result, viewModel.answerList)
            }
        } else {
            BigButton("下一题", isDisabled: !viewModel.isCurrentQuestionAnswered) {
                viewModel.moveToNext()
            }
        }
    }
}

// MARK: - Preview

#Preview("Questionnaire") {
    QuestionnaireView { result, _ in
        print("Assessment complete: \(result.riskLevel)")
    }
}
