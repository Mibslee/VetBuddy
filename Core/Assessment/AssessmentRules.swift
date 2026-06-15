import Foundation

/// Pure-function assessment evaluator. No side effects.
enum AssessmentEvaluator {

    // MARK: - Public API

    /// Evaluates answers and returns a complete assessment result.
    static func evaluate(_ answers: [Answer]) -> AssessmentResult {
        let riskLevel = determineRiskLevel(answers)
        let fitnessLevel = determineFitnessLevel(answers)
        let ckdLevel = determineCKDLevel(answers)
        return buildResult(
            answers: answers,
            riskLevel: riskLevel,
            fitnessLevel: fitnessLevel,
            ckdLevel: ckdLevel
        )
    }

    // MARK: - Risk Level

    /// Determines risk level from answers.
    ///
    /// Red flag (红旗禁止):
    /// - Q4 = yes (心脏病)
    /// - Q5 = yes AND Q6 = under6Months (近期髋部手术)
    /// - Q2 = yes AND Q3 = no (未控制的高血压)
    ///
    /// Caution (谨慎模式):
    /// - Q2 = yes AND Q3 = yes (药物控制的高血压)
    /// - Q6 = sixTo12Months (手术 6-12 个月)
    /// - Q8 = yes (慢性肾病)
    ///
    /// Standard (标准模式): none of the above.
    static func determineRiskLevel(_ answers: [Answer]) -> RiskLevel {
        if isRedFlag(answers) { return .redFlag }
        if isCaution(answers) { return .caution }
        return .standard
    }

    // MARK: - Fitness Level

    /// Determines fitness level from activity (Q7).
    /// Always computed; view logic decides whether to use it.
    static func determineFitnessLevel(_ answers: [Answer]) -> FitnessLevel {
        let answer = findAnswer(7, in: answers)
        switch answer {
        case ActivityLevel.occasional.rawValue:
            return .L2
        case ActivityLevel.regular.rawValue, ActivityLevel.active.rawValue:
            return .L3
        default:
            return .L1
        }
    }

    // MARK: - CKD Level

    /// Determines CKD level from Q8 answer.
    static func determineCKDLevel(_ answers: [Answer]) -> CKDLevel {
        let answer = findAnswer(8, in: answers)
        switch answer {
        case TriChoice.yes.rawValue:
            switch findAnswer(11, in: answers) {
            case CKDStageChoice.stage1to2.rawValue:
                return .stage1to2
            case CKDStageChoice.stage3.rawValue:
                return .stage3
            case CKDStageChoice.stage4to5.rawValue:
                return .stage4to5
            case CKDStageChoice.unsure.rawValue:
                return .unknown
            default:
                return .stage3
            }
        case TriChoice.no.rawValue:
            return .none
        case TriChoice.unsure.rawValue:
            return .unknown
        default:
            return .none
        }
    }

    // MARK: - Internal

    static func isRedFlag(_ answers: [Answer]) -> Bool {
        // Q4: heart disease
        if findAnswer(4, in: answers) == TriChoice.yes.rawValue {
            return true
        }
        // Q5 + Q6: recent hip/leg surgery (< 6 months)
        if findAnswer(5, in: answers) == TriChoice.yes.rawValue
            && findAnswer(6, in: answers) == SurgeryRecency.under6Months.rawValue {
            return true
        }
        // Q2 + Q3: uncontrolled hypertension
        if findAnswer(2, in: answers) == TriChoice.yes.rawValue
            && findAnswer(3, in: answers) == TriChoice.no.rawValue {
            return true
        }
        return false
    }

    static func isCaution(_ answers: [Answer]) -> Bool {
        // Q2 + Q3: controlled hypertension
        if findAnswer(2, in: answers) == TriChoice.yes.rawValue
            && findAnswer(3, in: answers) == TriChoice.yes.rawValue {
            return true
        }
        // Q6: surgery 6-12 months ago
        if findAnswer(6, in: answers) == SurgeryRecency.sixTo12Months.rawValue {
            return true
        }
        // Q8: CKD
        if findAnswer(8, in: answers) == TriChoice.yes.rawValue {
            return true
        }
        return false
    }

    // MARK: - Private Helpers

    private static func findAnswer(_ questionId: Int, in answers: [Answer]) -> String? {
        answers.first { $0.questionId == questionId }?.value
    }

    private static func boolFromTriChoice(_ questionId: Int, in answers: [Answer]) -> Bool {
        findAnswer(questionId, in: answers) == TriChoice.yes.rawValue
    }

    private static func buildResult(
        answers: [Answer],
        riskLevel: RiskLevel,
        fitnessLevel: FitnessLevel,
        ckdLevel: CKDLevel
    ) -> AssessmentResult {
        let hasHeartDisease = boolFromTriChoice(4, in: answers)
        let hasCKD = boolFromTriChoice(8, in: answers)
        let hasDiabetes = boolFromTriChoice(9, in: answers)
        let ageRange = findAnswer(1, in: answers) ?? AgeRange.range60to65.rawValue
        return AssessmentResult(
            date: Date(),
            riskLevel: riskLevel,
            fitnessLevel: fitnessLevel,
            hasHeartDisease: hasHeartDisease,
            hasCKD: hasCKD,
            ckdLevel: ckdLevel,
            hasDiabetes: hasDiabetes,
            ageRange: ageRange
        )
    }
}
