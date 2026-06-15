import SwiftUI

/// Main home dashboard showing today's plan, streak, and health summary.
struct HomeView: View {

    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var router: AppRouter
    @State private var showManualHealthInput = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    greetingSection
                    if viewModel.isTrainingLocked {
                        redFlagTrainingCard
                    } else {
                        todayPlanCard
                    }
                    streakSection
                    healthSummaryCard
                    startTrainingButton
                    recentCheckinsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color.vbCream.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .task { await viewModel.loadAll() }
            .sheet(isPresented: $showManualHealthInput) {
                ManualHealthInputView { steps, heartRate, weight in
                    viewModel.saveManualHealth(steps: steps, heartRate: heartRate, weight: weight)
                    showManualHealthInput = false
                }
            }
        }
    }

    // MARK: - Greeting

    private var greetingSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.greetingText)
                    .font(VBFont.hero)
                    .foregroundStyle(Color.vbMainText)
                Text("今天也要元气满满哦")
                    .vbBody()
            }
            Spacer()
        }
    }

    // MARK: - Today Plan Card

    @ViewBuilder
    private var todayPlanCard: some View {
        if viewModel.hasAssessment {
            StepCard(
                step: 1,
                title: "今日训练计划",
                subtitle: "\(viewModel.exerciseCount) 个动作 · 目标 \(viewModel.targetDuration) 分钟"
            )
        } else {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "checklist")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.vbAccent)
                    Text("先完成健康评估")
                        .vbHeadline()
                }

                Text("评估会先筛查高血压、心脏病和术后风险，再生成适合您的训练计划。")
                    .vbBody()
                    .foregroundStyle(Color.vbSecondaryText)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.vbCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var redFlagTrainingCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.vbWarning)
                Text("暂不建议开始训练")
                    .vbHeadline()
                    .foregroundStyle(Color.vbWarning)
            }

            Text("根据您的健康评估结果，建议先咨询医生。当前可继续查看饮食建议。")
                .vbBody()
                .foregroundStyle(Color.vbSecondaryText)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbWarning.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        VStack(spacing: 16) {
            Text("连续打卡")
                .vbHeadline()

            ProgressRing(
                progress: .constant(viewModel.streakProgress),
                size: 140,
                lineWidth: 14,
                color: .vbAccent
            )

            Text("\(viewModel.streak) 天 / 目标 7 天")
                .vbBody()
                .foregroundStyle(Color.vbSecondaryText)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Health Summary

    private var healthSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今日健康数据")
                .vbHeadline()

            HStack(spacing: 16) {
                healthStatItem(
                    icon: "figure.walk",
                    label: "步数",
                    value: stepsText
                )
                healthStatItem(
                    icon: "heart.fill",
                    label: "心率",
                    value: heartRateText
                )
                healthStatItem(
                    icon: "scalemass.fill",
                    label: "体重",
                    value: weightText
                )
            }

            HStack(spacing: 12) {
                if viewModel.healthKitStatus != .authorized {
                    Button {
                        Task { await viewModel.requestHealthKit() }
                    } label: {
                        Label("连接健康", systemImage: "heart.text.square")
                            .font(VBFont.body)
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .foregroundStyle(Color.vbAccent)
                    .background(Color.vbAccent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    Button {
                        Task { await viewModel.forceRefreshHealthData() }
                    } label: {
                        Label("刷新", systemImage: "arrow.clockwise")
                            .font(VBFont.body)
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .foregroundStyle(Color.vbAccent)
                    .background(Color.vbAccent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Button {
                    showManualHealthInput = true
                } label: {
                    Label("手动录入", systemImage: "square.and.pencil")
                        .font(VBFont.body)
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .foregroundStyle(Color.vbMainText)
                .background(Color.vbSurfaceVariant.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func healthStatItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(Color.vbAccent)
                .frame(height: 36)

            Text(value)
                .font(VBFont.headline)
                .foregroundStyle(Color.vbMainText)

            Text(label)
                .vbCaption()
        }
        .frame(maxWidth: .infinity)
    }

    private var stepsText: String {
        guard let steps = viewModel.healthSummary?.steps, steps > 0 else {
            return "--"
        }
        return "\(steps)"
    }

    private var heartRateText: String {
        guard let hr = viewModel.healthSummary?.heartRate else {
            return "--"
        }
        return String(format: "%.0f", hr)
    }

    private var weightText: String {
        guard let w = viewModel.healthSummary?.weight else {
            return "--"
        }
        return String(format: "%.1f", w)
    }

    // MARK: - Start Training

    private var startTrainingButton: some View {
        Group {
            if viewModel.isTrainingLocked {
                BigButton("查看饮食建议", style: .secondary) {
                    router.selectedTab = .nutrition
                }
            } else if !viewModel.hasAssessment {
                BigButton("开始健康评估") {
                    router.showOnboardingFlow()
                }
            } else {
                BigButton("开始今日训练") {
                    router.navigateToTraining()
                }
            }
        }
    }

    // MARK: - Recent Checkins

    private var recentCheckinsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近打卡")
                .vbHeadline()

            if viewModel.recentCheckins.isEmpty {
                Text("还没有打卡记录，开始训练吧！")
                    .vbBody()
                    .foregroundStyle(Color.vbSecondaryText)
                    .padding(.vertical, 8)
            } else {
                ForEach(viewModel.recentCheckins) { checkin in
                    checkinRow(checkin)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func checkinRow(_ checkin: DailyCheckin) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.vbSuccess)
                .font(.system(size: 24))

            VStack(alignment: .leading, spacing: 2) {
                Text(dateText(checkin.date))
                    .vbBody()
                Text("\(checkin.completedExerciseCount)/\(checkin.totalExerciseCount) 个动作")
                    .vbCaption()
            }

            Spacer()

            Text(durationText(checkin.totalDurationSeconds))
                .font(VBFont.headline)
                .foregroundStyle(Color.vbAccent)
        }
        .padding(.vertical, 4)
    }

    private func dateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    private func durationText(_ seconds: Int) -> String {
        let minutes = seconds / 60
        return "\(minutes) 分钟"
    }
}

private struct ManualHealthInputView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var stepsText = ""
    @State private var heartRateText = ""
    @State private var weightText = ""

    let onSave: (Int?, Double?, Double?) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("今日健康数据") {
                    TextField("步数，例如 3200", text: $stepsText)
                        .keyboardType(.numberPad)
                    TextField("心率，例如 72", text: $heartRateText)
                        .keyboardType(.decimalPad)
                    TextField("体重 kg，例如 62.5", text: $weightText)
                        .keyboardType(.decimalPad)
                }

                Section {
                    Text("没有 Apple Watch 也可以手动填写。留空的项目会保留原有数据。")
                        .font(VBFont.body)
                        .foregroundStyle(Color.vbSecondaryText)
                }
            }
            .navigationTitle("手动录入")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .font(VBFont.body)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(
                            Int(stepsText),
                            Double(heartRateText),
                            Double(weightText)
                        )
                    }
                    .font(VBFont.body)
                    .foregroundStyle(Color.vbAccent)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("HomeView") {
    HomeView()
        .environmentObject(AppRouter(defaults: .standard))
}
