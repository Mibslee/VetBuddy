import SwiftUI

/// Completion card shown after finishing all exercises in a session.
struct TrainingCompleteView: View {

    @EnvironmentObject private var router: AppRouter

    let durationSeconds: Int
    let exerciseCount: Int
    let totalExercises: Int

    @State private var showPoster = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)

                successIcon
                successMessage
                statsCard
                actionButtons

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.vbSuccess.opacity(0.05).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showPoster) {
            PosterPreviewView(
                data: PosterData(
                    date: Date(),
                    totalDuration: durationText,
                    exerciseNames: [],
                    steps: nil,
                    heartRate: nil,
                    quote: "坚持就是胜利！",
                    totalDays: 1,
                    completedExercises: exerciseCount,
                    totalExercises: totalExercises
                )
            )
        }
    }

    // MARK: - Success Icon

    private var successIcon: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 80, weight: .light))
            .foregroundStyle(Color.vbSuccess)
            .frame(width: 130, height: 130)
            .background(Color.vbSuccess.opacity(0.12))
            .clipShape(Circle())
    }

    // MARK: - Success Message

    private var successMessage: some View {
        VStack(spacing: 12) {
            Text("太棒了！今日训练完成！")
                .font(VBFont.title)
                .foregroundStyle(Color.vbMainText)
                .multilineTextAlignment(.center)

            Text("您又向健康迈进了一步")
                .vbBody()
                .foregroundStyle(Color.vbSecondaryText)
        }
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                statItem(label: "运动时长", value: durationText)
                statItem(label: "完成动作", value: "\(exerciseCount)/\(totalExercises)")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(VBFont.title)
                .foregroundStyle(Color.vbAccent)
            Text(label)
                .vbCaption()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 16) {
            BigButton("打卡") {
                router.selectedTab = .home
            }

            BigButton("生成海报", style: .secondary) {
                showPoster = true
            }

            Button("返回首页") {
                router.selectedTab = .home
            }
            .font(VBFont.body)
            .foregroundStyle(Color.vbSecondaryText)
            .frame(minHeight: 60)
        }
    }

    // MARK: - Helpers

    private var durationText: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        if minutes > 0 {
            return "\(minutes) 分 \(seconds) 秒"
        }
        return "\(seconds) 秒"
    }
}

// MARK: - Preview

#Preview("Training Complete") {
    NavigationStack {
        TrainingCompleteView(
            durationSeconds: 1234,
            exerciseCount: 5,
            totalExercises: 5
        )
        .environmentObject(AppRouter(defaults: .standard))
    }
}
