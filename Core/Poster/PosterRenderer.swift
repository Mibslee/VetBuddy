import SwiftUI
import UIKit

@MainActor
final class PosterRenderer {

    func render(template: PosterTemplate, data: PosterData) -> UIImage {
        let view = PosterContentView(template: template, data: data)
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        renderer.proposedSize = .init(width: 1080, height: 1920)
        return renderer.uiImage ?? UIImage()
    }
}

// MARK: - Poster Content View

private struct PosterContentView: View {
    let template: PosterTemplate
    let data: PosterData

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy年M月d日"
        df.locale = Locale(identifier: "zh_CN")
        return df
    }

    private var completionText: String {
        guard let completed = data.completedExercises, let total = data.totalExercises, total > 0 else {
            return data.exerciseNames.isEmpty ? "今日训练完成" : "完成 \(data.exerciseNames.count) 个动作"
        }
        return "完成 \(completed)/\(total) 个动作"
    }

    private var completionRate: String {
        guard let completed = data.completedExercises, let total = data.totalExercises, total > 0 else {
            return data.exerciseNames.isEmpty ? "100%" : "\(min(data.exerciseNames.count * 100 / max(data.exerciseNames.count, 1), 100))%"
        }
        return "\(min(completed * 100 / total, 100))%"
    }

    var body: some View {
        ZStack {
            PosterBackground(template: template)

            VStack(alignment: .leading, spacing: 0) {
                header

                Spacer().frame(height: 104)

                heroMetric

                Spacer().frame(height: 42)

                metricGrid

                Spacer().frame(height: 42)

                exerciseSection

                Spacer()

                quoteSection
            }
            .padding(.horizontal, 72)
            .padding(.top, 86)
            .padding(.bottom, 76)
        }
        .frame(width: 1080, height: 1920)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 18) {
                Text("老铁 VetBuddy")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(template.primaryColor.opacity(0.78))
                    .tracking(0.8)

                Text("今日运动报告")
                    .font(.system(size: 76, weight: .black))
                    .foregroundColor(template.primaryColor)
                    .minimumScaleFactor(0.82)
                    .lineLimit(1)

                Text(dateFormatter.string(from: data.date))
                    .font(.system(size: 31, weight: .medium))
                    .foregroundColor(template.primaryColor.opacity(0.62))
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(template.accentColor.opacity(0.16))
                    .frame(width: 132, height: 132)
                Text(completionRate)
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundColor(template.accentColor)
            }
            .background(
                Circle()
                    .fill(Color.white.opacity(0.58))
                    .blur(radius: 16)
                    .frame(width: 160, height: 160)
            )
        }
    }

    private var heroMetric: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 22) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("训练时长")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(template.primaryColor.opacity(0.58))

                    Text(data.totalDuration)
                        .font(.system(size: 96, weight: .black))
                        .foregroundColor(template.primaryColor)
                        .minimumScaleFactor(0.68)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("完成度")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(template.primaryColor.opacity(0.54))
                    Text(completionRate)
                        .font(.system(size: 58, weight: .black))
                        .foregroundColor(template.accentColor)
                }
            }

            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(template.accentColor)
                    .frame(width: 78, height: 8)
                Text(completionText)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(template.primaryColor.opacity(0.76))
            }
        }
        .padding(44)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white.opacity(0.76))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.72), lineWidth: 1.5)
                )
                .shadow(color: template.primaryColor.opacity(0.10), radius: 30, y: 18)
        )
    }

    private var metricGrid: some View {
        HStack(spacing: 26) {
            PosterMetricTile(label: "连续打卡", value: "\(data.totalDays) 天", template: template)
            PosterMetricTile(label: "今日步数", value: data.steps.map { "\($0)" } ?? "已完成", template: template)
            PosterMetricTile(label: "平均心率", value: data.heartRate.map { String(format: "%.0f", $0) + " bpm" } ?? "平稳", template: template)
        }
    }

    private var exerciseSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("今日训练")
                .font(.system(size: 34, weight: .heavy))
                .foregroundColor(template.primaryColor)

            let names = displayExercises
            ForEach(Array(names.enumerated()), id: \.offset) { index, name in
                HStack(spacing: 18) {
                    Text("\(index + 1)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(template.accentColor))

                    Text(name)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(template.primaryColor.opacity(0.86))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
            }
        }
        .padding(36)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.62))
        )
    }

    private var displayExercises: [String] {
        if data.exerciseNames.isEmpty {
            return ["热身活动", "力量训练", "平衡练习", "舒缓放松"]
        }
        return Array(data.exerciseNames.prefix(5))
    }

    private var quoteSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Rectangle()
                .fill(template.accentColor)
                .frame(width: 96, height: 8)

            Text("「\(data.quote)」")
                .font(.system(size: 34, weight: .medium))
                .foregroundColor(template.primaryColor.opacity(0.72))
                .lineSpacing(8)
                .multilineTextAlignment(.leading)

            Text("保持运动，让每一天更有精神")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(template.primaryColor.opacity(0.48))
        }
    }
}

// MARK: - Poster Components

private struct PosterMetricTile: View {
    let label: String
    let value: String
    let template: PosterTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.system(size: 23, weight: .semibold))
                .foregroundColor(template.primaryColor.opacity(0.52))
            Text(value)
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(template.primaryColor)
                .lineLimit(1)
                .minimumScaleFactor(0.66)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, minHeight: 134, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.70))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.60), lineWidth: 1)
                )
        )
    }
}

private struct PosterBackground: View {
    let template: PosterTemplate

