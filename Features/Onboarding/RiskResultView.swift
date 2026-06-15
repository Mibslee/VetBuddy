import SwiftUI

/// Result screen displayed after the health questionnaire.
/// Shows risk level with appropriate messaging and styling.
struct RiskResultView: View {

    let result: AssessmentResult
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)
                statusIcon
                statusMessage
                detailCard
                continueButton
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
        }
        .background(backgroundColor.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Status Icon

    private var statusIcon: some View {
        Image(systemName: iconName)
            .font(.system(size: 72, weight: .light))
            .foregroundStyle(iconColor)
            .frame(width: 120, height: 120)
            .background(iconColor.opacity(0.12))
            .clipShape(Circle())
    }

    // MARK: - Status Message

    private var statusMessage: some View {
        VStack(spacing: 12) {
            Text(titleText)
                .font(VBFont.title)
                .foregroundStyle(Color.vbMainText)
                .multilineTextAlignment(.center)

            Text(subtitleText)
                .font(VBFont.body)
                .foregroundStyle(Color.vbSecondaryText)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Detail Card

    private var detailCard: some View {
        VStack(spacing: 16) {
            riskBadge
            fitnessBadge
            if result.riskLevel != .redFlag {
                Divider()
                detailRow(label: "风险等级", value: riskLevelText)
                detailRow(label: "体能等级", value: fitnessLevelText)
            }
            if result.hasDiabetes {
                Divider()
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(Color.vbAccent)
                    Text("检测到糖尿病，饮食计划将做相应调整")
                        .font(VBFont.caption)
                        .foregroundStyle(Color.vbSecondaryText)
                }
            }
        }
        .padding(20)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Badges

    private var riskBadge: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(riskColor)
                .frame(width: 12, height: 12)
            Text(riskLevelText)
                .font(VBFont.headline)
                .foregroundStyle(riskColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(riskColor.opacity(0.1))
        .clipShape(Capsule())
    }

    @ViewBuilder
    private var fitnessBadge: some View {
        if result.riskLevel != .redFlag {
            Text(fitnessLevelText)
                .font(VBFont.headline)
                .foregroundStyle(Color.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.vbAccent)
                .clipShape(Capsule())
        }
    }

    // MARK: - Detail Row

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(VBFont.body)
                .foregroundStyle(Color.vbSecondaryText)
            Spacer()
            Text(value)
                .font(VBFont.body)
                .foregroundStyle(Color.vbMainText)
        }
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        BigButton(buttonTitle) {
            onContinue()
        }
        .padding(.top, 8)
    }

    // MARK: - Text Helpers

    private var titleText: String {
        switch result.riskLevel {
        case .standard:
            return "太好了！您适合开始训练"
        case .caution:
            return "建议从低强度开始"
        case .redFlag:
            return "建议咨询医生后再开始运动"
        }
    }

    private var subtitleText: String {
        switch result.riskLevel {
        case .standard:
            return "根据您的健康评估，您可以安全地开始日常锻炼计划。"
        case .caution:
            return "根据您的健康状况，建议您在运动时注意身体反应，循序渐进。"
        case .redFlag:
            return "您的健康状况需要医生的专业评估，建议先咨询医生再决定运动方案。您可以先使用饮食管理功能。"
        }
    }

    private var riskLevelText: String {
        switch result.riskLevel {
        case .standard: return "标准模式"
        case .caution: return "谨慎模式"
        case .redFlag: return "红旗禁止"
        }
    }

    private var fitnessLevelText: String {
        switch result.fitnessLevel {
        case .L1: return "L1 · 入门级"
        case .L2: return "L2 · 进阶级"
        case .L3: return "L3 · 活跃级"
        }
    }

    private var buttonTitle: String {
        result.riskLevel == .redFlag ? "查看饮食建议" : "进入首页"
    }

    // MARK: - Style Helpers

    private var iconName: String {
        switch result.riskLevel {
        case .standard: return "checkmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .redFlag: return "xmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch result.riskLevel {
        case .standard: return Color.vbSuccess
        case .caution: return Color.orange
        case .redFlag: return Color.vbWarning
        }
    }

    private var riskColor: Color {
        switch result.riskLevel {
        case .standard: return Color.vbSuccess
        case .caution: return Color.orange
        case .redFlag: return Color.vbWarning
        }
    }

    private var backgroundColor: Color {
        switch result.riskLevel {
        case .standard: return Color.vbSuccess.opacity(0.05)
        case .caution: return Color.orange.opacity(0.05)
        case .redFlag: return Color.vbWarning.opacity(0.05)
        }
    }
}

// MARK: - Preview

#Preview("Standard Result") {
    RiskResultView(
        result: AssessmentResult(
            date: Date(),
            riskLevel: .standard,
            fitnessLevel: .L2,
            hasHeartDisease: false,
            hasCKD: false,
            hasDiabetes: false,
            ageRange: AgeRange.range65to70.rawValue
        )
    ) {}
}

#Preview("Caution Result") {
    RiskResultView(
        result: AssessmentResult(
            date: Date(),
            riskLevel: .caution,
            fitnessLevel: .L1,
            hasHeartDisease: false,
            hasCKD: true,
            hasDiabetes: true,
            ageRange: AgeRange.range70to75.rawValue
        )
    ) {}
}

#Preview("Red Flag Result") {
    RiskResultView(
        result: AssessmentResult(
            date: Date(),
            riskLevel: .redFlag,
            fitnessLevel: .L1,
            hasHeartDisease: true,
            hasCKD: false,
            hasDiabetes: false,
            ageRange: AgeRange.range75plus.rawValue
        )
    ) {}
}
