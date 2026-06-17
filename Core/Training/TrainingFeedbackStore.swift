import Foundation

enum TrainingEffort: String, CaseIterable, Codable, Identifiable, Sendable {
    case easy
    case justRight
    case tooHard

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .easy: return "轻松"
        case .justRight: return "正好"
        case .tooHard: return "太累"
        }
    }
}

enum TrainingDiscomfort: String, CaseIterable, Codable, Identifiable, Sendable {
    case none
    case knee
    case back
    case dizzy
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "无不适"
        case .knee: return "膝盖不适"
        case .back: return "腰背不适"
        case .dizzy: return "头晕"
        case .other: return "其他不适"
        }
    }
}

struct TrainingFeedback: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let date: Date
    let effort: TrainingEffort
    let discomfort: TrainingDiscomfort

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        effort: TrainingEffort,
        discomfort: TrainingDiscomfort
    ) {
        self.id = id
        self.date = date
        self.effort = effort
        self.discomfort = discomfort
    }
}

struct TrainingFeedbackStore {
    private let defaults: UserDefaults

    private enum Keys {
        static let feedback = "vb_training_feedback"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ feedback: TrainingFeedback) {
        var items = loadAll()
        if let index = items.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: feedback.date) }) {
            items[index] = feedback
        } else {
            items.append(feedback)
        }
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: Keys.feedback)
    }

    func latest() -> TrainingFeedback? {
        loadAll().sorted { $0.date > $1.date }.first
    }

    private func loadAll() -> [TrainingFeedback] {
        guard let data = defaults.data(forKey: Keys.feedback) else { return [] }
        return (try? JSONDecoder().decode([TrainingFeedback].self, from: data)) ?? []
    }
}
