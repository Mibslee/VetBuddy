import Foundation

/// Persistence service for assessment results.
/// Stores the latest result in UserDefaults for quick access.
final class AssessmentService {

    private let defaults: UserDefaults

    private enum Keys {
        static let resultData = "vb_assessment_result"
        static let answersData = "vb_assessment_answers"
        static let completed = "vb_assessment_completed"
        static let version = "vb_assessment_version"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Save

    func saveAssessment(_ result: AssessmentResult, answers: [Answer]) {
        if let data = try? JSONEncoder().encode(result) {
            defaults.set(data, forKey: Keys.resultData)
        }
        if let data = try? JSONEncoder().encode(answers) {
            defaults.set(data, forKey: Keys.answersData)
        }
        defaults.set(QuestionBank.version, forKey: Keys.version)
        defaults.set(true, forKey: Keys.completed)
    }

    // MARK: - Load

    func loadLatestAssessment() -> AssessmentResult? {
        guard let data = defaults.data(forKey: Keys.resultData) else {
            return nil
        }
        return try? JSONDecoder().decode(AssessmentResult.self, from: data)
    }

    func loadSavedAnswers() -> [Answer]? {
        guard let data = defaults.data(forKey: Keys.answersData) else {
            return nil
        }
        return try? JSONDecoder().decode([Answer].self, from: data)
    }

    // MARK: - Status

    func hasCompletedAssessment() -> Bool {
        defaults.bool(forKey: Keys.completed)
    }

    func savedVersion() -> Int {
        defaults.integer(forKey: Keys.version)
    }

    // MARK: - Clear

    func clearAssessment() {
        defaults.removeObject(forKey: Keys.resultData)
        defaults.removeObject(forKey: Keys.answersData)
        defaults.removeObject(forKey: Keys.version)
        defaults.set(false, forKey: Keys.completed)
    }
}

