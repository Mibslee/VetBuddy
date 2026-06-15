import AVFoundation
import AVKit
import SwiftUI
import UIKit

struct ExerciseMediaView: View {
    let exercise: Exercise
    let height: CGFloat

    @ViewBuilder
    var body: some View {
        if let sequence = ExerciseIllustrationAsset.sequence(for: exercise.id),
           let image = UIImage(named: sequence.fileName) {
            ExerciseIllustrationSequenceView(
                image: image,
                sheet: sequence.sheet,
                frameDuration: sequence.frameDuration,
                layout: sequence.layout,
                guidance: sequence.guidance
            )
            .id(sequence.fileName)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(exercise.nameCN)动作分解图解")
        } else if let videoName = ExerciseVideoAsset.fileName(for: exercise.id),
           let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            LoopingVideoPlayer(url: url)
                .frame(height: height)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(radius: 4)
                        .padding(14)
                }
                .accessibilityLabel("\(exercise.nameCN)动作指导视频")
        } else if Bundle.main.url(forResource: exercise.id, withExtension: "usdz") != nil {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.vbCardBackground)

                USDZModelView(modelName: exercise.id)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                LinearGradient(
                    colors: [Color.clear, Color.vbCardBackground.opacity(0.6)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 60)
            }
            .frame(height: height)
        } else {
            ExerciseGuideAnimationView(exercise: exercise, height: height)
        }
    }
}

private struct ExerciseSequenceAsset {
    let fileName: String
    let sheet: ExerciseFrameSheet
    let frameDuration: TimeInterval
    let layout: ExerciseIllustrationLayout
    let guidance: [ExerciseFrameGuidance]

    var frameCount: Int { sheet.frameCount }
}

