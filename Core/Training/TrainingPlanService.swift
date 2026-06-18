import Foundation

struct TrainingPlan: Identifiable, Equatable, Codable, Sendable {
let id: UUID
let date: Date
let exercises: [PlannedExercise]
let targetDurationMinutes: Int
let fitnessLevel: FitnessLevel
var isCompleted: Bool

init(
        id: UUID = UUID(),
        date: Date = Date(),
        exercises: [PlannedExercise],
        targetDurationMinutes: Int,
        fitnessLevel: FitnessLevel,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.date = date
        self.exercises = exercises
        self.targetDurationMinutes = targetDurationMinutes
        self.fitnessLevel = fitnessLevel
        self.isCompleted = isCompleted
    }
}

struct PlannedExercise: Identifiable, Equatable, Codable, Sendable {
let id: String
let exercise: Exercise
let sets: Int
let reps: Int
let restSeconds: Int
var isCompleted: Bool
var completedSets: Int

init(exercise: Exercise, sets: Int, reps: Int, restSeconds: Int, isCompleted: Bool = false, completedSets: Int = 0) {
        self.id = exercise.id
        self.exercise = exercise
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.isCompleted = isCompleted
        self.completedSets = completedSets
    }
}

struct TrainingPlanService {
    private let library: ExerciseLibrary
    private let defaults: UserDefaults

    private enum Keys {
        static let dailyPlanPrefix = "vb_daily_plan_"
    }

init(library: ExerciseLibrary = .shared, defaults: UserDefaults = .standard) {
        self.library = library
        self.defaults = defaults
    }

func loadOrCreateDailyPlan(for level: FitnessLevel, date: Date = Date()) -> TrainingPlan {
        let key = Self.storageKey(for: date)
        if let data = defaults.data(forKey: key),
           let plan = try? JSONDecoder().decode(TrainingPlan.self, from: data),
           plan.fitnessLevel == level {
            return plan
        }

        let plan = generateDailyPlan(for: level, date: date)
        if let data = try? JSONEncoder().encode(plan) {
            defaults.set(data, forKey: key)
        }
        return plan
    }

func generateDailyPlan(for level: FitnessLevel, date: Date = Date()) -> TrainingPlan {
        let exercises = library.exercisesForLevel(level)
        let plannedExercises: [PlannedExercise]

        switch level {
        case .L1:
            let selected = Array(exercises.prefix(5))
            plannedExercises = selected.map {
                PlannedExercise(exercise: $0, sets: $0.setsForLevel(.L1), reps: $0.repsForLevel(.L1), restSeconds: $0.restForLevel(.L1))
            }
            return TrainingPlan(
                date: date,
                exercises: plannedExercises,
                targetDurationMinutes: 18,
                fitnessLevel: .L1
            )

        case .L2:
            let selected = Array(exercises.prefix(7))
            plannedExercises = selected.map {
                PlannedExercise(exercise: $0, sets: $0.setsForLevel(.L2), reps: $0.repsForLevel(.L2), restSeconds: $0.restForLevel(.L2))
            }
            return TrainingPlan(
                date: date,
                exercises: plannedExercises,
                targetDurationMinutes: 28,
                fitnessLevel: .L2
            )

        case .L3:
            plannedExercises = exercises.map {
                PlannedExercise(exercise: $0, sets: $0.setsForLevel(.L3), reps: $0.repsForLevel(.L3), restSeconds: $0.restForLevel(.L3))
            }
            return TrainingPlan(
                date: date,
                exercises: plannedExercises,
                targetDurationMinutes: 35,
                fitnessLevel: .L3
            )
        }
    }

    func lightPlan(from plan: TrainingPlan) -> TrainingPlan {
        let exercises = plan.exercises.map { planned in
            PlannedExercise(
                exercise: planned.exercise,
                sets: max(1, planned.sets - 1),
                reps: max(1, min(planned.reps, (Double(planned.reps) * 0.7).roundedInt())),
                restSeconds: planned.restSeconds + 15,
                isCompleted: planned.isCompleted,
                completedSets: planned.completedSets
            )
        }

        return TrainingPlan(
            id: plan.id,
            date: plan.date,
            exercises: exercises,
            targetDurationMinutes: max(10, (Double(plan.targetDurationMinutes) * 0.75).roundedInt()),
            fitnessLevel: plan.fitnessLevel,
            isCompleted: plan.isCompleted
        )
    }

    private static func storageKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return Keys.dailyPlanPrefix + formatter.string(from: date)
    }

func estimateDuration(for plan: TrainingPlan) -> Int {
        var totalSeconds = 0
        for exercise in plan.exercises {
            let exerciseTime = exercise.sets * exercise.reps * 3
            let restTime = (exercise.sets - 1) * exercise.restSeconds
            totalSeconds += exerciseTime + restTime
        }
        return totalSeconds / 60
    }
}

private extension Double {
    func roundedInt() -> Int {
        Int(rounded())
    }
}
