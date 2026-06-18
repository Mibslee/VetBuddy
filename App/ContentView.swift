import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var router: AppRouter
    @State private var onboardingStep: OnboardingStep = .questionnaire
    @State private var assessmentResult: AssessmentResult?

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView()
                .tabItem {
                    Label(AppTab.home.label, systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)

            TrainingTabView()
                .tabItem {
                    Label(AppTab.training.label, systemImage: AppTab.training.icon)
                }
                .tag(AppTab.training)

            NutritionView()
                .tabItem {
                    Label(AppTab.nutrition.label, systemImage: AppTab.nutrition.icon)
                }
                .tag(AppTab.nutrition)

            ProfileView()
                .tabItem {
                    Label(AppTab.profile.label, systemImage: AppTab.profile.icon)
                }
                .tag(AppTab.profile)
        }
        .tint(Color.vbAccent)
        .fullScreenCover(isPresented: $router.showOnboarding) {
            onboardingContent
        }
    }

    // MARK: - Onboarding

    @ViewBuilder
    private var onboardingContent: some View {
        switch onboardingStep {
        case .questionnaire:
            QuestionnaireView { result, answers in
                assessmentResult = result
                AssessmentService().saveAssessment(result, answers: answers)
                onboardingStep = .riskResult
            }

        case .riskResult:
            if let result = assessmentResult {
                RiskResultView(result: result) {
                    if result.riskLevel == .redFlag {
                        router.selectedTab = .nutrition
                    }
                    router.completeAssessment()
                    onboardingStep = .questionnaire
                }
            }

        case .complete:
            Color.clear
        }
    }
}

// MARK: - Onboarding Step

private enum OnboardingStep {
    case questionnaire
    case riskResult
    case complete
}

// MARK: - Training Tab Wrapper

private struct TrainingTabView: View {

    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isTrainingLocked {
                    lockedTrainingState
                } else if let plan = viewModel.todayPlan {
                    trainingListView(plan: plan)
                } else {
                    emptyTrainingState
                }
            }
            .background(Color.vbCream.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .task { await viewModel.loadAll() }
        }
    }

    private func trainingListView(plan: TrainingPlan) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]

        return ScrollView {
            VStack(spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("今日计划")
                            .vbHeadline()
                        Text("\(plan.exercises.count) 个动作 · \(plan.targetDurationMinutes) 分钟 · \(viewModel.planModeText)")
                            .vbCaption()
                            .foregroundStyle(Color.vbSecondaryText)
                    }

                    Spacer()

                    Text(plan.fitnessLevel.rawValue)
                        .font(VBFont.caption)
                        .foregroundStyle(Color.vbAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.vbAccent.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 2)

                if viewModel.usesLightTrainingMode {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .foregroundStyle(Color.vbSuccess)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.top, 2)
                        Text("上次训练反馈提示需要放轻一点。今天已减少组数、降低次数并延长休息。")
                            .font(VBFont.caption)
                            .foregroundStyle(Color.vbSecondaryText)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.vbSuccess.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(plan.exercises.enumerated()), id: \.element.id) { index, planned in
                        NavigationLink {
                            ExerciseDemoView(
                                exercise: planned.exercise,
                                fitnessLevel: plan.fitnessLevel,
                                plannedExercise: planned,
                                showsStartButton: false,
                                onStart: {}
                            )
                        } label: {
                            CompactExerciseCard(
                                step: index + 1,
                                title: planned.exercise.nameCN,
                                subtitle: "\(planned.sets) 组 x \(planned.reps) 次"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                NavigationLink {
                    TrainingSessionView(plan: plan)
                        .environmentObject(router)
                } label: {
                    Label("开始今日训练", systemImage: "play.fill")
                        .font(VBFont.button)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(Color.vbAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
    }

    private var emptyTrainingState: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "figure.walk")
                .font(.system(size: 60))
                .foregroundStyle(Color.vbAccent)
            Text("请先完成健康评估")
                .vbTitle()
            Text("评估后将为您生成个性化训练计划")
                .vbBody()
                .foregroundStyle(Color.vbSecondaryText)
            BigButton("开始评估") {
                router.showOnboarding = true
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var lockedTrainingState: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "cross.case.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.vbWarning)
            Text("暂不建议训练")
                .vbTitle()
            Text("您的健康评估提示需要先咨询医生。您仍然可以查看饮食建议，做好日常营养管理。")
                .vbBody()
                .foregroundStyle(Color.vbSecondaryText)
                .multilineTextAlignment(.center)
            BigButton("查看饮食建议", style: .secondary) {
                router.selectedTab = .nutrition
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

private struct CompactExerciseCard: View {
    let step: Int
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text("\(step)")
                .font(VBFont.caption)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Color.vbAccent)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(VBFont.headline)
                    .foregroundStyle(Color.vbMainText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text(subtitle)
                    .vbCaption()
                    .foregroundStyle(Color.vbSecondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.vbSecondaryText.opacity(0.65))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Preview

#Preview("ContentView") {
    ContentView()
        .environmentObject(AppRouter(defaults: .standard))
}
