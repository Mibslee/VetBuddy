import Foundation
import Vision
import CoreVideo
import Combine

final class PoseEstimator: ObservableObject {

    @Published var currentPose: BodyPose?
    @Published var repCount: Int = 0
    @Published var isDetecting = false

    private var repCounter = RepCounter()
    private let bodyPoseRequest = VNDetectHumanBodyPoseRequest()

    // MARK: - Public API

    func processFrame(_ pixelBuffer: CVPixelBuffer) async {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])

        do {
            try handler.perform([bodyPoseRequest])
        } catch {
            return
        }

        guard let observation = bodyPoseRequest.results?.first else { return }

        let joints = extractJoints(from: observation)
        let pose = BodyPose(joints: joints, confidence: observation.confidence)

        let repCompleted = repCounter.update(with: pose)

        await MainActor.run {
            currentPose = pose
            if repCompleted {
                repCount = repCounter.count
            }
            if !isDetecting {
                isDetecting = true
            }
        }
    }

    func reset() {
        repCounter = RepCounter()
        repCount = 0
        currentPose = nil
        isDetecting = false
    }

    // MARK: - Private

    private func extractJoints(from observation: VNHumanBodyPoseObservation) -> [VNHumanBodyPoseObservation.JointName: CGPoint] {
        let jointNames: [VNHumanBodyPoseObservation.JointName] = [
            .leftHip, .leftKnee, .leftAnkle,
            .rightHip, .rightKnee, .rightAnkle,
            .leftShoulder, .rightShoulder,
            .nose, .neck
        ]

        var joints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        for name in jointNames {
            if let point = try? observation.recognizedPoint(name), point.confidence > 0.3 {
                joints[name] = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
            }
        }
        return joints
    }
}
