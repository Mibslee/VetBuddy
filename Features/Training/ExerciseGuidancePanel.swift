import SwiftUI

struct ExerciseGuidancePanel: View {
    let exercise: Exercise
    @StateObject private var speechController = GuidanceSpeechController()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Label("动作要点与注意事项", systemImage: "list.bullet.clipboard")
                    .font(VBFont.headline)
                    .foregroundStyle(Color.vbMainText)

                Spacer()

                if UserAppSettings.safetyVoiceEnabled {
                    Button {
                        speechController.toggle(
                            text: exercise.spokenGuidanceText,
                            voiceAssetName: "voice_\(exercise.id)"
                        )
                    } label: {
                        Label(
                            speechController.isSpeaking ? "关闭语音" : "语音朗读",
                            systemImage: speechController.isSpeaking ? "speaker.slash.fill" : "speaker.wave.2.fill"
                        )
                        .font(VBFont.body)
                        .foregroundStyle(speechController.isSpeaking ? Color.vbSecondaryText : Color.vbAccent)
                    }
                    .buttonStyle(.plain)
                    .frame(minHeight: 44)
                    .accessibilityLabel(speechController.isSpeaking ? "关闭动作语音朗读" : "朗读动作要点和注意事项")
                }
            }

            guidanceSection(
                title: "开始前确认",
                notes: exercise.beforeStartNotes,
                icon: "circle.fill",
                color: .vbAccent
            )

            guidanceSection(
                title: "全程记住",
                notes: exercise.alwaysRememberNotes,
                icon: "checkmark.circle.fill",
                color: .vbSuccess
            )

            guidanceSection(
                title: "立即停止",
                notes: exercise.stopConditionNotes,
                icon: "exclamationmark.triangle.fill",
                color: .vbWarning
            )

            Text("仅用于健康管理和动作示范，不构成医学诊断或治疗建议。")
                .font(VBFont.caption)
                .foregroundStyle(Color.vbSecondaryText)
                .padding(.top, 2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onDisappear {
            speechController.stop()
        }
    }

    private func guidanceSection(title: String, notes: [String], icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(VBFont.headline)
                .foregroundStyle(color)

            ForEach(notes, id: \.self) { note in
                bullet(note, icon: icon, color: color)
            }
        }
    }

    private func bullet(_ text: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .padding(.top, 5)

            Text(text)
                .vbBody()
                .foregroundStyle(Color.vbMainText)
        }
    }
}
