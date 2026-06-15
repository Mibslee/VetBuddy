import SwiftUI

struct ExerciseGuideAnimationView: View {
    let exercise: Exercise
    var height: CGFloat = 240

    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = Self.phase(for: timeline.date, duration: 3.2)
            let pose = ExercisePoseFactory.pose(for: exercise.id, phase: phase)
            let stageHeight = max(160, height * 0.80)
            let cueHeight = max(58, height - stageHeight - 10)

            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.vbDistantMountain.opacity(0.18),
                                    Color.vbCardBackground
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    exerciseStage(for: pose)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                }
                .frame(height: stageHeight)

                cueBar(for: pose)
                    .frame(height: cueHeight)
            }
            .frame(height: height)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(exercise.nameCN)动作指导动画，\(pose.coachingCue)")
        }
    }

    private func cueBar(for pose: ExercisePose) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.strengthtraining.functional")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.vbAccent)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 4) {
                Text(pose.coachingCue)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.vbMainText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)
                Text("看大图跟动作，节奏要慢")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.vbSecondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func exerciseStage(for pose: ExercisePose) -> some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                StageEquipmentSurfaceView(equipment: pose.equipment)

                StageEquipmentView(equipment: pose.equipment)
                    .stroke(Color.vbSecondaryText.opacity(0.38), style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))

                MotionTrailView(points: pose.trail)
                    .stroke(Color.vbAccent.opacity(0.32), style: StrokeStyle(lineWidth: 8, lineCap: .round, dash: [6, 10]))

                PoseAvatarView(pose: pose)
            }
            .scaleEffect(Self.stageScale(for: size), anchor: .center)
            .frame(width: size.width, height: size.height)
        }
    }

    private static func phase(for date: Date, duration: TimeInterval) -> Double {
        let progress = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration) / duration
        return progress < 0 ? progress + 1 : progress
    }

    private static func stageScale(for size: CGSize) -> CGFloat {
        min(1.18, max(1.0, min(size.width / 300, size.height / 220)))
    }
}

private struct ExercisePose {
    var head: CGPoint
    var neck: CGPoint
    var chest: CGPoint
    var hip: CGPoint
    var leftShoulder: CGPoint
    var rightShoulder: CGPoint
    var leftElbow: CGPoint
    var rightElbow: CGPoint
    var leftHand: CGPoint
    var rightHand: CGPoint
    var leftKnee: CGPoint
    var rightKnee: CGPoint
    var leftFoot: CGPoint
    var rightFoot: CGPoint
    var trail: [CGPoint]
    var equipment: StageEquipment
    var coachingCue: String

    var joints: [CGPoint] {
        [
            head, neck, chest, hip,
            leftShoulder, rightShoulder, leftElbow, rightElbow,
            leftHand, rightHand, leftKnee, rightKnee, leftFoot, rightFoot
        ]
    }
}

private enum StageEquipment {
    case none
    case chair
    case wall
    case floor
    case wallAndLine
}

private enum ExercisePoseFactory {
    static func pose(for id: String, phase: Double) -> ExercisePose {
        switch id {
        case "sit_to_stand":
            return sitToStand(phase: phase)
        case "calf_raise":
            return calfRaise(phase: phase)
        case "wall_sit":
            return wallSit(phase: phase)
        case "straight_leg_raise":
            return straightLegRaise(phase: phase)
        case "side_leg_raise":
            return sideLegRaise(phase: phase)
        case "glute_bridge":
            return gluteBridge(phase: phase)
        case "standing_march":
            return standingMarch(phase: phase)
        case "tandem_walk":
            return tandemWalk(phase: phase)
        default:
            return standingMarch(phase: phase)
        }
    }

    private static func rep(_ phase: Double) -> CGFloat {
        CGFloat((1 - cos(phase * .pi * 2)) / 2)
    }

    private static func pulse(_ phase: Double) -> CGFloat {
        CGFloat(sin(phase * .pi * 2))
    }

