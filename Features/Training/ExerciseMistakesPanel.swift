import SwiftUI

struct ExerciseMistakesPanel: View {
    let exercise: Exercise

    var body: some View {
        let mistakes = exercise.commonMistakes
        if !mistakes.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Label("常见错误", systemImage: "exclamationmark.triangle.fill")
                    .font(VBFont.headline)
                    .foregroundStyle(Color.vbMainText)

                ForEach(mistakes) { mistake in
                    mistakeCard(mistake)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.vbWarning.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func mistakeCard(_ mistake: ExerciseMistake) -> some View {
        HStack(alignment: .top, spacing: 12) {
            mistakeImage(mistake)

            VStack(alignment: .leading, spacing: 8) {
                Text(mistake.title)
                    .font(VBFont.headline)
                    .foregroundStyle(Color.vbWarning)

                Text(mistake.wrongCue)
                    .font(VBFont.body)
                    .foregroundStyle(Color.vbMainText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.vbSuccess)
                        .padding(.top, 4)
                    Text(mistake.correction)
                        .font(VBFont.caption)
                        .foregroundStyle(Color.vbSecondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    private func mistakeImage(_ mistake: ExerciseMistake) -> some View {
        if let image = UIImage(named: mistake.imageName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .accessibilityHidden(true)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.vbWarning.opacity(0.12))
                Image(systemName: "xmark.octagon.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Color.vbWarning)
            }
            .frame(width: 96, height: 96)
            .accessibilityHidden(true)
        }
    }
}
