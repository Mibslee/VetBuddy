import Foundation

struct TrainingRecord: Identifiable, Equatable, Codable, Sendable {
let id: UUID
let date: Date
let exerciseId: String
let exerciseName: String
let completedSets: Int
let completedReps: Int
let durationSeconds: Int
let notes: String

init(
        id: UUID = UUID(),
        date: Date = Date(),
        exerciseId: String,
        exerciseName: String,
        completedSets: Int,
        completedReps: Int,
        durationSeconds: Int,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.completedSets = completedSets
        self.completedReps = completedReps
        self.durationSeconds = durationSeconds
        self.notes = notes
    }
}

struct DailyCheckin: Identifiable, Equatable, Codable, Sendable {
let id: UUID
let date: Date
let completedExerciseCount: Int
let totalExerciseCount: Int
let totalDurationSeconds: Int
let steps: Int?
let heartRate: Double?
let weight: Double?

init(
        id: UUID = UUID(),
        date: Date = Date(),
        completedExerciseCount: Int,
        totalExerciseCount: Int,
        totalDurationSeconds: Int,
        steps: Int? = nil,
        heartRate: Double? = nil,
        weight: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.completedExerciseCount = completedExerciseCount
        self.totalExerciseCount = totalExerciseCount
        self.totalDurationSeconds = totalDurationSeconds
        self.steps = steps
        self.heartRate = heartRate
        self.weight = weight
    }
}

actor TrainingRecordStore {
    static let shared = TrainingRecordStore()

    private var records: [TrainingRecord] = []
    private var checkins: [DailyCheckin] = []
    private let defaults: UserDefaults

    private enum Keys {
        static let records = "vb_training_records"
        static let checkins = "vb_daily_checkins"
    }

init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.records = Self.load([TrainingRecord].self, forKey: Keys.records, from: defaults) ?? []
        self.checkins = Self.load([DailyCheckin].self, forKey: Keys.checkins, from: defaults) ?? []
    }

func addRecord(_ record: TrainingRecord) {
        records.append(record)
        persistRecords()
    }

func addCheckin(_ checkin: DailyCheckin) {
        if let index = checkins.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: checkin.date) }) {
            checkins[index] = checkin
        } else {
            checkins.append(checkin)
        }
        persistCheckins()
    }

func recordsForDate(_ date: Date) -> [TrainingRecord] {
        let calendar = Calendar.current
        return records.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

func allCheckins() -> [DailyCheckin] {
        checkins.sorted { $0.date > $1.date }
    }

func consecutiveStreak(asOf date: Date = Date()) -> Int {
        let calendar = Calendar.current
        let sortedDates = checkins
            .map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)
            .removingDuplicates()

        guard !sortedDates.isEmpty else { return 0 }

        var streak = 0
        let currentDate = calendar.startOfDay(for: date)

        for sortedDate in sortedDates {
            let expectedDate = calendar.date(byAdding: .day, value: -streak, to: currentDate)!
            if calendar.isDate(sortedDate, inSameDayAs: expectedDate) {
                streak += 1
            } else {
                break
            }
        }

        return streak
    }

func totalTrainingDays() -> Int {
        let calendar = Calendar.current
        let uniqueDates = Set(checkins.map { calendar.startOfDay(for: $0.date) })
        return uniqueDates.count
    }

func clearAll() {
        records = []
        checkins = []
        defaults.removeObject(forKey: Keys.records)
        defaults.removeObject(forKey: Keys.checkins)
    }

    private func persistRecords() {
        persist(records, forKey: Keys.records)
    }

    private func persistCheckins() {
        persist(checkins, forKey: Keys.checkins)
    }

    private func persist<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load<T: Decodable>(_ type: T.Type, forKey key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

private extension Array where Element: Equatable {
    func removingDuplicates() -> [Element] {
        var result: [Element] = []
        for element in self where !result.contains(element) {
            result.append(element)
        }
        return result
    }
}