    private static func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }

    private static func standing(
        hip: CGPoint = p(0.50, 0.52),
        kneeOffset: CGFloat = 0,
        footLift: CGFloat = 0,
        equipment: StageEquipment = .none,
        cue: String
    ) -> ExercisePose {
        let chest = p(hip.x, hip.y - 0.18)
        let neck = p(chest.x, chest.y - 0.09)
        let leftKnee = p(0.43, 0.70 - kneeOffset)
        let rightKnee = p(0.57, 0.70 + kneeOffset)

        return ExercisePose(
            head: p(neck.x, neck.y - 0.08),
            neck: neck,
            chest: chest,
            hip: hip,
            leftShoulder: p(chest.x - 0.10, chest.y - 0.03),
            rightShoulder: p(chest.x + 0.10, chest.y - 0.03),
            leftElbow: equipment == .wall || equipment == .wallAndLine ? p(0.34, chest.y + 0.06) : p(chest.x - 0.15, chest.y + 0.10),
            rightElbow: p(chest.x + 0.15, chest.y + 0.10),
            leftHand: equipment == .wall || equipment == .wallAndLine ? p(0.28, chest.y + 0.09) : p(chest.x - 0.12, chest.y + 0.22),
            rightHand: p(chest.x + 0.12, chest.y + 0.22),
            leftKnee: leftKnee,
            rightKnee: rightKnee,
            leftFoot: p(0.41, 0.88 - footLift),
            rightFoot: p(0.59, 0.88 + footLift),
            trail: [],
            equipment: equipment,
            coachingCue: cue
        )
    }

    private static func sitToStand(phase: Double) -> ExercisePose {
        let t = rep(phase)
        let hip = p(0.50, 0.52 + 0.15 * t)
        let chest = p(0.50 + 0.04 * t, hip.y - 0.18)
        let neck = p(chest.x, chest.y - 0.09)
        let kneeY = 0.72 + 0.02 * t

        return ExercisePose(
            head: p(neck.x, neck.y - 0.08),
            neck: neck,
            chest: chest,
            hip: hip,
            leftShoulder: p(chest.x - 0.10, chest.y - 0.03),
            rightShoulder: p(chest.x + 0.10, chest.y - 0.03),
            leftElbow: p(chest.x - 0.15, chest.y + 0.10),
            rightElbow: p(chest.x + 0.15, chest.y + 0.10),
            leftHand: p(0.31, chest.y + 0.18),
            rightHand: p(chest.x + 0.12, chest.y + 0.22),
            leftKnee: p(0.42, kneeY),
            rightKnee: p(0.58, kneeY),
            leftFoot: p(0.39, 0.88),
            rightFoot: p(0.61, 0.88),
            trail: [p(0.50, 0.66), p(0.50, 0.59), p(0.50, 0.52)],
            equipment: .chair,
            coachingCue: t > 0.5 ? "臀部向后坐，膝盖对准脚尖" : "脚跟发力站直，收紧臀部"
        )
    }

    private static func calfRaise(phase: Double) -> ExercisePose {
        let t = rep(phase)
        var pose = standing(
            hip: p(0.50, 0.52 - 0.05 * t),
            footLift: 0.03 * t,
            equipment: .wall,
            cue: t > 0.5 ? "脚跟慢慢落回地面" : "向上提踵，保持身体竖直"
        )
        pose.trail = [p(0.50, 0.52), p(0.50, 0.47)]
        return pose
    }

    private static func wallSit(phase: Double) -> ExercisePose {
        let breath = pulse(phase) * 0.01
        return ExercisePose(
            head: p(0.34, 0.23 + breath),
            neck: p(0.34, 0.31 + breath),
            chest: p(0.34, 0.42 + breath),
            hip: p(0.36, 0.58),
            leftShoulder: p(0.31, 0.39 + breath),
            rightShoulder: p(0.40, 0.39 + breath),
            leftElbow: p(0.31, 0.50),
            rightElbow: p(0.44, 0.50),
            leftHand: p(0.35, 0.60),
            rightHand: p(0.46, 0.60),
            leftKnee: p(0.56, 0.67),
            rightKnee: p(0.64, 0.67),
            leftFoot: p(0.56, 0.86),
            rightFoot: p(0.66, 0.86),
            trail: [],
            equipment: .wall,
            coachingCue: "背部贴墙，膝盖不要超过脚尖"
        )
    }

    private static func straightLegRaise(phase: Double) -> ExercisePose {
        let t = rep(phase)
        return ExercisePose(
            head: p(0.20, 0.56),
            neck: p(0.27, 0.58),
            chest: p(0.40, 0.60),
            hip: p(0.56, 0.61),
            leftShoulder: p(0.34, 0.56),
            rightShoulder: p(0.34, 0.64),
            leftElbow: p(0.43, 0.55),
            rightElbow: p(0.43, 0.67),
            leftHand: p(0.51, 0.57),
            rightHand: p(0.51, 0.67),
            leftKnee: p(0.72, 0.62 - 0.24 * t),
            rightKnee: p(0.73, 0.72),
            leftFoot: p(0.88, 0.62 - 0.34 * t),
            rightFoot: p(0.90, 0.72),
            trail: [p(0.88, 0.62), p(0.87, 0.44), p(0.85, 0.29)],
            equipment: .floor,
            coachingCue: "直腿抬到对侧膝高，腰背贴稳"
        )
    }

    private static func sideLegRaise(phase: Double) -> ExercisePose {
        let t = rep(phase)
        return ExercisePose(
            head: p(0.22, 0.58),
            neck: p(0.30, 0.60),
            chest: p(0.44, 0.62),
            hip: p(0.58, 0.64),
            leftShoulder: p(0.38, 0.57),
            rightShoulder: p(0.39, 0.66),
            leftElbow: p(0.47, 0.55),
            rightElbow: p(0.46, 0.70),
            leftHand: p(0.54, 0.57),
            rightHand: p(0.54, 0.70),
            leftKnee: p(0.74, 0.64 - 0.20 * t),
            rightKnee: p(0.75, 0.69),
            leftFoot: p(0.90, 0.64 - 0.27 * t),
            rightFoot: p(0.91, 0.69),
            trail: [p(0.90, 0.64), p(0.89, 0.50), p(0.88, 0.37)],
            equipment: .floor,
            coachingCue: "髋部保持稳定，上方腿慢慢抬起"
        )
    }

    private static func gluteBridge(phase: Double) -> ExercisePose {
        let t = rep(phase)
        let hipY = 0.70 - 0.20 * t

        return ExercisePose(
            head: p(0.20, 0.68),
            neck: p(0.28, 0.67),
            chest: p(0.42, 0.66 - 0.08 * t),
            hip: p(0.58, hipY),
            leftShoulder: p(0.36, 0.62),
            rightShoulder: p(0.36, 0.70),
            leftElbow: p(0.45, 0.61),
            rightElbow: p(0.45, 0.73),
            leftHand: p(0.54, 0.63),
            rightHand: p(0.54, 0.73),
            leftKnee: p(0.72, 0.72),
            rightKnee: p(0.80, 0.72),
            leftFoot: p(0.76, 0.88),
            rightFoot: p(0.86, 0.88),
            trail: [p(0.58, 0.70), p(0.58, 0.60), p(0.58, 0.50)],
            equipment: .floor,
            coachingCue: "抬臀到肩髋膝一线，避免挺腰"
        )
    }

    private static func standingMarch(phase: Double) -> ExercisePose {
        let t = rep(phase)
        var pose = standing(
            hip: p(0.50, 0.52),
            kneeOffset: 0,
            equipment: .wall,
            cue: "交替提膝到舒适高度，身体保持直立"
        )

        if phase < 0.5 {
            pose.leftKnee = p(0.43, 0.62 - 0.13 * t)
            pose.leftFoot = p(0.43, 0.82 - 0.22 * t)
        } else {
            pose.rightKnee = p(0.57, 0.62 - 0.13 * t)
            pose.rightFoot = p(0.57, 0.82 - 0.22 * t)
        }
        pose.trail = [p(0.43, 0.82), p(0.43, 0.70), p(0.43, 0.60)]
        return pose
    }

    private static func tandemWalk(phase: Double) -> ExercisePose {
        let t = rep(phase)
        let shift = (CGFloat(phase) - 0.5) * 0.12
        var pose = standing(
            hip: p(0.50 + shift, 0.52 - 0.02 * t),
            equipment: .wallAndLine,
            cue: "脚跟贴脚尖走直线，必要时扶墙"
        )
        pose.leftFoot = p(0.47 + shift + 0.08 * t, 0.88)
        pose.rightFoot = p(0.55 + shift - 0.06 * t, 0.88)
        pose.leftKnee = p(0.45 + shift + 0.04 * t, 0.70)
        pose.rightKnee = p(0.55 + shift - 0.03 * t, 0.70)
        pose.trail = [p(0.35, 0.88), p(0.50, 0.88), p(0.65, 0.88)]
        return pose
    }
}

