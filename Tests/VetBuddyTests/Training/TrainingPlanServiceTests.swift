import XCTest
@testable import VetBuddy

final class TrainingPlanServiceTests: XCTestCase {

    let service = TrainingPlanService()
    let library = ExerciseLibrary.shared
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "TrainingPlanServiceTests")!
        defaults.removePersistentDomain(forName: "TrainingPlanServiceTests")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "TrainingPlanServiceTests")
        defaults = nil
        super.tearDown()
    }

    private func makeRecordStore() -> TrainingRecordStore {
        TrainingRecordStore(defaults: defaults)
    }

    // MARK: - 计划生成

    func testGeneratePlan_L1_ReturnsCorrectExerciseCount() {
        let plan = service.generateDailyPlan(for: .L1)
        XCTAssertEqual(plan.exercises.count, 5)
        XCTAssertEqual(plan.fitnessLevel, .L1)
    }

    func testGeneratePlan_L2_ReturnsCorrectExerciseCount() {
        let plan = service.generateDailyPlan(for: .L2)
        XCTAssertEqual(plan.exercises.count, 7)
        XCTAssertEqual(plan.fitnessLevel, .L2)
    }

    func testGeneratePlan_L3_ReturnsAllExercises() {
        let plan = service.generateDailyPlan(for: .L3)
        XCTAssertEqual(plan.exercises.count, 8)
        XCTAssertEqual(plan.fitnessLevel, .L3)
    }

    func testGeneratePlan_L1_TargetDurationInRange() {
        let plan = service.generateDailyPlan(for: .L1)
        XCTAssertTrue((15...20).contains(plan.targetDurationMinutes))
    }

    func testGeneratePlan_L2_TargetDurationInRange() {
        let plan = service.generateDailyPlan(for: .L2)
        XCTAssertTrue((25...30).contains(plan.targetDurationMinutes))
    }

    func testGeneratePlan_L3_TargetDurationInRange() {
        let plan = service.generateDailyPlan(for: .L3)
        XCTAssertTrue((30...40).contains(plan.targetDurationMinutes))
    }

    // MARK: - 动作配置

    func testPlanExercise_SetsMatchLevel() {
        let plan = service.generateDailyPlan(for: .L2)
        for planned in plan.exercises {
            XCTAssertEqual(planned.sets, planned.exercise.setsForLevel(.L2))
        }
    }

    func testPlanExercise_RepsMatchLevel() {
        let plan = service.generateDailyPlan(for: .L3)
        for planned in plan.exercises {
            XCTAssertEqual(planned.reps, planned.exercise.repsForLevel(.L3))
        }
    }

    func testPlanExercise_RestMatchLevel() {
        let plan = service.generateDailyPlan(for: .L1)
        for planned in plan.exercises {
            XCTAssertEqual(planned.restSeconds, planned.exercise.restForLevel(.L1))
        }
    }

    func testLightPlan_ReducesLoadAndExtendsRest() {
        let plan = service.generateDailyPlan(for: .L2)

        let lightPlan = service.lightPlan(from: plan)

        XCTAssertEqual(lightPlan.exercises.count, plan.exercises.count)
        XCTAssertLessThan(lightPlan.targetDurationMinutes, plan.targetDurationMinutes)
        for (base, light) in zip(plan.exercises, lightPlan.exercises) {
            XCTAssertLessThanOrEqual(light.sets, base.sets)
            XCTAssertLessThanOrEqual(light.reps, base.reps)
            XCTAssertGreaterThan(light.restSeconds, base.restSeconds)
            XCTAssertGreaterThanOrEqual(light.sets, 1)
            XCTAssertGreaterThanOrEqual(light.reps, 1)
        }
    }

    func testTrainingFeedbackStore_RecentHardFeedbackTriggersLightMode() {
        let store = TrainingFeedbackStore(defaults: defaults)
        store.save(TrainingFeedback(effort: .tooHard, discomfort: .none))

        XCTAssertTrue(store.shouldUseLightMode())
    }

    func testTrainingFeedbackStore_OldHardFeedbackDoesNotTriggerLightMode() {
        let store = TrainingFeedbackStore(defaults: defaults)
        let oldDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        store.save(TrainingFeedback(date: oldDate, effort: .tooHard, discomfort: .none))

        XCTAssertFalse(store.shouldUseLightMode())
    }

    // MARK: - Exercise Library

    func testExerciseLibrary_FilterByLevel() {
        let l1Exercises = library.exercisesForLevel(.L1)
        XCTAssertEqual(l1Exercises.count, 8)

        for exercise in l1Exercises {
            XCTAssertTrue(exercise.applicableLevels.contains(.L1))
        }
    }

    func testExerciseLibrary_LookupById() {
        let exercise = library.exercise(byId: "sit_to_stand")
        XCTAssertNotNil(exercise)
        XCTAssertEqual(exercise?.nameCN, "椅子坐立")
    }

    func testExerciseLibrary_LookupById_NotFound() {
        let exercise = library.exercise(byId: "nonexistent")
        XCTAssertNil(exercise)
    }

    func testExerciseLibrary_AllExercisesHaveSafetyTips() {
        for exercise in library.allExercises {
            XCTAssertFalse(exercise.safetyTips.isEmpty, "\(exercise.nameCN) should have safety tips")
        }
    }

    func testExerciseLibrary_AllExercisesHaveModifiers() {
        for exercise in library.allExercises {
            for level in exercise.applicableLevels {
                XCTAssertNotNil(exercise.difficultyModifier[level],
                    "\(exercise.nameCN) should have modifier for \(level)")
            }
        }
    }

    // MARK: - 持久化

    func testTrainingRecordStore_AddAndRetrieve() async {
        let store = makeRecordStore()
        let record = TrainingRecord(
            exerciseId: "sit_to_stand",
            exerciseName: "椅子坐立",
            completedSets: 3,
            completedReps: 12,
            durationSeconds: 180
        )
        await store.addRecord(record)
        let records = await store.recordsForDate(Date())
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.exerciseId, "sit_to_stand")
    }

    func testTrainingSession_CompletedRepsSavesTotalRepsAcrossSets() async throws {
        let store = makeRecordStore()
        let exercise = ExerciseLibrary.shared.exercise(byId: "sit_to_stand")!
        let planned = PlannedExercise(exercise: exercise, sets: 2, reps: 8, restSeconds: 1)
        let plan = TrainingPlan(exercises: [planned], targetDurationMinutes: 5, fitnessLevel: .L1)
        let viewModel = await MainActor.run {
            TrainingSessionViewModel(recordStore: store, healthKitService: HealthKitService(defaults: defaults))
        }

        await MainActor.run {
            viewModel.startSession(plan: plan)
            viewModel.currentSet = 2
            viewModel.completeSet()
        }

        try await Task.sleep(nanoseconds: 300_000_000)
        let records = await store.recordsForDate(Date())
        XCTAssertEqual(records.first?.completedSets, 2)
        XCTAssertEqual(records.first?.completedReps, 16)
    }

    func testTrainingRecordStore_ConsecutiveStreak() async {
        let store = makeRecordStore()
        let calendar = Calendar.current

        for dayOffset in 0..<3 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let checkin = DailyCheckin(date: date, completedExerciseCount: 5, totalExerciseCount: 5, totalDurationSeconds: 1200)
            await store.addCheckin(checkin)
        }

        let streak = await store.consecutiveStreak()
        XCTAssertGreaterThanOrEqual(streak, 3)
    }

    func testTrainingRecordStore_EmptyStreak() async {
        let store = makeRecordStore()
        let streak = await store.consecutiveStreak()
        XCTAssertEqual(streak, 0)
    }

    func testTrainingRecordStore_TotalTrainingDays() async {
        let store = makeRecordStore()
        let calendar = Calendar.current

        for dayOffset in 0..<5 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let checkin = DailyCheckin(date: date, completedExerciseCount: 5, totalExerciseCount: 5, totalDurationSeconds: 1200)
            await store.addCheckin(checkin)
        }

        let totalDays = await store.totalTrainingDays()
        XCTAssertEqual(totalDays, 5)
    }
}
