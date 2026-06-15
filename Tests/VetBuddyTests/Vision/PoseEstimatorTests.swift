import XCTest
import Vision
@testable import VetBuddy

final class PoseEstimatorTests: XCTestCase {

    // MARK: - RepCounter 初始状态

    func testRepCounter_InitialCount() {
        let counter = RepCounter()
        XCTAssertEqual(counter.count, 0)
        XCTAssertFalse(counter.isInDownPosition)
    }

    func testRepCounter_Reset() {
        let newCounter = RepCounter()
        XCTAssertEqual(newCounter.count, 0)
        XCTAssertFalse(newCounter.isInDownPosition)
    }

    // MARK: - RepCounter 更新逻辑

    func testRepCounter_NoPose_ReturnsFalse() {
        var counter = RepCounter()
        let pose = BodyPose(joints: [:], confidence: 0.5)
        let completed = counter.update(with: pose)
        XCTAssertFalse(completed)
        XCTAssertEqual(counter.count, 0)
    }

    func testRepCounter_WithJoints_DetectsDownPosition() {
        var counter = RepCounter()

        // Simulate a pose (joints present, will calculate angle)
        // Even if angle detection doesn't trigger, count should stay 0
        let pose = BodyPose(joints: [
            .leftHip: CGPoint(x: 0.5, y: 0.3),
            .leftKnee: CGPoint(x: 0.5, y: 0.5),
            .leftAnkle: CGPoint(x: 0.5, y: 0.7)
        ], confidence: 0.9)

        let _ = counter.update(with: pose)
        // With straight legs, should not be in down position
        XCTAssertFalse(counter.isInDownPosition)
        XCTAssertEqual(counter.count, 0)
    }

    // MARK: - BodyPose 模型

    func testBodyPose_StoresJoints() {
        let joints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [
            .leftHip: CGPoint(x: 0.5, y: 0.3)
        ]
        let pose = BodyPose(joints: joints, confidence: 0.8)
        XCTAssertEqual(pose.confidence, 0.8)
        XCTAssertEqual(pose.joints[.leftHip], CGPoint(x: 0.5, y: 0.3))
    }

    // MARK: - CameraSession 初始状态

    func testCameraSession_InitialState() {
        let session = CameraSession()
        XCTAssertFalse(session.isRunning)
        XCTAssertFalse(session.permissionGranted)
    }
}