private struct PoseAvatarView: View {
    let pose: ExercisePose

    var body: some View {
        GeometryReader { proxy in
            let rect = CGRect(origin: .zero, size: proxy.size)

            ZStack {
                avatarShadow(in: rect)

                bodySegment(from: pose.leftShoulder, to: pose.leftElbow, in: rect, width: 16, color: Color.vbAccent.opacity(0.92))
                bodySegment(from: pose.leftElbow, to: pose.leftHand, in: rect, width: 15, color: Color.vbAccent.opacity(0.82))
                bodySegment(from: pose.rightShoulder, to: pose.rightElbow, in: rect, width: 16, color: Color.vbAccent.opacity(0.92))
                bodySegment(from: pose.rightElbow, to: pose.rightHand, in: rect, width: 15, color: Color.vbAccent.opacity(0.82))

                bodySegment(from: pose.hip, to: pose.leftKnee, in: rect, width: 24, color: Color.vbMainText.opacity(0.90))
                bodySegment(from: pose.leftKnee, to: pose.leftFoot, in: rect, width: 22, color: Color.vbMainText.opacity(0.86))
                bodySegment(from: pose.hip, to: pose.rightKnee, in: rect, width: 24, color: Color.vbDistantMountain.opacity(0.88))
                bodySegment(from: pose.rightKnee, to: pose.rightFoot, in: rect, width: 22, color: Color.vbDistantMountain.opacity(0.84))

                torso(in: rect)
                feet(in: rect)
                head(in: rect)
            }
        }
        .accessibilityHidden(true)
    }

