import Foundation

// MARK: - Question Enums

enum AgeRange: String, Codable, CaseIterable {
    case range60to65 = "range_60_65"
    case range65to70 = "range_65_70"
    case range70to75 = "range_70_75"
    case range75plus = "range_75_plus"

    var displayText: String {
        switch self {
        case .range60to65: return "60 ~ 65 岁"
        case .range65to70: return "65 ~ 70 岁"
        case .range70to75: return "70 ~ 75 岁"
        case .range75plus: return "75 岁以上"
        }
    }
}

enum TriChoice: String, Codable {
    case yes, no, unsure
}

enum ActivityLevel: String, Codable {
    case sedentary, occasional, regular, active

    var displayText: String {
        switch self {
        case .sedentary: return "几乎不活动"
        case .occasional: return "偶尔散步"
        case .regular: return "经常散步"
        case .active: return "规律运动"
        }
    }
}

enum SurgeryRecency: String, Codable {
    case under6Months = "under_6_months"
    case sixTo12Months = "six_to_12_months"
    case over12Months = "over_12_months"

    var displayText: String {
        switch self {
        case .under6Months: return "不到 6 个月"
        case .sixTo12Months: return "6 ~ 12 个月"
        case .over12Months: return "超过 12 个月"
        }
    }
}

enum CKDStageChoice: String, Codable, CaseIterable {
    case stage1to2 = "stage_1_2"
    case stage3 = "stage_3"
    case stage4to5 = "stage_4_5"
    case unsure

    var displayText: String {
        switch self {
        case .stage1to2: return "1 ~ 2 期"
        case .stage3: return "3 期"
        case .stage4to5: return "4 ~ 5 期"
        case .unsure: return "不确定"
        }
    }
}

// MARK: - Question Types

enum QuestionType {
    case ageRange
    case triChoice
    case surgeryRecency
    case activityLevel
    case ckdStage
}

// MARK: - Data Models

struct Question: Identifiable {
    let id: Int
    let text: String
    let type: QuestionType
    let isConditional: Bool
    let parentQuestionId: Int?
    let parentRequiredAnswer: String?

    init(
        id: Int,
        text: String,
        type: QuestionType,
        isConditional: Bool = false,
        parentQuestionId: Int? = nil,
        parentRequiredAnswer: String? = nil
    ) {
        self.id = id
        self.text = text
        self.type = type
        self.isConditional = isConditional
        self.parentQuestionId = parentQuestionId
        self.parentRequiredAnswer = parentRequiredAnswer
    }
}

struct Answer: Codable {
    let questionId: Int
    let value: String
}

// MARK: - Question Bank

enum QuestionBank {
    static let questions: [Question] = [
        Question(
            id: 1,
            text: "请问您的年龄段是？",
            type: .ageRange
        ),
        Question(
            id: 2,
            text: "您是否有高血压？",
            type: .triChoice
        ),
        Question(
            id: 3,
            text: "您的高血压是否在药物控制中？",
            type: .triChoice,
            isConditional: true,
            parentQuestionId: 2,
            parentRequiredAnswer: TriChoice.yes.rawValue
        ),
        Question(
            id: 4,
            text: "您是否有心脏病？",
            type: .triChoice
        ),
        Question(
            id: 5,
            text: "您的髋部或腿部是否做过大手术？",
            type: .triChoice
        ),
        Question(
            id: 6,
            text: "手术距今多久？",
            type: .surgeryRecency,
            isConditional: true,
            parentQuestionId: 5,
            parentRequiredAnswer: TriChoice.yes.rawValue
        ),
        Question(
            id: 7,
            text: "您平时的体力活动情况是？",
            type: .activityLevel
        ),
        Question(
            id: 8,
            text: "您是否有慢性肾病 (CKD)？",
            type: .triChoice
        ),
        Question(
            id: 11,
            text: "医生告知您的慢性肾病分期是？",
            type: .ckdStage,
            isConditional: true,
            parentQuestionId: 8,
            parentRequiredAnswer: TriChoice.yes.rawValue
        ),
        Question(
            id: 9,
            text: "您是否有糖尿病？",
            type: .triChoice
        ),
        Question(
            id: 10,
            text: "近 6 个月内您是否有过跌倒？",
            type: .triChoice
        )
    ]

    static let version = 1
}
