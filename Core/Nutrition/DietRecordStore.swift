import Foundation

enum MealType: String, CaseIterable, Codable, Identifiable, Sendable {
    case breakfast
    case lunch
    case dinner
    case snack

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .breakfast: return "早餐"
        case .lunch: return "午餐"
        case .dinner: return "晚餐"
        case .snack: return "加餐"
        }
    }
}

struct DietLogEntry: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let date: Date
    let mealType: MealType
    let foodName: String
    let grams: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mealType: MealType,
        foodName: String,
        grams: Double,
        proteinPer100g: Double,
        carbsPer100g: Double,
        fatPer100g: Double
    ) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.foodName = foodName
        self.grams = grams
        self.proteinPer100g = proteinPer100g
        self.carbsPer100g = carbsPer100g
        self.fatPer100g = fatPer100g
    }

    var proteinG: Double { grams * proteinPer100g / 100.0 }
    var carbsG: Double { grams * carbsPer100g / 100.0 }
    var fatG: Double { grams * fatPer100g / 100.0 }
}

struct DietMacroSummary: Equatable, Sendable {
    let proteinG: Double
    let carbsG: Double
    let fatG: Double

    var calories: Int {
        Int((proteinG * 4.0) + (carbsG * 4.0) + (fatG * 9.0))
    }
}

enum MacroStatus: String, Equatable, Sendable {
    case low
    case onTrack
    case high

    var displayName: String {
        switch self {
        case .low: return "偏低"
        case .onTrack: return "合适"
        case .high: return "偏高"
        }
    }
}

struct MacroNutrientAnalysis: Equatable, Sendable {
    let name: String
    let actualG: Double
    let targetG: Int
    let status: MacroStatus
}

struct DietMacroAnalysis: Equatable, Sendable {
    let summary: DietMacroSummary
    let protein: MacroNutrientAnalysis
    let carbs: MacroNutrientAnalysis
    let fat: MacroNutrientAnalysis
    let message: String

    var nutrients: [MacroNutrientAnalysis] {
        [protein, carbs, fat]
    }
}

enum DietAnalyzer {
    static func summarize(_ entries: [DietLogEntry]) -> DietMacroSummary {
        DietMacroSummary(
            proteinG: entries.reduce(0) { $0 + $1.proteinG },
            carbsG: entries.reduce(0) { $0 + $1.carbsG },
            fatG: entries.reduce(0) { $0 + $1.fatG }
        )
    }

    static func analyze(entries: [DietLogEntry], requirements: NutritionRequirements) -> DietMacroAnalysis {
        let summary = summarize(entries)
        let protein = analyzeNutrient(name: "蛋白质", actual: summary.proteinG, target: requirements.proteinG)
        let carbs = analyzeNutrient(name: "碳水", actual: summary.carbsG, target: requirements.carbsG)
        let fat = analyzeNutrient(name: "脂肪", actual: summary.fatG, target: requirements.fatG)

        let message: String
        if protein.status == .onTrack, carbs.status == .onTrack, fat.status == .onTrack {
            message = "今日摄入与当前目标基本匹配。"
        } else if protein.status == .low {
            message = "今日蛋白质偏低，可优先补充鸡蛋、鱼禽、豆制品或无糖奶制品。"
        } else if carbs.status == .high {
            message = "今日碳水偏高，下一餐建议减少精制主食，增加蔬菜和优质蛋白。"
        } else {
            message = "今日摄入与目标有偏差，建议按下方项目调整下一餐。"
        }

        return DietMacroAnalysis(
            summary: summary,
            protein: protein,
            carbs: carbs,
            fat: fat,
            message: message
        )
    }

    private static func analyzeNutrient(name: String, actual: Double, target: Int) -> MacroNutrientAnalysis {
        let lower = Double(target) * 0.90
        let upper = Double(target) * 1.10
        let status: MacroStatus
        if actual < lower {
            status = .low
        } else if actual > upper {
            status = .high
        } else {
            status = .onTrack
        }
        return MacroNutrientAnalysis(name: name, actualG: actual, targetG: target, status: status)
    }
}

struct DietRecordStore {
    private let defaults: UserDefaults

    private enum Keys {
        static let entries = "vb_diet_entries"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadEntries(for date: Date = Date()) -> [DietLogEntry] {
        let entries = loadAllEntries()
        return entries
            .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date > $1.date }
    }

    func addEntry(_ entry: DietLogEntry) {
        var entries = loadAllEntries()
        entries.append(entry)
        save(entries)
    }

    func deleteEntry(id: UUID) {
        let entries = loadAllEntries().filter { $0.id != id }
        save(entries)
    }

    func clearAll() {
        defaults.removeObject(forKey: Keys.entries)
    }

    private func loadAllEntries() -> [DietLogEntry] {
        guard let data = defaults.data(forKey: Keys.entries) else { return [] }
        return (try? JSONDecoder().decode([DietLogEntry].self, from: data)) ?? []
    }

    private func save(_ entries: [DietLogEntry]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: Keys.entries)
    }
}