    private func torso(in rect: CGRect) -> some View {
        ZStack {
            bodySegment(from: pose.neck, to: pose.chest, in: rect, width: 36, color: Color.vbAccent)
            bodySegment(from: pose.chest, to: pose.hip, in: rect, width: 42, color: Color.vbAccent)
            bodySegment(from: pose.leftShoulder, to: pose.rightShoulder, in: rect, width: 34, color: Color.vbAccent)
        }
        .shadow(color: Color.vbMainText.opacity(0.16), radius: 5, x: 0, y: 5)
    }

    private func head(in rect: CGRect) -> some View {
        let center = convert(pose.head, in: rect)

        return ZStack {
            Circle()
                .fill(Color(red: 0.89, green: 0.70, blue: 0.56))
                .frame(width: 44, height: 44)
                .shadow(color: Color.vbMainText.opacity(0.18), radius: 4, x: 0, y: 3)
                .position(center)

            Circle()
                .fill(Color.white.opacity(0.28))
                .frame(width: 14, height: 10)
                .position(CGPoint(x: center.x - 7, y: center.y - 8))
        }
    }

    private func feet(in rect: CGRect) -> some View {
        ZStack {
            foot(at: pose.leftFoot, in: rect)
            foot(at: pose.rightFoot, in: rect)
        }
    }

    private func foot(at point: CGPoint, in rect: CGRect) -> some View {
        let center = convert(point, in: rect)
        return Capsule()
            .fill(Color.vbMainText)
            .frame(width: 42, height: 14)
            .position(CGPoint(x: center.x + 5, y: center.y + 5))
    }

    private func avatarShadow(in rect: CGRect) -> some View {
        Capsule()
            .fill(Color.vbMainText.opacity(0.10))
            .frame(width: rect.width * 0.36, height: 16)
            .position(convert(CGPoint(x: 0.56, y: 0.91), in: rect))
    }