private enum ExerciseIllustrationAsset {
    static func sequence(for exerciseId: String) -> ExerciseSequenceAsset? {
        switch exerciseId {
        case "sit_to_stand":
            return ExerciseSequenceAsset(
                fileName: "sit_to_stand_sequence",
                sheet: .verticalColumns(5),
                frameDuration: 2.5,
                layout: .standing(imageSide: .leading),
                guidance: [
                    ExerciseFrameGuidance(title: "坐稳准备", primary: "坐在椅子前半段，双脚踩实，与肩同宽。", secondary: "膝盖对准脚尖，手可轻放大腿。"),
                    ExerciseFrameGuidance(title: "身体前倾", primary: "从髋部轻轻前倾，胸口向前而不是弯腰塌背。", secondary: "重心移到脚掌，准备站起。"),
                    ExerciseFrameGuidance(title: "站直收髋", primary: "用腿和臀部发力站起，站到身体完全伸直。", secondary: "不要猛起，头晕时立即坐回。"),
                    ExerciseFrameGuidance(title: "臀部后坐", primary: "侧面看，先把臀部向后送，像找椅子一样坐下。", secondary: "膝盖尽量不要超过脚尖。"),
                    ExerciseFrameGuidance(title: "慢慢坐下", primary: "控制速度坐回椅子，不要突然摔坐。", secondary: "腰背保持自然直立，全程呼吸平稳。")
                ]
            )
        case "calf_raise":
            return ExerciseSequenceAsset(
                fileName: "calf_raise_sequence",
                sheet: .verticalColumns(4),
                frameDuration: 2.5,
                layout: .standing(imageSide: .leading),
                guidance: [
                    ExerciseFrameGuidance(
                        title: "准备",
                        primary: "前脚掌稳稳踩在防滑垫块上，脚跟自然下沉。",
                        secondary: "一只手轻扶墙，身体站直，目视前方。"
                    ),
                    ExerciseFrameGuidance(
                        title: "慢慢抬起",
                        primary: "呼气，脚跟缓慢离开垫块，重心保持在前脚掌。",
                        secondary: "膝盖微松，不要锁死，肩颈放松。"
                    ),
                    ExerciseFrameGuidance(
                        title: "顶点停一拍",
                        primary: "脚跟抬到舒适高度即可，感觉小腿发力。",
                        secondary: "保持扶墙稳定，不要身体前后晃动。"
                    ),
                    ExerciseFrameGuidance(
                        title: "控制落下",
                        primary: "吸气，脚跟慢慢落回起始位置，不要突然砸下。",
                        secondary: "全程慢起慢落，垫块必须稳固不滑动。"
                    )
                ]
            )
        case "wall_sit":
            return ExerciseSequenceAsset(
                fileName: "wall_sit_sequence",
                sheet: .verticalColumns(4),
                frameDuration: 2.5,
                layout: .standing(imageSide: .leading),
                guidance: [
                    ExerciseFrameGuidance(title: "靠墙站好", primary: "背部、肩部轻贴墙，双脚向前离墙一小步。", secondary: "脚尖朝前，双脚与髋同宽。"),
                    ExerciseFrameGuidance(title: "缓慢下滑", primary: "沿墙慢慢下滑，膝盖朝脚尖方向弯曲。", secondary: "不要一下蹲太深，先找舒适角度。"),
                    ExerciseFrameGuidance(title: "稳定保持", primary: "保持浅到中等深度，膝盖不超过脚尖。", secondary: "下背贴墙，有膝痛就立刻减小角度。"),
                    ExerciseFrameGuidance(title: "慢慢站回", primary: "脚掌踩稳，沿墙缓慢推回站姿。", secondary: "不要憋气，也不要用膝盖硬顶。")
                ]
            )
        case "straight_leg_raise":
            return ExerciseSequenceAsset(
                fileName: "straight_leg_raise_sequence",
                sheet: .grid(columns: 2, rows: 2),
                frameDuration: 2.5,
                layout: .floor,
                guidance: [
                    ExerciseFrameGuidance(title: "仰卧准备", primary: "一侧膝盖弯曲踩地，训练腿伸直放在垫上。", secondary: "腰背自然贴近垫子，双手放松。"),
                    ExerciseFrameGuidance(title: "核心收紧", primary: "先收紧腹部，再慢慢抬起伸直的腿。", secondary: "膝盖保持伸直但不要硬锁死。"),
                    ExerciseFrameGuidance(title: "抬到合适高度", primary: "抬到与另一侧膝盖差不多高即可。", secondary: "不要追求越高越好，腰不要拱起。"),
                    ExerciseFrameGuidance(title: "控制放下", primary: "慢慢放回垫面，不要让腿直接落下。", secondary: "全程保持骨盆稳定。")
                ]
            )
        case "side_leg_raise":
            return ExerciseSequenceAsset(
                fileName: "side_leg_raise_sequence",
                sheet: .grid(columns: 2, rows: 2),
                frameDuration: 2.5,
                layout: .floor,
                guidance: [
                    ExerciseFrameGuidance(title: "侧卧对齐", primary: "身体侧卧成一直线，下方腿可微弯保持稳定。", secondary: "髋部上下叠放，不要向后翻。"),
                    ExerciseFrameGuidance(title: "慢慢抬腿", primary: "上方腿伸直向上抬，脚尖略朝前。", secondary: "动作来自髋部，不要甩腿。"),
                    ExerciseFrameGuidance(title: "控制高度", primary: "抬到约 45 度或舒适高度即可。", secondary: "保持骨盆稳定，身体不要滚动。"),
                    ExerciseFrameGuidance(title: "慢慢落回", primary: "缓慢放下到双腿叠放位置。", secondary: "下落也要控制，不借惯性。")
                ]
            )
        case "glute_bridge":
            return ExerciseSequenceAsset(
                fileName: "glute_bridge_sequence",
                sheet: .grid(columns: 2, rows: 2),
                frameDuration: 2.5,
                layout: .floor,
                guidance: [
                    ExerciseFrameGuidance(title: "屈膝准备", primary: "仰卧屈膝，双脚踩实，与髋同宽。", secondary: "手臂放松，脚跟不要离臀部太远。"),
                    ExerciseFrameGuidance(title: "抬起骨盆", primary: "脚跟发力，臀部慢慢离开垫面。", secondary: "肋骨收住，避免腰先用力。"),
                    ExerciseFrameGuidance(title: "保持一条线", primary: "肩、髋、膝尽量成一直线，臀部发力。", secondary: "不要过度挺腰或把肚子顶太高。"),
                    ExerciseFrameGuidance(title: "慢慢落下", primary: "控制臀部回到垫面，再开始下一次。", secondary: "脚掌全程踩稳，呼吸保持平稳。")
                ]
            )
        case "standing_march":
            return ExerciseSequenceAsset(
                fileName: "standing_march_sequence",
                sheet: .verticalColumns(4),
                frameDuration: 2.5,
                layout: .standing(imageSide: .leading),
                guidance: [
                    ExerciseFrameGuidance(title: "扶椅站稳", primary: "双手轻扶稳固椅背，身体站直。", secondary: "椅子不能滑动，脚下保持干燥。"),
                    ExerciseFrameGuidance(title: "抬右腿", primary: "慢慢抬起一侧膝盖，到舒适高度即可。", secondary: "躯干保持直立，不向后仰。"),
                    ExerciseFrameGuidance(title: "换另一侧", primary: "右脚踩稳后，再抬起另一侧膝盖。", secondary: "左右交替，节奏慢而稳。"),
                    ExerciseFrameGuidance(title: "回到站姿", primary: "双脚回到地面，确认平衡后继续。", secondary: "如果晃动明显，降低抬腿高度。")
                ]
            )
        case "tandem_walk":
            return ExerciseSequenceAsset(
                fileName: "tandem_walk_sequence",
                sheet: .verticalColumns(5),
                frameDuration: 2.5,
                layout: .standing(imageSide: .leading),
                guidance: [
                    ExerciseFrameGuidance(title: "靠墙准备", primary: "站在直线旁，一只手轻扶墙面或扶手。", secondary: "先确认周围没有绊倒风险。"),
                    ExerciseFrameGuidance(title: "脚跟接脚尖", primary: "前脚脚跟尽量贴近后脚脚尖，走在直线上。", secondary: "眼睛看前方，不要一直低头。"),
                    ExerciseFrameGuidance(title: "慢慢转移重心", primary: "身体保持直立，重心缓慢移到前脚。", secondary: "手只是辅助，避免用力拉墙。"),
                    ExerciseFrameGuidance(title: "继续下一步", primary: "下一步仍然脚跟接脚尖，步子小一点更稳。", secondary: "宁可慢，也不要抢步。"),
                    ExerciseFrameGuidance(title: "稳定结束", primary: "停下时先站稳，再转身或离开墙边。", secondary: "头晕或明显晃动时立刻停止。")
                ]
            )
        default:
            return nil
        }
    }
}

