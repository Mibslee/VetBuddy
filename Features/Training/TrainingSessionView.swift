import SwiftUI

/// Sequential training session flow — one exercise at a time,
/// with rest timers between sets and overall progress tracking.
struct TrainingSessionView: View {

    @StateObject private var viewModel = TrainingSessionViewModel()
    @EnvironmentObject private var router: AppRouter

    let plan: TrainingPlan

    @State private var showEndAlert = false
    @State private var showSkipAlert = false
    @State private var showSafetyAlert = false
    @State private var hasStartedSession = false
    @State private var navigateToComplete = false

    var body: some View {
        VStack(spacing: 0) {
            if !hasStartedSession {
                preflightContent
            } else if viewModel.isSessionComplete {
                completionRedirect
            } else {
                sessionContent
            }
        }
        .background(Color.vbCream.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            guard !hasStartedSession else { return }
            showSafetyAlert = true
        }
        .alert("训练前确认", isPresented: $showSafetyAlert) {
            Button("状态良好，开始") {
                hasStartedSession = true
                viewModel.startSession(plan: plan)
            }
            Button("今天先不练", role: .cancel) {
                router.selectedTab = .home
            }
        } message: {
            Text("如果今天有胸闷、头晕、明显膝痛或血压异常，请先休息并咨询医生。")
        }
    }

    private var preflightContent: some View {
        VStack(spacing: 18) {
            Spacer()

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 58))
                .foregroundStyle(Color.vbAccent)

            Text("训练准备")
                .font(VBFont.title)
                .foregroundStyle(Color.vbMainText)

