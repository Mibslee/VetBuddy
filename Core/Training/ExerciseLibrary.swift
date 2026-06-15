import Foundation

struct Exercise: Identifiable, Codable, Equatable, Sendable {
let id: String
let nameCN: String
let nameEN: String
let description: String
let targetMuscle: String
let applicableLevels: [FitnessLevel]
let sets: [FitnessLevel: Int]
let reps: [FitnessLevel: Int]
let restSeconds: [FitnessLevel: Int]
let durationSeconds: Int
let equipment: String
let safetyTips: [String]
let difficultyModifier: [FitnessLevel: String]

init(
        id: String,
        nameCN: String,
        nameEN: String,
        description: String,
        targetMuscle: String,
        applicableLevels: [FitnessLevel],
        sets: [FitnessLevel: Int],
        reps: [FitnessLevel: Int],
        restSeconds: [FitnessLevel: Int],
        durationSeconds: Int,
        equipment: String,
        safetyTips: [String],
        difficultyModifier: [FitnessLevel: String]
    ) {
        self.id = id
        self.nameCN = nameCN
        self.nameEN = nameEN
        self.description = description
        self.targetMuscle = targetMuscle
        self.applicableLevels = applicableLevels
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.durationSeconds = durationSeconds
        self.equipment = equipment
        self.safetyTips = safetyTips
        self.difficultyModifier = difficultyModifier
    }

func setsForLevel(_ level: FitnessLevel) -> Int {
        sets[level] ?? 2
    }

func repsForLevel(_ level: FitnessLevel) -> Int {
        reps[level] ?? 10
    }

func restForLevel(_ level: FitnessLevel) -> Int {
        restSeconds[level] ?? 60
    }
}

