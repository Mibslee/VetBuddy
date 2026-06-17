import Foundation

extension Exercise {
    var beforeStartNotes: [String] {
        switch id {
        case "sit_to_stand":
            return [
                "选择稳定、不带轮子的椅子，椅背可靠墙更稳。",
                "双脚踩实，椅子高度以起身不憋气、不疼痛为准。"
            ]
        case "calf_raise":
            return [
                "可以用稳定的厚书、瑜伽砖或低台阶垫高脚尖，让脚跟有少量下落空间。",
                "垫脚物必须防滑、平整、不会晃动；不稳定时不要使用。",
                "初练时请用一只手扶墙或扶稳固椅背，先双脚同时练习。"
            ]
        case "wall_sit":
            return [
                "选择平整墙面，脚下不要有地毯褶皱或湿滑区域。",
                "双脚向前离墙一小步，先从浅蹲角度开始。"
            ]
        case "straight_leg_raise", "side_leg_raise", "glute_bridge":
            return [
                "使用防滑瑜伽垫，周围留出足够空间。",
                "先调整到舒适体位，腰背或髋部疼痛时不要勉强。"
            ]
        case "standing_march":
            return [
                "使用稳固椅背或墙面辅助，椅子不能滑动。",
                "脚下保持干燥，先用低高度慢速练习。"
            ]
        case "tandem_walk":
            return [
                "靠墙或扶手练习，地面保持平整无杂物。",
                "刚开始走短距离即可，必要时请家人在旁看护。"
            ]
        default:
            return []
        }
    }

    var alwaysRememberNotes: [String] {
        switch id {
        case "sit_to_stand":
            return ["臀部先后坐，膝盖对准脚尖。", "起身和坐下都要慢，不要突然摔坐。"]
        case "calf_raise":
            return ["慢起慢落，重心保持在前脚掌。", "膝盖微松，不要锁死，扶墙只做稳定辅助。"]
        case "wall_sit":
            return ["背部轻贴墙，膝盖不要超过脚尖。", "保持浅到中等深度，不追求蹲得更低。"]
        case "straight_leg_raise":
            return ["先收紧核心，再抬腿。", "抬到与另一侧膝盖差不多高即可。"]
        case "side_leg_raise":
            return ["髋部上下叠放，身体不要向后滚。", "抬腿和落腿都要控制，不借惯性。"]
        case "glute_bridge":
            return ["脚掌踩稳，臀部发力抬起。", "肩、髋、膝尽量成一直线，不要过度挺腰。"]
        case "standing_march":
            return ["躯干保持直立，左右交替慢慢抬腿。", "晃动明显时降低抬腿高度。"]
        case "tandem_walk":
            return ["脚跟尽量接近脚尖，步子小一点。", "眼睛看前方，手只做轻扶辅助。"]
        default:
            return safetyTips
        }
    }

    var stopConditionNotes: [String] {
        [
            "出现胸闷、头晕、明显疼痛或呼吸异常时立即停止。",
            "动作明显不稳、器械滑动或场地不安全时立即停止。"
        ]
    }

    var spokenGuidanceText: String {
        var sections: [String] = [
            "\(nameCN)。\(description)。"
        ]

        appendSpokenSection("开始前确认", notes: beforeStartNotes, to: &sections)
        appendSpokenSection("全程记住", notes: alwaysRememberNotes, to: &sections)
        appendSpokenSection("立即停止", notes: stopConditionNotes, to: &sections)

        sections.append("本内容仅用于健康管理和动作示范，不构成医学诊断或治疗建议。")
        return sections.joined(separator: " ")
    }

    var rhythmGuidanceText: String {
        switch id {
        case "sit_to_stand":
            return "准备。身体微微前倾，三、二、一。缓慢起立，三、二、一。站稳保持，三、二、一。臀部向后，缓慢坐下，三、二、一。"
        case "calf_raise":
            return "准备扶稳。脚跟慢慢抬起，三、二、一。最高点停住，三、二、一。脚跟慢慢落下，三、二、一。"
        case "wall_sit":
            return "背部贴墙。慢慢下滑，三、二、一。保持呼吸，三、二、一。脚掌踩稳，慢慢站回，三、二、一。"
        case "straight_leg_raise":
            return "仰卧准备。收紧腹部，三、二、一。直腿慢慢抬起，三、二、一。控制放下，三、二、一。"
        case "side_leg_raise":
            return "侧卧对齐。上方腿慢慢抬起，三、二、一。保持稳定，三、二、一。慢慢落回，三、二、一。"
        case "glute_bridge":
            return "屈膝踩稳。臀部慢慢抬起，三、二、一。肩髋膝成一线，保持，三、二、一。慢慢落下，三、二、一。"
        case "standing_march":
            return "扶稳站直。右腿慢慢抬起，三、二、一。右脚踩稳。左腿慢慢抬起，三、二、一。左脚踩稳。"
        case "tandem_walk":
            return "靠墙准备。脚跟接脚尖，慢慢迈步，三、二、一。站稳再下一步，三、二、一。眼睛看前方，保持呼吸。"
        default:
            return "动作开始。保持缓慢稳定，三、二、一。控制返回，三、二、一。"
        }
    }

    private func appendSpokenSection(_ title: String, notes: [String], to sections: inout [String]) {
        guard !notes.isEmpty else { return }
        let text = notes.map { note in
            note.trimmingCharacters(in: CharacterSet(charactersIn: "。.!！?？"))
        }
        .joined(separator: "；")
        sections.append("\(title)：\(text)。")
    }
}
