import SwiftUI

/// Profile and settings screen.
struct ProfileView: View {

    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var speechController = GuidanceSpeechController()
    @EnvironmentObject private var router: AppRouter

    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    userInfoSection
                    familySummarySection
                    bodyProfileSection
                    healthKitSection
                    settingsSection
                    aboutSection
                    disclaimerSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color.vbCream.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                viewModel.loadProfile()
                Task { await viewModel.loadFamilySummary() }
            }
            .alert("确定重新评估？", isPresented: $showResetAlert) {
                Button("确定", role: .destructive) {
                    viewModel.resetAssessment()
                    router.resetAssessment()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("重新评估将清除之前的评估结果。")
            }
        }
    }

    // MARK: - User Info Section

    private var userInfoSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.vbAccent)

            if let assessment = viewModel.assessment {
                HStack(spacing: 12) {
                    riskBadge(assessment.riskLevel)
                    fitnessBadge(assessment.fitnessLevel)
                }

                Text("评估日期: \(formatDate(assessment.date))")
                    .vbCaption()
            } else {
                Text("尚未完成评估")
                    .vbBody()
                    .foregroundStyle(Color.vbSecondaryText)
            }

            BigButton("重新评估", style: .secondary) {
                showResetAlert = true
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func riskBadge(_ level: RiskLevel) -> some View {
        let color: Color = switch level {
        case .standard: .vbSuccess
        case .caution: .orange
        case .redFlag: .vbWarning
        }
        let text: String = switch level {
        case .standard: "标准"
        case .caution: "谨慎"
        case .redFlag: "红旗"
        }

        return Text(text)
            .font(VBFont.body)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color)
            .clipShape(Capsule())
    }

    private func fitnessBadge(_ level: FitnessLevel) -> some View {
        Text(viewModel.fitnessLevelText)
            .font(VBFont.body)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.vbAccent)
            .clipShape(Capsule())
    }

    // MARK: - Family Summary

    private var familySummarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.vbAccent)
                Text("家属查看")
                    .vbHeadline()
                Spacer()
                Text("本机概览")
                    .vbCaption()
                    .foregroundStyle(Color.vbSecondaryText)
            }

            Text("这些信息只在本机显示，适合当面给家人了解最近状态。")
                .font(VBFont.caption)
                .foregroundStyle(Color.vbSecondaryText)

            HStack(spacing: 10) {
                summaryTile(title: "近 7 天训练", value: "\(viewModel.familySummary.trainingDays) 天")
                summaryTile(title: "今日饮食", value: "\(viewModel.familySummary.todayMealCount) 项")
                summaryTile(title: "今日蛋白", value: "\(formatGrams(viewModel.familySummary.todayProteinG))g")
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "figure.walk.circle.fill")
                    .foregroundStyle(Color.vbSuccess)
                    .font(.system(size: 18))
                    .padding(.top, 1)
                Text("最近一次训练：\(viewModel.familySummary.latestTrainingText)")
                    .font(VBFont.caption)
                    .foregroundStyle(Color.vbSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func summaryTile(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(VBFont.headline)
                .foregroundStyle(Color.vbMainText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            Text(title)
                .font(VBFont.caption)
                .foregroundStyle(Color.vbSecondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 68)
        .background(Color.vbCream.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: - HealthKit Section

    private var bodyProfileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "person.text.rectangle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.vbAccent)
                Text("营养估算资料")
                    .vbHeadline()
                Spacer()
            }

            Text("用于计算热量和蛋白质等目标，仅保存在本机。未填写时会使用保守平均值。")
                .font(VBFont.caption)
                .foregroundStyle(Color.vbSecondaryText)

            Picker("性别", selection: Binding(
                get: { viewModel.biologicalSex },
                set: { viewModel.setBiologicalSex($0) }
            )) {
                ForEach(BiologicalSex.allCases, id: \.self) { sex in
                    Text(sex.displayName).tag(sex)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("身高")
                        .vbBody()
                    Spacer()
                    Text(viewModel.heightCM > 0 ? "\(Int(viewModel.heightCM)) cm" : "未填写")
                        .font(VBFont.body)
                        .foregroundStyle(Color.vbSecondaryText)
                }

                Slider(
                    value: Binding(
                        get: { viewModel.heightCM > 0 ? viewModel.heightCM : 160 },
                        set: { viewModel.setHeightCM($0.rounded()) }
                    ),
                    in: 140...185,
                    step: 1
                )
                .tint(Color.vbAccent)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var healthKitSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.vbAccent)
                Text("Apple 健康")
                    .vbHeadline()
                Spacer()
                Text(viewModel.healthKitStatusText)
                    .vbBody()
                    .foregroundStyle(viewModel.healthKitStatusColor)
            }

            if viewModel.healthKitStatus != .authorized {
                BigButton("连接 Apple 健康", style: .secondary) {
                    Task { await viewModel.requestHealthKit() }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: 0) {
            settingToggleRow(
                icon: "speaker.wave.2.fill",
                title: "语音总开关",
                isOn: viewModel.soundEnabled,
                action: viewModel.toggleSound
            )
            Divider().padding(.leading, 52)
            settingToggleRow(
                icon: "metronome.fill",
                title: "训练节奏语音",
                isOn: viewModel.rhythmVoiceEnabled,
                action: viewModel.toggleRhythmVoice
            )
            Divider().padding(.leading, 52)
            settingToggleRow(
                icon: "list.bullet.clipboard.fill",
                title: "注意事项语音",
                isOn: viewModel.safetyVoiceEnabled,
                action: viewModel.toggleSafetyVoice
            )
            Divider().padding(.leading, 52)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "speedometer")
                        .foregroundStyle(Color.vbAccent)
                        .frame(width: 32)
                    Text("语速")
                        .vbBody()
                    Spacer()
                    Text(viewModel.speechRate < 0.43 ? "慢" : "标准")
                        .vbBody()
                        .foregroundStyle(Color.vbSecondaryText)
                }
                Slider(
                    value: Binding(
                        get: { viewModel.speechRate },
                        set: { viewModel.setSpeechRate($0) }
                    ),
                    in: 0.34...0.48
                )
                .tint(Color.vbAccent)
            }
            .padding(20)
            Divider().padding(.leading, 52)
            Button {
                speechController.toggle(text: "老铁 VetBuddy 语音试听。训练时如果听不清，可以调高手机音量，或在这里调整语速。")
            } label: {
                HStack {
                    Image(systemName: speechController.isSpeaking ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .foregroundStyle(Color.vbAccent)
                        .frame(width: 32)
                    Text(speechController.isSpeaking ? "停止试听" : "试听语音")
                        .vbBody()
                    Spacer()
                    Text("训练前检查音量")
                        .font(VBFont.caption)
                        .foregroundStyle(Color.vbSecondaryText)
                }
                .padding(20)
                .frame(minHeight: 60)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.soundEnabled)
            .opacity(viewModel.soundEnabled ? 1 : 0.45)
        }
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func settingToggleRow(icon: String, title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.vbAccent)
                .frame(width: 32)
            Text(title)
                .vbBody()
            Spacer()
            Toggle("", isOn: Binding(get: { isOn }, set: { _ in action() }))
                .labelsHidden()
                .tint(Color.vbAccent)
        }
        .padding(20)
        .frame(minHeight: 60)
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(spacing: 0) {
            aboutRow(label: "版本", value: appVersion)
            Divider().padding(.leading, 52)
            aboutRow(label: "开发者", value: "ShaneStudio")
            Divider().padding(.leading, 52)
            Button {
                // Placeholder for privacy policy
            } label: {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(Color.vbAccent)
                        .frame(width: 32)
                    Text("隐私政策")
                        .vbBody()
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.vbSecondaryText)
                }
                .padding(20)
                .frame(minHeight: 60)
                .contentShape(Rectangle())
            }
        }
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func aboutRow(label: String, value: String) -> some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.vbAccent)
                .frame(width: 32)
            Text(label)
                .vbBody()
            Spacer()
            Text(value)
                .vbBody()
                .foregroundStyle(Color.vbSecondaryText)
        }
        .padding(20)
        .frame(minHeight: 60)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private func formatGrams(_ value: Double) -> String {
        if value.rounded() == value {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }

    // MARK: - Disclaimer Section

    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(Color.vbWarning)
                Text("免责声明")
                    .vbCaption()
                    .foregroundStyle(Color.vbWarning)
            }
            Text("本应用提供的运动和饮食建议仅供参考，不构成医疗建议。如有健康问题，请咨询专业医生。使用本应用进行锻炼时，请根据自身情况量力而行。")
                .vbCaption()
                .foregroundStyle(Color.vbSecondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbWarning.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("Profile") {
    ProfileView()
        .environmentObject(AppRouter(defaults: .standard))
}