            Text("开始前请确认今天状态良好。确认后会进入第一个动作并开始计时。")
                .vbBody()
                .foregroundStyle(Color.vbSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            Spacer()
        }
    }

    // MARK: - Completion Redirect

    private var completionRedirect: some View {
        Color.clear
            .onAppear {
                navigateToComplete = true
            }
            .navigationDestination(isPresented: $navigateToComplete) {
                TrainingCompleteView(
                    durationSeconds: viewModel.totalElapsedSeconds,
                    exerciseCount: viewModel.completedExerciseIndices.count,
                    totalExercises: viewModel.totalExercises
                )
                .environmentObject(router)
            }
    }

    // MARK: - Session Content

    private var sessionContent: some View {
        VStack(spacing: 0) {
            topBar
            overallProgressBar

            if viewModel.isResting {
                restTimerView
            } else {
                exerciseContent
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Text("动作 \(viewModel.currentExerciseIndex + 1)/\(viewModel.totalExercises)")
                .vbHeadline()

            Spacer()

            Text(viewModel.elapsedTimeText)
                .font(VBFont.headline)
                .foregroundStyle(Color.vbSecondaryText)

            Spacer()

            Button("暂停") {
                if viewModel.isPaused {
                    viewModel.resumeSession()
                } else {
                    viewModel.pauseSession()
                }
            }
            .font(VBFont.body)
            .foregroundStyle(Color.vbAccent)
            .frame(minWidth: 60, minHeight: 44)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Overall Progress

    private var overallProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.vbCardBackground)
                    .frame(height: 8)

                Capsule()
                    .fill(Color.vbAccent)
                    .frame(
                        width: geo.size.width * viewModel.overallProgress,
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.3), value: viewModel.overallProgress)
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Rest Timer

    private var restTimerView: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("休息中")
                .font(VBFont.title)
                .foregroundStyle(Color.vbSecondaryText)

            ProgressRing(
                progress: .constant(restProgress),
                size: 180,
                lineWidth: 16,
                color: .vbAccent
            )

            Text("\(viewModel.restTimeRemaining) 秒")
                .font(VBFont.hero)
                .foregroundStyle(Color.vbMainText)

            Text("下一组即将开始")
                .vbBody()
                .foregroundStyle(Color.vbSecondaryText)

            Spacer()
            Spacer()
        }
    }

    private var restProgress: Double {
        guard let exercise = viewModel.currentExercise else { return 0 }
        let total = Double(exercise.restSeconds)
        guard total > 0 else { return 0 }
        return Double(viewModel.restTimeRemaining) / total
    }

    // MARK: - Exercise Content

    private var exerciseContent: some View {
        VStack(spacing: 0) {
            if let exercise = viewModel.currentExercise {
                ScrollView {
                    VStack(spacing: 16) {
                        ExerciseMediaView(exercise: exercise.exercise, height: 300)
                            .padding(.top, 8)

                        currentExerciseSummary(exercise)

                        ExerciseMistakesPanel(exercise: exercise.exercise)

                        ExerciseGuidancePanel(exercise: exercise.exercise)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                }

                actionBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 18)
                    .background(Color.vbCream)
            }
        }
        .alert("确定结束训练？", isPresented: $showEndAlert) {
            Button("结束训练", role: .destructive) {
                viewModel.endSession()
            }
            Button("继续训练", role: .cancel) {}
        } message: {
            Text("当前进度将被保存。")
        }
        .alert("跳过此动作？", isPresented: $showSkipAlert) {
            Button("跳过", role: .destructive) {
                viewModel.skipCurrentExercise()
            }
            Button("继续练这个", role: .cancel) {}
        } message: {
            Text("可以因为疼痛、疲劳、场地或器材不合适跳过。跳过的动作不会计入完成数量。")
        }
    }

    private func currentExerciseSummary(_ exercise: PlannedExercise) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.exercise.nameCN)
                        .font(VBFont.title)
                        .foregroundStyle(Color.vbMainText)

                    Text(exercise.exercise.nameEN)
                        .vbCaption()
                }

                Spacer()

                Text("第 \(viewModel.currentSet) / \(exercise.sets) 组")
                    .font(VBFont.headline)
                    .foregroundStyle(Color.vbAccent)
            }

            HStack(spacing: 10) {
                exerciseStat(label: "每组", value: "\(exercise.reps) 次")
                exerciseStat(label: "休息", value: "\(exercise.restSeconds) 秒")
                exerciseStat(label: "已跳过", value: "\(viewModel.skippedExerciseIndices.count)")
            }

            ExerciseRhythmGuidancePanel(exercise: exercise.exercise, compact: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func exerciseStat(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(VBFont.headline)
                .foregroundStyle(Color.vbMainText)
            Text(label)
                .font(VBFont.caption)
                .foregroundStyle(Color.vbSecondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.vbCream.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var actionBar: some View {
        VStack(spacing: 10) {
            BigButton("完成一组") {
                viewModel.completeSet()
            }

            HStack(spacing: 12) {
                Button {
                    showSkipAlert = true
                } label: {
                    Label("跳过此动作", systemImage: "forward.end.fill")
                        .font(VBFont.headline)
                        .foregroundStyle(Color.vbAccent)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.vbCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    showEndAlert = true
                } label: {
                    Label("结束训练", systemImage: "xmark.circle.fill")
                        .font(VBFont.headline)
                        .foregroundStyle(Color.vbSecondaryText)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.vbCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .accessibilityElement(children: .contain)
    }

}

private struct ExerciseRhythmGuidancePanel: View {
    @StateObject private var speechController = GuidanceSpeechController()

    let exercise: Exercise
    let compact: Bool

    init(exercise: Exercise, compact: Bool = false) {
        self.exercise = exercise
        self.compact = compact
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "metronome.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.vbAccent)

            VStack(alignment: .leading, spacing: 4) {
                Text("训练节奏语音")
                    .font(VBFont.headline)
                    .foregroundStyle(Color.vbMainText)
                if !compact {
                    Text("运动时播放“慢起、保持、慢落”的节奏倒数；注意事项仍在下方单独朗读。")
                        .font(VBFont.caption)
                        .foregroundStyle(Color.vbSecondaryText)
                }
            }

            Spacer()

            Button {
                speechController.toggle(
                    text: exercise.rhythmGuidanceText,
                    voiceAssetName: "rhythm_\(exercise.id)"
                )
            } label: {
                Image(systemName: speechController.isSpeaking ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Color.vbAccent)
                    .clipShape(Circle())
            }
            .accessibilityLabel(speechController.isSpeaking ? "关闭节奏语音" : "播放节奏语音")
        }
        .padding(compact ? 12 : 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(compact ? Color.vbCream.opacity(0.55) : Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: compact ? 10 : 12, style: .continuous))
        .opacity(UserAppSettings.rhythmVoiceEnabled ? 1 : 0.55)
        .allowsHitTesting(UserAppSettings.rhythmVoiceEnabled)
    }
}

// MARK: - Preview

#Preview("Training Session") {
    let plan = TrainingPlanService().generateDailyPlan(for: .L1)
    NavigationStack {
        TrainingSessionView(plan: plan)
            .environmentObject(AppRouter(defaults: .standard))
    }
}