    private func bodySegment(from start: CGPoint, to end: CGPoint, in rect: CGRect, width: CGFloat, color: Color) -> some View {
        AvatarSegment(
            start: convert(start, in: rect),
            end: convert(end, in: rect),
            width: width,
            color: color
        )
    }
}

private struct AvatarSegment: View {
    let start: CGPoint
    let end: CGPoint
    let width: CGFloat
    let color: Color

    var body: some View {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = max(1, hypot(dx, dy))
        let angle = atan2(dy, dx)
        let center = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)

        Capsule()
            .fill(color)
            .frame(width: length, height: width)
            .rotationEffect(.radians(angle))
            .position(center)
            .shadow(color: Color.vbMainText.opacity(0.10), radius: 3, x: 0, y: 2)
    }
}

private struct PoseSkeletonView: Shape {
    let pose: ExercisePose

    func path(in rect: CGRect) -> Path {
        Path { path in
            addLine(&path, rect, pose.head, pose.neck)
            addLine(&path, rect, pose.neck, pose.chest)
            addLine(&path, rect, pose.chest, pose.hip)
            addLine(&path, rect, pose.leftShoulder, pose.leftElbow)
            addLine(&path, rect, pose.leftElbow, pose.leftHand)
            addLine(&path, rect, pose.rightShoulder, pose.rightElbow)
            addLine(&path, rect, pose.rightElbow, pose.rightHand)
            addLine(&path, rect, pose.hip, pose.leftKnee)
            addLine(&path, rect, pose.leftKnee, pose.leftFoot)
            addLine(&path, rect, pose.hip, pose.rightKnee)
            addLine(&path, rect, pose.rightKnee, pose.rightFoot)
        }
    }

    private func addLine(_ path: inout Path, _ rect: CGRect, _ start: CGPoint, _ end: CGPoint) {
        path.move(to: convert(start, in: rect))
        path.addLine(to: convert(end, in: rect))
    }
}

private struct JointDotsView: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        Path { path in
            for point in points {
                let center = convert(point, in: rect)
                path.addEllipse(in: CGRect(x: center.x - 7, y: center.y - 7, width: 14, height: 14))
            }
        }
    }
}

private struct HeadView: Shape {
    let center: CGPoint

    func path(in rect: CGRect) -> Path {
        Path { path in
            let point = convert(center, in: rect)
            path.addEllipse(in: CGRect(x: point.x - 21, y: point.y - 21, width: 42, height: 42))
        }
    }
}

private struct HeadHighlightView: Shape {
    let center: CGPoint

    func path(in rect: CGRect) -> Path {
        Path { path in
            let point = convert(center, in: rect)
            path.addEllipse(in: CGRect(x: point.x - 10, y: point.y - 14, width: 16, height: 12))
        }
    }
}

private struct StageEquipmentSurfaceView: View {
    let equipment: StageEquipment

    var body: some View {
        GeometryReader { proxy in
            let rect = CGRect(origin: .zero, size: proxy.size)

            ZStack {
                floorShadow(in: rect)

                switch equipment {
                case .none:
                    EmptyView()
                case .floor:
                    mat(in: rect)
                case .chair:
                    chair(in: rect)
                case .wall:
                    wall(in: rect)
                case .wallAndLine:
                    wall(in: rect)
                    balanceLine(in: rect)
                }
            }
        }
    }

    private func floorShadow(in rect: CGRect) -> some View {
        Capsule()
            .fill(Color.vbDistantMountain.opacity(0.12))
            .frame(width: rect.width * 0.72, height: 18)
            .position(convert(CGPoint(x: 0.56, y: 0.91), in: rect))
    }