    var body: some View {
        ZStack {
            if let uiImage = UIImage.posterBackground(named: template.backgroundImageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 1080, height: 1920)
                    .clipped()
            } else {
                LinearGradient(
                    colors: [template.secondaryColor, template.accentColor.opacity(0.22)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            Color.white.opacity(0.32),
                            Color.white.opacity(0.20)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .ignoresSafeArea()
    }
}

private extension UIImage {
    static func posterBackground(named name: String) -> UIImage? {
        if let image = UIImage(named: name) {
            return image
        }
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: "png",
            subdirectory: "PosterBackgrounds"
        ) else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }
}

private struct MountainPosterArt: View {
    let template: PosterTemplate

    var body: some View {
        ZStack {
            Circle()
                .fill(template.accentColor.opacity(0.16))
                .frame(width: 520, height: 520)
                .offset(x: 300, y: -570)

            InkMountainShape(points: [
                CGPoint(x: 0.02, y: 0.48),
                CGPoint(x: 0.18, y: 0.36),
                CGPoint(x: 0.35, y: 0.43),
                CGPoint(x: 0.52, y: 0.28),
                CGPoint(x: 0.73, y: 0.40),
                CGPoint(x: 1.03, y: 0.30)
            ])
            .fill(template.accentColor.opacity(0.18))

            InkMountainShape(points: [
                CGPoint(x: -0.05, y: 0.57),
                CGPoint(x: 0.22, y: 0.45),
                CGPoint(x: 0.44, y: 0.54),
                CGPoint(x: 0.68, y: 0.38),
                CGPoint(x: 1.05, y: 0.52)
            ])
            .fill(template.primaryColor.opacity(0.08))
            .offset(y: 130)
        }
    }
}

private struct BambooPosterArt: View {
    let template: PosterTemplate

    var body: some View {
        ZStack {
            ForEach(0..<7, id: \.self) { index in
                BambooStem(index: index, template: template)
            }
        }
    }
}

private struct PinePosterArt: View {
    let template: PosterTemplate

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PineBranchShape()
                .stroke(template.accentColor.opacity(0.30), style: StrokeStyle(lineWidth: 22, lineCap: .round, lineJoin: .round))
                .frame(width: 720, height: 520)
                .offset(x: 70, y: -430)

            ForEach(0..<12, id: \.self) { index in
                Capsule()
                    .fill(template.accentColor.opacity(0.22))
                    .frame(width: 18, height: 160)
                    .rotationEffect(.degrees(Double(index) * 15 - 72))
                    .offset(x: CGFloat(index % 4) * 36 - 250, y: CGFloat(index / 4) * 56 - 600)
            }
        }
    }
}

private struct CranePosterArt: View {
    let template: PosterTemplate

    var body: some View {
        ZStack {
            Circle()
                .fill(template.accentColor.opacity(0.12))
                .frame(width: 520, height: 520)
                .offset(x: 250, y: -520)

            CraneWingShape()
                .fill(template.primaryColor.opacity(0.08))
                .frame(width: 620, height: 380)
                .offset(x: 250, y: -160)

            CraneWingShape()
                .fill(template.primaryColor.opacity(0.06))
                .frame(width: 520, height: 320)
                .scaleEffect(x: -1, y: 1)
                .offset(x: -360, y: 460)
        }
    }
}

private struct BambooStem: View {
    let index: Int
    let template: PosterTemplate

    var body: some View {
        ZStack {
            Capsule()
                .fill(template.accentColor.opacity(0.18))
                .frame(width: 26, height: 1060)

            ForEach(0..<7, id: \.self) { joint in
                Capsule()
                    .fill(template.accentColor.opacity(0.22))
                    .frame(width: 72, height: 10)
                    .offset(y: CGFloat(joint) * 150 - 440)
            }
        }
        .rotationEffect(.degrees(Double(index % 3) * 4 - 4))
        .offset(x: CGFloat(index) * 135 - 420, y: CGFloat(index % 2) * 90 - 120)
    }
}

private struct InkMountainShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: CGPoint(x: first.x * rect.width, y: first.y * rect.height))
            for point in points.dropFirst() {
                path.addLine(to: CGPoint(x: point.x * rect.width, y: point.y * rect.height))
            }
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

private struct PineBranchShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY + 90))
            path.addCurve(
                to: CGPoint(x: rect.minX + 90, y: rect.maxY - 80),
                control1: CGPoint(x: rect.maxX - 190, y: rect.minY + 130),
                control2: CGPoint(x: rect.midX, y: rect.maxY - 70)
            )
        }
    }
}

private struct CraneWingShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX + 30, y: rect.midY))
            path.addCurve(
                to: CGPoint(x: rect.maxX - 30, y: rect.minY + 70),
                control1: CGPoint(x: rect.midX - 120, y: rect.minY - 40),
                control2: CGPoint(x: rect.midX + 120, y: rect.minY + 40)
            )
            path.addCurve(
                to: CGPoint(x: rect.minX + 30, y: rect.midY),
                control1: CGPoint(x: rect.maxX - 170, y: rect.maxY - 60),
                control2: CGPoint(x: rect.midX - 120, y: rect.maxY + 20)
            )
            path.closeSubpath()
        }
    }
}

// MARK: - Preview

#Preview {
    PosterContentView(
        template: .mountain,
        data: PosterData(
            date: Date(),
            totalDuration: "25 分钟",
            exerciseNames: ["椅子坐立", "提踵", "桥式"],
            steps: 3200,
            heartRate: 72,
            quote: "今天也是元气满满的一天！",
            totalDays: 15,
            completedExercises: 5,
            totalExercises: 5
        )
    )
}
