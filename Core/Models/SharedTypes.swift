import Foundation

// MARK: - Enums

enum RiskLevel: String, Codable, Sendable {
    case redFlag = "red_flag"
    case caution
    case standard
}

enum FitnessLevel: String, Codable, Sendable {
    case L1, L2, L3
}

enum CKDLevel: String, Codable, Sendable {
    case none
    case stage1to2 = "stage_1_2"
    case stage3 = "stage_3"
    case stage4to5 = "stage_4_5"
    case unknown
}

enum BiologicalSex: String, Codable, CaseIterable, Sendable {
    case unspecified
    case male
    case female

    var displayName: String {
        switch self {
        case .unspecified: return "未填写"
        case .male: return "男"
        case .female: return "女"
        }
    }
}

// MARK: - Value Types

struct AssessmentResult: Codable, Equatable, Sendable {
    let date: Date
    let riskLevel: RiskLevel
    let fitnessLevel: FitnessLevel
    let hasHeartDisease: Bool
    let hasCKD: Bool
    let ckdLevel: CKDLevel
    let hasDiabetes: Bool
    let ageRange: String

    init(
        date: Date,
        riskLevel: RiskLevel,
        fitnessLevel: FitnessLevel,
        hasHeartDisease: Bool,
        hasCKD: Bool,
        ckdLevel: CKDLevel = .none,
        hasDiabetes: Bool,
        ageRange: String
    ) {
        self.date = date
        self.riskLevel = riskLevel
        self.fitnessLevel = fitnessLevel
        self.hasHeartDisease = hasHeartDisease
        self.hasCKD = hasCKD
        self.ckdLevel = hasCKD && ckdLevel == .none ? .stage3 : ckdLevel
        self.hasDiabetes = hasDiabetes
        self.ageRange = ageRange
    }

    private enum CodingKeys: String, CodingKey {
        case date, riskLevel, fitnessLevel, hasHeartDisease, hasCKD, ckdLevel, hasDiabetes, ageRange
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        riskLevel = try container.decode(RiskLevel.self, forKey: .riskLevel)
        fitnessLevel = try container.decode(FitnessLevel.self, forKey: .fitnessLevel)
        hasHeartDisease = try container.decode(Bool.self, forKey: .hasHeartDisease)
        hasCKD = try container.decode(Bool.self, forKey: .hasCKD)
        ckdLevel = try container.decodeIfPresent(CKDLevel.self, forKey: .ckdLevel) ?? (hasCKD ? .stage3 : .none)
        hasDiabetes = try container.decode(Bool.self, forKey: .hasDiabetes)
        ageRange = try container.decode(String.self, forKey: .ageRange)
    }
}

struct DailySummary: Codable, Equatable, Sendable {
    let date: Date
    let steps: Int
    let heartRate: Double?
    let weight: Double?

    static func == (lhs: DailySummary, rhs: DailySummary) -> Bool {
        Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
            && lhs.steps == rhs.steps
            && lhs.heartRate == rhs.heartRate
            && lhs.weight == rhs.weight
    }
}