private enum ExerciseIllustrationLayout {
    case standing(imageSide: HorizontalEdge)
    case floor
}

private enum ExerciseFrameSheet {
    case verticalColumns(Int)
    case grid(columns: Int, rows: Int)

    var frameCount: Int {
        switch self {
        case .verticalColumns(let count):
            return count
        case .grid(let columns, let rows):
            return columns * rows
        }
    }
}

private struct ExerciseFrameGuidance {
    let title: String
    let primary: String
    let secondary: String
}

private enum ExerciseVideoAsset {
    static func fileName(for exerciseId: String) -> String? {
        switch exerciseId {
        case "calf_raise":
            return "calf_raise_pexels_32115656_preview"
        default:
            return nil
        }
    }
}

private struct ExerciseIllustrationSequenceView: View {
    let frames: [UIImage]
    let frameDuration: TimeInterval
    let layout: ExerciseIllustrationLayout
    let guidance: [ExerciseFrameGuidance]
    @State private var sequenceStartDate = Date()

    init(
        image: UIImage,
        sheet: ExerciseFrameSheet,
        frameDuration: TimeInterval,
        layout: ExerciseIllustrationLayout,
        guidance: [ExerciseFrameGuidance]
    ) {
        self.frames = image.splitIntoFrames(sheet: sheet)
        self.frameDuration = frameDuration
        self.layout = layout
        self.guidance = guidance
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.25)) { timeline in
            let currentFrame = frameIndex(for: timeline.date, startedAt: sequenceStartDate)
            let currentGuidance = guidanceText(for: currentFrame)

            GeometryReader { proxy in
                content(
                    frame: frames[currentFrame],
                    guidance: currentGuidance,
                    currentFrame: currentFrame,
                    size: proxy.size
                )
            }
        }
        .onAppear {
            sequenceStartDate = Date()
        }
    }

    @ViewBuilder
    private func content(
        frame: UIImage,
        guidance: ExerciseFrameGuidance,
        currentFrame: Int,
        size: CGSize
    ) -> some View {
        switch layout {
        case .standing(let imageSide):
            standingLayout(
                frame: frame,
                guidance: guidance,
                currentFrame: currentFrame,
                imageSide: imageSide,
                size: size
            )
        case .floor:
            floorLayout(
                frame: frame,
                guidance: guidance,
                currentFrame: currentFrame,
                size: size
            )
        }
    }

    private func standingLayout(
        frame: UIImage,
        guidance: ExerciseFrameGuidance,
        currentFrame: Int,
        imageSide: HorizontalEdge,
        size: CGSize
    ) -> some View {
        let imageWidth = size.width * 0.52
        let textWidth = size.width - imageWidth

        return ZStack(alignment: .bottom) {
            illustrationBackground

            HStack(spacing: 0) {
                if imageSide == .leading {
                    imagePanel(frame, width: imageWidth, height: size.height)
                    guidancePanel(guidance, width: textWidth, height: size.height)
                } else {
                    guidancePanel(guidance, width: textWidth, height: size.height)
                    imagePanel(frame, width: imageWidth, height: size.height)
                }
            }

            edgeBlend(
                for: imageSide,
                imageWidth: imageWidth,
                canvasWidth: size.width,
                canvasHeight: size.height
            )

            frameDots(currentFrame: currentFrame)
                .padding(.bottom, 12)
        }
    }

    private func floorLayout(
        frame: UIImage,
        guidance: ExerciseFrameGuidance,
        currentFrame: Int,
        size: CGSize
    ) -> some View {
        ZStack(alignment: .bottom) {
            illustrationBackground

            VStack(spacing: 0) {
                guidancePanel(guidance, width: size.width, height: size.height * 0.36)
                imagePanel(frame, width: size.width, height: size.height * 0.64)
            }

            LinearGradient(
                colors: [Color.vbCardBackground.opacity(0.96), Color.vbCardBackground.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 32)
            .offset(y: size.height * 0.36 - 16)

            frameDots(currentFrame: currentFrame)
                .padding(.bottom, 12)
        }
    }

    private var illustrationBackground: some View {
        LinearGradient(
            colors: [
                Color.vbCardBackground,
                Color.vbCream.opacity(0.72),
                Color.vbDistantMountain.opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func imagePanel(_ frame: UIImage, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Image(uiImage: frame)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .blur(radius: 18)
                .opacity(0.22)
                .clipped()
                .accessibilityHidden(true)

            Image(uiImage: frame)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .padding(.vertical, 10)
                .accessibilityHidden(true)
        }
        .frame(width: width, height: height)
        .clipped()
    }

    private func guidancePanel(_ guidance: ExerciseFrameGuidance, width: CGFloat, height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(guidance.title)
                .font(.system(.subheadline, design: .default).weight(.bold))
                .foregroundStyle(Color.vbAccent)
                .lineLimit(1)

            Text(guidance.primary)
                .font(.system(.callout, design: .default).weight(.semibold))
                .foregroundStyle(Color.vbMainText)
                .fixedSize(horizontal: false, vertical: true)

            Text(guidance.secondary)
                .font(.system(.footnote, design: .default))
                .foregroundStyle(Color.vbSecondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 20)
        .padding(.leading, 14)
        .padding(.trailing, 16)
        .frame(width: width, height: height, alignment: .topLeading)
    }

    private func edgeBlend(
        for imageSide: HorizontalEdge,
        imageWidth: CGFloat,
        canvasWidth: CGFloat,
        canvasHeight: CGFloat
    ) -> some View {
        LinearGradient(
            colors: [
                Color.vbCardBackground.opacity(0),
                Color.vbCardBackground.opacity(0.34),
                Color.vbCream.opacity(0.50)
            ],
            startPoint: imageSide == .leading ? .leading : .trailing,
            endPoint: imageSide == .leading ? .trailing : .leading
        )
        .frame(width: 30, height: canvasHeight)
        .position(
            x: imageSide == .leading ? imageWidth - 8 : canvasWidth - imageWidth + 8,
            y: canvasHeight / 2
        )
        .allowsHitTesting(false)
    }

    private func frameIndex(for date: Date, startedAt startDate: Date) -> Int {
        guard !frames.isEmpty, frameDuration > 0 else { return 0 }
        let phase = max(0, date.timeIntervalSince(startDate)) / frameDuration
        return Int(phase.rounded(.down)) % frames.count
    }

    private func guidanceText(for frameIndex: Int) -> ExerciseFrameGuidance {
        guard !guidance.isEmpty else {
            return ExerciseFrameGuidance(title: "动作要点", primary: "保持动作缓慢稳定。", secondary: "如有不适，请立即停止。")
        }

        return guidance[min(frameIndex, guidance.count - 1)]
    }

    private func frameDots(currentFrame: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<frames.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentFrame ? Color.white : Color.white.opacity(0.45))
                    .frame(width: index == currentFrame ? 18 : 7, height: 7)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.vbMainText.opacity(0.26))
        .clipShape(Capsule())
    }
}

