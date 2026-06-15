import Foundation
import Vision

// MARK: - Body Pose

struct BodyPose: Sendable {
    let joints: [VNHumanBodyPoseObservation.JointName: CGPoint]
    let confidence: Float
}

// MARK: - Rep Counter (sit-to-stand knee angle)

struct RepCounter {
    private(set) var count: Int = 0
    private(set) var isInDownPosition: Bool = false
    let threshold: Float = 0.15

    /// Updates the counter with a new pose. Returns `true` if a rep was just completed.
    mutating func update(with pose: BodyPose) -> Bool {
        let kneeAngle = calculateKneeAngle(from: pose)
        guard let angle = kneeAngle else { return false }

        let normalizedAngle = angle / 180.0

        if normalizedAngle < (1.0 - threshold) {
            if !isInDownPosition {
                isInDownPosition = true
            }
        } else if normalizedAngle > (1.0 - threshold / 2) {
            if isInDownPosition {
                isInDownPosition = false
                count += 1
                return true
            }
        }
        return false
    }

    /// Calculates knee angle from hip-knee-ankle joints. Returns degrees or nil if joints unavailable.
    private func calculateKneeAngle(from pose: BodyPose) -> Float? {
        guard let hip = pose.joints[.leftHip],
              let knee = pose.joints[.leftKnee],
              let ankle = pose.joints[.leftAnkle]
        else {
            guard let hip = pose.joints[.rightHip],
                  let knee = pose.joints[.rightKnee],
                  let ankle = pose.joints[.rightAnkle]
            else { return nil }
            return angleBetween(hip: hip, knee: knee, ankle: ankle)
        }
        return angleBetween(hip: hip, knee: knee, ankle: ankle)
    }

    private func angleBetween(hip: CGPoint, knee: CGPoint, ankle: CGPoint) -> Float {
        let thigh = CGPoint(x: hip.x - knee.x, y: hip.y - knee.y)
        let shin = CGPoint(x: ankle.x - knee.x, y: ankle.y - knee.y)

        let dot = Float(thigh.x * shin.x + thigh.y * shin.y)
        let magThigh = sqrtf(Float(thigh.x * thigh.x + thigh.y * thigh.y))
        let magShin = sqrtf(Float(shin.x * shin.x + shin.y * shin.y))

        guard magThigh > 0, magShin > 0 else { return 0 }
        let cosAngle = max(-1, min(1, dot / (magThigh * magShin)))
        return acos(cosAngle) * 180.0 / .pi
    }
}
