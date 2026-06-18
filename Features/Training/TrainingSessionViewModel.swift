import Foundation
import Combine

/// ViewModel managing an active training session.
final class TrainingSessionViewModel: ObservableObject {

    // MARK: - Published State

    @Published var currentExerciseIndex: Int = 0
    @Published var currentSet: Int = 1
    @Published var isResting: Bool = false
    @Published var restTimeRemaining: Int = 0
    @Published var isSessionComplete: Bool = false
    @Published var isPaused: Bool = false
    @Published var totalElapsedSeconds: Int = 0
    @Published var completedExerciseIndices: Set<Int> = []
    @Published var skippedExerciseIndices: Set<Int> = []

    // MARK: - Internal State

    private var sessionPlan: TrainingPlan?
    private var sessionStartTime: Date?
    private var exerciseRecords: [TrainingRecord] = []
    private var restTimer: AnyCancellable?
    private var sessionTimer: AnyCancellable?

    private let recordStore: TrainingRecordStore
    private let healthKitService: HealthKitService

    init(
        recordStore: TrainingRecordStore = .shared,
        healthKitService: HealthKitService = HealthKitService()
    ) {
        self.recordStore = recordStore
        self.healthKitService = healthKitService
    }

    // MARK: - Computed

    var exercises: [PlannedExercise] {
        sessionPlan?.exercises ?? []
    }

    var currentExercise: PlannedExercise? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }

    var totalExercises: Int {
        exercises.count
    }

    var overallProgress: Double {
        guard totalExercises > 0 else { return 0 }
        let completedCount = Double(completedExerciseIndices.union(skippedExerciseIndices).count)
        let currentProgress = currentSetProgress
        return (completedCount + currentProgress) / Double(totalExercises)
    }

    private var currentSetProgress: Double {
        guard let exercise = currentExercise, exercise.sets > 0 else { return 0 }
        return Double(currentSet - 1) / Double(exercise.sets)
    }

    var elapsedTimeText: String {
        let minutes = totalElapsedSeconds / 60
        let seconds = totalElapsedSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Session Control

    func startSession(plan: TrainingPlan) {
        sessionPlan = plan
        currentExerciseIndex = 0
        currentSet = 1
        isResting = false
        isPaused = false
        isSessionComplete = false
        completedExerciseIndices = []
        skippedExerciseIndices = []
        exerciseRecords = []
        totalElapsedSeconds = 0
        sessionStartTime = Date()
        startSessionTimer()
    }

    func completeSet() {
        guard let exercise = currentExercise else { return }

        if currentSet < exercise.sets {
            beginRest(duration: exercise.restSeconds)
        } else {
            completeCurrentExercise()
        }
    }

    func nextExercise() {
        moveToNextExercise()
    }

    func skipCurrentExercise() {
        guard currentExercise != nil else { return }
        restTimer?.cancel()
        restTimer = nil
        isResting = false
        skippedExerciseIndices.insert(currentExerciseIndex)
        moveToNextExercise()
    }

    func pauseSession() {
        isPaused = true
        stopAllTimers()
    }

    func resumeSession() {
        isPaused = false
        startSessionTimer()
        if isResting {
            startRestTimer()
        }
    }

    func endSession() {
        stopAllTimers()
        finishSession()
    }

    // MARK: - Internal

    private func beginRest(duration: Int) {
        restTimeRemaining = duration
        isResting = true
        startRestTimer()
    }

    private func startRestTimer() {
        restTimer?.cancel()
        restTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.restTimeRemaining > 1 {
                    self.restTimeRemaining -= 1
                } else {
                    self.restTimer?.cancel()
                    self.restTimer = nil
                    self.isResting = false
                    self.currentSet += 1
                }
            }
    }

    private func completeCurrentExercise() {
        guard let exercise = currentExercise else { return }

        completedExerciseIndices.insert(currentExerciseIndex)

        let record = TrainingRecord(
            exerciseId: exercise.exercise.id,
            exerciseName: exercise.exercise.nameCN,
            completedSets: exercise.sets,
            completedReps: exercise.sets * exercise.reps,
            durationSeconds: exercise.exercise.durationSeconds
        )
        exerciseRecords.append(record)

        if currentExerciseIndex + 1 < totalExercises {
            moveToNextExercise()
        } else {
            finishSession()
        }
    }

    private func moveToNextExercise() {
        let nextIndex = currentExerciseIndex + 1
        if nextIndex < totalExercises {
            currentExerciseIndex = nextIndex
            currentSet = 1
            isResting = false
            restTimeRemaining = 0
        } else {
            finishSession()
        }
    }

    private func finishSession() {
        stopAllTimers()
        Task {
            await saveRecords()
            await MainActor.run {
                isSessionComplete = true
            }
        }
    }

    private func saveRecords() async {
        for record in exerciseRecords {
            await recordStore.addRecord(record)
        }

        guard sessionPlan != nil else { return }

        await healthKitService.refreshAll()
        let summary = await MainActor.run { healthKitService.todaySummary }

        let checkin = DailyCheckin(
            completedExerciseCount: completedExerciseIndices.count,
            totalExerciseCount: totalExercises,
            totalDurationSeconds: totalElapsedSeconds,
            steps: summary?.steps,
            heartRate: summary?.heartRate,
            weight: summary?.weight
        )
        await recordStore.addCheckin(checkin)
    }

    private func startSessionTimer() {
        sessionTimer?.cancel()
        sessionTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.totalElapsedSeconds += 1
            }
    }

    private func stopAllTimers() {
        restTimer?.cancel()
        restTimer = nil
        sessionTimer?.cancel()
        sessionTimer = nil
    }

    func reset() {
        stopAllTimers()
        sessionPlan = nil
        currentExerciseIndex = 0
        currentSet = 1
        isResting = false
        isPaused = false
        isSessionComplete = false
        totalElapsedSeconds = 0
        completedExerciseIndices = []
        skippedExerciseIndices = []
        exerciseRecords = []
    }
}