private extension UIImage {
    func splitIntoFrames(sheet: ExerciseFrameSheet) -> [UIImage] {
        switch sheet {
        case .verticalColumns(let count):
            return splitIntoVerticalFrames(count: count)
        case .grid(let columns, let rows):
            return splitIntoGridFrames(columns: columns, rows: rows)
        }
    }

    func splitIntoVerticalFrames(count: Int) -> [UIImage] {
        guard count > 1, let cgImage else { return [self] }

        let frameWidth = cgImage.width / count
        guard frameWidth > 0 else { return [self] }

        let frames = (0..<count).compactMap { index -> UIImage? in
            let cropRect = CGRect(
                x: index * frameWidth,
                y: 0,
                width: frameWidth,
                height: cgImage.height
            )

            guard let croppedImage = cgImage.cropping(to: cropRect) else { return nil }
            return UIImage(cgImage: croppedImage, scale: scale, orientation: imageOrientation)
        }

        return frames.isEmpty ? [self] : frames
    }

    func splitIntoGridFrames(columns: Int, rows: Int) -> [UIImage] {
        guard columns > 0, rows > 0, let cgImage else { return [self] }

        let frameWidth = cgImage.width / columns
        let frameHeight = cgImage.height / rows
        guard frameWidth > 0, frameHeight > 0 else { return [self] }

        let frames = (0..<rows).flatMap { row in
            (0..<columns).compactMap { column -> UIImage? in
                let cropRect = CGRect(
                    x: column * frameWidth,
                    y: row * frameHeight,
                    width: frameWidth,
                    height: frameHeight
                )

                guard let croppedImage = cgImage.cropping(to: cropRect) else { return nil }
                return UIImage(cgImage: croppedImage, scale: scale, orientation: imageOrientation)
            }
        }

        return frames.isEmpty ? [self] : frames
    }
}

private struct LoopingVideoPlayer: UIViewControllerRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill

        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: item)
        context.coordinator.looper = AVPlayerLooper(player: player, templateItem: item)
        context.coordinator.player = player

        controller.player = player
        player.isMuted = true
        player.play()
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if context.coordinator.player?.timeControlStatus != .playing {
            context.coordinator.player?.play()
        }
    }

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        coordinator.player?.pause()
        coordinator.player = nil
        coordinator.looper = nil
    }

    final class Coordinator {
        var player: AVQueuePlayer?
        var looper: AVPlayerLooper?
    }
}