struct ExerciseLibrary: Sendable {
static let shared = ExerciseLibrary()

let allExercises: [Exercise] = [
        Exercise(
            id: "sit_to_stand",
            nameCN: "椅子坐立",
            nameEN: "Sit-to-Stand",
            description: "缓慢坐下再站起，锻炼大腿和臀部肌肉",
            targetMuscle: "股四头肌、臀大肌",
            applicableLevels: [.L1, .L2, .L3],
            sets: [.L1: 2, .L2: 3, .L3: 4],
            reps: [.L1: 8, .L2: 12, .L3: 15],
            restSeconds: [.L1: 60, .L2: 45, .L3: 30],
            durationSeconds: 45,
            equipment: "椅子",
            safetyTips: ["膝盖不要超过脚尖", "腰背挺直", "站立时完全伸髋"],
            difficultyModifier: [.L1: "有扶手椅子，可手扶", .L2: "无扶手椅子", .L3: "降低坐垫高度或负重"]
        ),
        Exercise(
            id: "calf_raise",
            nameCN: "提踵",
            nameEN: "Calf Raise",
            description: "踮脚尖再放下，锻炼小腿肌肉",
            targetMuscle: "腓肠肌、比目鱼肌",
            applicableLevels: [.L1, .L2, .L3],
            sets: [.L1: 2, .L2: 3, .L3: 4],
            reps: [.L1: 10, .L2: 15, .L3: 20],
            restSeconds: [.L1: 60, .L2: 45, .L3: 30],
            durationSeconds: 40,
            equipment: "扶墙（L1）、防滑垫脚物（可选）",
            safetyTips: ["慢起慢放，2秒起2秒落", "脚尖垫高时确认物体稳定防滑", "注意小腿抽筋风险", "扶墙或扶椅保持平衡"],
            difficultyModifier: [.L1: "双脚，扶墙", .L2: "双脚，不扶墙", .L3: "单脚交替"]
        ),
        Exercise(
            id: "wall_sit",
            nameCN: "靠墙静蹲",
            nameEN: "Wall Sit",
            description: "背靠墙壁保持半蹲姿势",
            targetMuscle: "股四头肌、核心",
            applicableLevels: [.L1, .L2, .L3],
            sets: [.L1: 2, .L2: 3, .L3: 3],
            reps: [.L1: 1, .L2: 1, .L3: 1],
            restSeconds: [.L1: 60, .L2: 45, .L3: 30],
            durationSeconds: 30,
            equipment: "墙壁",
            safetyTips: ["脚跟离墙约50厘米", "膝盖不超过脚尖", "下背贴墙", "有严重膝关节炎者避免超过60度"],
            difficultyModifier: [.L1: "浅蹲30度，15秒", .L2: "半蹲45度，30秒", .L3: "深蹲60度，60秒"]
        ),
        Exercise(
            id: "straight_leg_raise",
            nameCN: "直腿抬高",
            nameEN: "Straight Leg Raise",
            description: "仰卧抬腿，锻炼大腿前侧",
            targetMuscle: "股四头肌、髂腰肌",
            applicableLevels: [.L1, .L2, .L3],
            sets: [.L1: 2, .L2: 3, .L3: 3],
            reps: [.L1: 8, .L2: 12, .L3: 15],
            restSeconds: [.L1: 60, .L2: 45, .L3: 30],
            durationSeconds: 40,
            equipment: "瑜伽垫",
            safetyTips: ["抬腿至与对侧膝同高即可", "核心收紧防腰痛", "特别适合膝关节术后康复"],
            difficultyModifier: [.L1: "无负重", .L2: "增加保持时间", .L3: "脚踝沙袋0.5-1kg"]
        ),
        Exercise(
            id: "side_leg_raise",
            nameCN: "侧抬腿",
            nameEN: "Side-Lying Leg Raise",
            description: "侧卧抬腿，锻炼臀中肌",
            targetMuscle: "臀中肌、臀小肌",
            applicableLevels: [.L1, .L2, .L3],
            sets: [.L1: 2, .L2: 3, .L3: 3],
            reps: [.L1: 8, .L2: 12, .L3: 15],
            restSeconds: [.L1: 60, .L2: 45, .L3: 30],
            durationSeconds: 40,
            equipment: "瑜伽垫",
            safetyTips: ["上方腿伸直上抬45度", "髋部不要旋转", "控制速度，避免惯性"],
            difficultyModifier: [.L1: "无负重", .L2: "增加弹力带", .L3: "脚踝沙袋1-2kg"]
        ),
        Exercise(
            id: "glute_bridge",
            nameCN: "桥式",
            nameEN: "Glute Bridge",
            description: "仰卧抬臀，锻炼臀部和后链",
            targetMuscle: "臀大肌、腘绳肌、核心",
            applicableLevels: [.L1, .L2, .L3],
            sets: [.L1: 2, .L2: 3, .L3: 3],
            reps: [.L1: 8, .L2: 12, .L3: 15],
            restSeconds: [.L1: 60, .L2: 45, .L3: 30],
            durationSeconds: 40,
            equipment: "瑜伽垫",
            safetyTips: ["脚掌平踏地面", "抬臀至肩-髋-膝一线", "避免过度挺腰"],
            difficultyModifier: [.L1: "双脚支撑", .L2: "增加保持时间", .L3: "单脚桥式"]
        ),
        Exercise(
            id: "standing_march",
            nameCN: "站姿提腿",
            nameEN: "Standing March",
            description: "原地高抬腿踏步，锻炼髋屈肌和平衡",
            targetMuscle: "髂腰肌、股四头肌、核心",
            applicableLevels: [.L1, .L2, .L3],
            sets: [.L1: 2, .L2: 3, .L3: 3],
            reps: [.L1: 10, .L2: 15, .L3: 20],
            restSeconds: [.L1: 60, .L2: 45, .L3: 30],
            durationSeconds: 45,
            equipment: "扶椅（L1）",
            safetyTips: ["膝盖抬至与髋同高", "保持腰背挺直", "60+最好的入门平衡+力量复合动作"],
            difficultyModifier: [.L1: "慢速低位，扶椅背", .L2: "中速中位", .L3: "高抬腿，不扶"]
        ),
        Exercise(
            id: "tandem_walk",
            nameCN: "脚跟-脚尖串联走",
            nameEN: "Tandem Walk",
            description: "脚跟贴脚尖走直线，锻炼平衡能力",
            targetMuscle: "核心、小腿、平衡系统",
            applicableLevels: [.L1, .L2, .L3],
            sets: [.L1: 2, .L2: 3, .L3: 3],
            reps: [.L1: 6, .L2: 10, .L3: 15],
            restSeconds: [.L1: 60, .L2: 45, .L3: 30],
            durationSeconds: 40,
            equipment: "扶墙（L1）",
            safetyTips: ["脚跟贴脚尖走直线", "初期必须靠墙或有人看护", "预防跌倒的核心平衡训练"],
            difficultyModifier: [.L1: "扶墙，短距离", .L2: "扶墙，长距离", .L3: "不扶墙"]
        )
    ]

func exercisesForLevel(_ level: FitnessLevel) -> [Exercise] {
        allExercises.filter { $0.applicableLevels.contains(level) }
    }

func exercise(byId id: String) -> Exercise? {
        allExercises.first { $0.id == id }
    }
}
