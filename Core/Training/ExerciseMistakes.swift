import Foundation

struct ExerciseMistake: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let wrongCue: String
    let correction: String
    let imageName: String
}

extension Exercise {
    var commonMistakes: [ExerciseMistake] {
        switch id {
        case "sit_to_stand":
            return [
                mistake(1, "膝盖内扣", "起身时膝盖向内夹，脚掌受力不稳。", "膝盖对准第二脚趾，双脚踩实再起身。"),
                mistake(2, "猛地坐下", "下坐时失去控制，直接摔坐到椅子上。", "臀部先向后找椅子，慢慢坐下。")
            ]
        case "calf_raise":
            return [
                mistake(1, "身体前后晃", "提踵时靠身体摆动借力。", "扶墙只做稳定辅助，脚跟慢起慢落。"),
                mistake(2, "膝盖锁死", "膝盖完全绷直，容易让关节紧张。", "膝盖微松，重心放在前脚掌。")
            ]
        case "wall_sit":
            return [
                mistake(1, "蹲得过深", "一开始就下滑太低，膝盖压力明显增大。", "先浅蹲，膝盖不超过脚尖。"),
                mistake(2, "背部离墙", "腰背悬空，身体向前顶。", "肩背轻贴墙，脚掌踩稳。")
            ]
        case "straight_leg_raise":
            return [
                mistake(1, "腰部拱起", "抬腿太高导致腰背离开垫面。", "先收紧腹部，抬到对侧膝盖高度即可。"),
                mistake(2, "腿直接落下", "下放时失去控制。", "慢慢放回垫面，不借惯性。")
            ]
        case "side_leg_raise":
            return [
                mistake(1, "身体后翻", "抬腿时髋部向后滚，动作变形。", "髋部上下叠放，脚尖略朝前。"),
                mistake(2, "甩腿借力", "腿快速甩上去又掉下来。", "小幅度、慢速度，感受髋侧发力。")
            ]
        case "glute_bridge":
            return [
                mistake(1, "过度挺腰", "抬起时把腰顶高，臀部没有发力。", "收住肋骨，用臀部发力抬起。"),
                mistake(2, "双脚太远", "脚离臀部太远，后腿容易抽紧。", "脚跟靠近臀部到舒适距离。")
            ]
        case "standing_march":
            return [
                mistake(1, "身体后仰", "抬膝时上身向后倒。", "身体站直，抬腿高度降低也可以。"),
                mistake(2, "椅子不稳", "扶的椅子滑动或摇晃。", "换成稳固椅背或墙面。")
            ]
        case "tandem_walk":
            return [
                mistake(1, "一直低头", "视线盯脚，身体更容易晃。", "眼睛看前方，用余光确认脚步。"),
                mistake(2, "步子过大", "急着向前跨，重心转移太快。", "脚跟接脚尖，小步慢走。")
            ]
        default:
            return []
        }
    }

    private func mistake(_ index: Int, _ title: String, _ wrongCue: String, _ correction: String) -> ExerciseMistake {
        ExerciseMistake(
            id: "\(id)_\(index)",
            title: title,
            wrongCue: wrongCue,
            correction: correction,
            imageName: "mistake_\(id)_\(index)"
        )
    }
}