    private func wall(in rect: CGRect) -> some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.vbSurfaceVariant.opacity(0.68))
            Rectangle()
                .fill(Color.vbSecondaryText.opacity(0.22))
                .frame(width: 5)
        }
        .frame(width: rect.width * 0.10, height: rect.height * 0.78)
        .position(convert(CGPoint(x: 0.25, y: 0.51), in: rect))
    }

    private func chair(in rect: CGRect) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.vbSurfaceVariant.opacity(0.78))
                .frame(width: rect.width * 0.25, height: rect.height * 0.06)
                .position(convert(CGPoint(x: 0.40, y: 0.69), in: rect))

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.vbSurfaceVariant.opacity(0.82))
                .frame(width: rect.width * 0.06, height: rect.height * 0.28)
                .position(convert(CGPoint(x: 0.28, y: 0.56), in: rect))

            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.vbSecondaryText.opacity(0.42))
                .frame(width: rect.width * 0.045, height: rect.height * 0.22)
                .position(convert(CGPoint(x: 0.31, y: 0.80), in: rect))

            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.vbSecondaryText.opacity(0.42))
                .frame(width: rect.width * 0.045, height: rect.height * 0.22)
                .position(convert(CGPoint(x: 0.50, y: 0.80), in: rect))
        }
    }

    private func mat(in rect: CGRect) -> some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.vbDistantMountain.opacity(0.18))
            .frame(width: rect.width * 0.82, height: rect.height * 0.16)
            .position(convert(CGPoint(x: 0.56, y: 0.78), in: rect))
    }

    private func balanceLine(in rect: CGRect) -> some View {
        Capsule()
            .fill(Color.vbAccent.opacity(0.22))
            .frame(width: rect.width * 0.40, height: 9)
            .position(convert(CGPoint(x: 0.54, y: 0.88), in: rect))
    }
}

private struct MotionTrailView: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: convert(first, in: rect))
            for point in points.dropFirst() {
                path.addLine(to: convert(point, in: rect))
            }
        }
    }
}

private struct StageEquipmentView: Shape {
    let equipment: StageEquipment

    func path(in rect: CGRect) -> Path {
        Path { path in
            addFloor(to: &path, rect: rect)

            switch equipment {
            case .none, .floor:
                break
            case .chair:
                addChair(to: &path, rect: rect)
            case .wall:
                addWall(to: &path, rect: rect)
            case .wallAndLine:
                addWall(to: &path, rect: rect)
                addBalanceLine(to: &path, rect: rect)
            }
        }
    }

    private func addFloor(to path: inout Path, rect: CGRect) {
        path.move(to: convert(CGPoint(x: 0.10, y: 0.90), in: rect))
        path.addLine(to: convert(CGPoint(x: 0.92, y: 0.90), in: rect))
    }

    private func addChair(to path: inout Path, rect: CGRect) {
        let seatLeft = convert(CGPoint(x: 0.28, y: 0.69), in: rect)
        let seatRight = convert(CGPoint(x: 0.53, y: 0.69), in: rect)
        let backTop = convert(CGPoint(x: 0.28, y: 0.42), in: rect)
        path.move(to: backTop)
        path.addLine(to: seatLeft)
        path.addLine(to: seatRight)
        path.move(to: seatLeft)
        path.addLine(to: convert(CGPoint(x: 0.31, y: 0.90), in: rect))
        path.move(to: seatRight)
        path.addLine(to: convert(CGPoint(x: 0.50, y: 0.90), in: rect))
    }

    private func addWall(to path: inout Path, rect: CGRect) {
        path.move(to: convert(CGPoint(x: 0.30, y: 0.12), in: rect))
        path.addLine(to: convert(CGPoint(x: 0.30, y: 0.90), in: rect))
    }

    private func addBalanceLine(to path: inout Path, rect: CGRect) {
        path.move(to: convert(CGPoint(x: 0.34, y: 0.88), in: rect))
        path.addLine(to: convert(CGPoint(x: 0.74, y: 0.88), in: rect))
    }
}

private func convert(_ point: CGPoint, in rect: CGRect) -> CGPoint {
    CGPoint(
        x: rect.minX + point.x * rect.width,
        y: rect.minY + point.y * rect.height
    )
}

#Preview("Guide Animation") {
    VStack {
        ExerciseGuideAnimationView(exercise: ExerciseLibrary.shared.allExercises[0])
        ExerciseGuideAnimationView(exercise: ExerciseLibrary.shared.allExercises[5])
    }
    .padding()
    .background(Color.vbCream)
}
