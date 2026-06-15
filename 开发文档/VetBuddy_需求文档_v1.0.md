---
title: VetBuddy (老铁) 需求文档 v1.0
created: 2026-06-09
updated: 2026-06-09
tags: [project/iOS, VetBuddy, prd, v1.0, ShaneStudio]
status: active
author: ShaneStudio
---

# VetBuddy (老铁) — 需求文档 v1.0

> **作者**: ShaneStudio
> **版本**: v1.0
> **日期**: 2026-06-09
> **状态**: 锁定, 可进入开发
> **目标平台**: iOS 17+ (后续 v2 拓展鸿蒙 HarmonyOS)
> **运行模式**: 单机本地, 不建后端
> **命名历史**: v0.1 阶段曾用"IronBuddy 老年版"作为代号, v0.2 起正式定名 **VetBuddy (老铁)**

---

## 1. 项目背景

### 1.1 立项初心
父母年纪渐长, 日常以走路为主, 缺乏针对性训练, 下肢肌肉退化加速。现有运动 App (Keep / 薄荷健康 等) 多针对年轻人, 缺少针对 60+ 用户的:
- 风险筛查 (高血压/心脏病/术后 6 月)
- 强度分级 (EWGSOP2 sarcopenia 评估 L1/L2/L3)
- 老人友好 UI (大字体/高对比/3D 动画示范)
- 饮食建议联动 (CKD 分层 / 增蛋白 / 减精碳)

### 1.2 差异化定位
- **人群**: 60+ 中老年, 起步用户 (健康, 无运动习惯)
- **核心动作**: 8 个腿部动作 (减缓下肢肌肉退化)
- **拓展**: 全身训练, 但 v1 聚焦腿部
- **不与太极/八段锦 App 竞争** — 那些"粗陋简单, 针对性不强, 上手难"

### 1.3 目标用户 (v1 起步画像)
- 年龄 60+, 健康, 但无运动习惯
- iPhone 用户 (iOS 17+), 可能有 Apple Watch (但不强求)
- 子女送手机/帮忙装, 老人自己日常使用
- 文化程度: 能用微信/支付宝即可

### 1.4 红旗用户策略 (v0.2 用户决策)
- 启动问卷检测到红旗（心脏病 / 髋部大手术 < 6 月 / 高血压未控制）→ **仍可进入 app**, 训练页锁定, **仅展示饮食建议页**, 文案"建议咨询医生后再开始运动"
- 体现"不能动也能看"的产品温度

---

## 2. 核心功能 (v1 MVP)

### 2.1 功能总览

| # | 功能 | 优先级 | 备注 |
|---|---|---|---|
| F1 | 启动前健康问卷 + 风险分级 | P0 | 8-10 题固定 + 动态追问 |
| F2 | 8 个腿部动作 3D 动画示范 | P0 | Mixamo 卡通人 + RealityKit |
| F3 | 每日训练计划生成 | P0 | 基于分级结果定制 |
| F4 | 打卡 + 训练记录 | P0 | 本地 Core Data |
| F5 | 饮食建议 + 风险提示 | P0 | 启动问卷联动, CKD 分层 |
| F6 | HealthKit 数据读取 | P0 | 步数/心率/体重 (本期实现) |
| F7 | 运动海报生成 + 微信分享 | P0 | 国风水墨风, iOS Share Sheet |
| F8 | 视频动作 AI 纠错 | P0 | Apple Vision 本地, 次数/时长记录 |
| F9 | 家人账号 / 医生审核 | v2 | 本期**不做**, 后置 |
| F10 | 内容订阅 / 商业化 | v3 | 未来探索 |

### 2.2 功能详情

#### F1 — 启动前健康问卷 + 风险分级

**触发**: 首次启动, 或用户主动从"我的 → 重新评估"入口

**问卷结构** (固定 8-10 题):

| # | 问题 | 类型 | 用途 |
|---|---|---|---|
| Q1 | 年龄 | 单选 (60-65/65-70/70-75/75+) | 分级辅助 |
| Q2 | 是否有高血压 | 是/否/不确定 | 红旗筛查 |
| Q3 | 高血压是否药物控制中 | 是/否/无高血压 | 红旗细化 |
| Q4 | 是否有心脏病 | 是/否/不确定 | 红旗筛查 |
| Q5 | 髋部/腿部是否做过大手术 | 是/否 | 红旗筛查 |
| Q6 | (Q5=是) 手术距今多久 | <6 月 / 6-12 月 / >12 月 | 红旗细化 |
| Q7 | 日常体力活动 | 几乎不活动 / 偶尔散步 / 经常散步 / 规律运动 | L1/L2/L3 分级 |
| Q8 | 是否有慢性肾病 (CKD) | 是/否/不确定 | 饮食风险 |
| Q9 | 是否有糖尿病 | 是/否/不确定 | 饮食建议 |
| Q10 | 近 6 月是否有过跌倒 | 是/否 | 平衡训练推荐 |

**分级算法**:

| 风险等级 | 触发条件 | 推荐内容 |
|---|---|---|
| 🔴 **红旗禁止** | Q4=是(心脏病) OR Q5=是且 Q6<6月 OR Q2=是且 Q3=否 | **可进 app**, 训练内容锁定, **仅展示饮食建议页**, 顶部提示"建议咨询医生后再开始运动" |
| 🟡 **谨慎模式** | Q2=是但控制中 OR Q6=6-12月 OR Q8=是(CKD) | 低强度训练 (L1), 饮食加强, 弹窗提醒 |
| 🟢 **标准模式 (L1/L2/L3)** | 无红旗 | 正常训练 + 饮食建议; L1 (几乎不活动) → L2 (偶尔) → L3 (经常/规律) |

**数据存储**: `UserDefaults` (单次) + `Core Data` (历史, 便于重新评估)

#### F2 — 8 个腿部动作 3D 动画

**8 个动作** (基于 v0.1 调研 WHO 2020 + ACSM 11th ed + EWGSOP2 推荐):

| # | 动作 (中) | 动作 (英) | 适用强度 | 器械 |
|---|---|---|---|---|
| 1 | 椅子坐立 | Sit-to-Stand | L1-L3 | 椅子 |
| 2 | 提踵 | Calf Raise | L1-L3 | 扶墙 (L1) → 无 (L3) |
| 3 | 靠墙静蹲 | Wall Sit | L1-L3 | 墙壁 |
| 4 | 直腿抬高 | Straight Leg Raise | L1-L3 | 瑜伽垫 |
| 5 | 侧抬腿 | Side-Lying Leg Raise | L1-L3 | 瑜伽垫 |
| 6 | 桥式 | Glute Bridge | L1-L3 | 瑜伽垫 |
| 7 | 站姿提腿 / 原地踏步 | Standing March | L1-L3 | 扶椅 (L1) → 无 (L3) |
| 8 | 脚跟-脚尖串联走 | Tandem Walk | L1-L3 | 扶墙 (L1) → 无 (L3) |

**3D 资产**:
- 角色: Mixamo 内置 `Kaya` (中性卡通女) 或 `Jake` (中性卡通男) — **不**用老人/小孩形象
- 动作: Mixamo 现成腿部动作库 (90% 可搜到)
- 转换: Mixamo FBX → Blender + CATS 插件 → USDZ
- 集成: iOS 17+ RealityKit (非 ARView, 纯 3D 展示)

**演示规格**:
- 时长: **30-60s 单动作示范** (用户决策: 教程不宜太长, 示范即可)
- UI: 大字体动作名 / 进度条 / 重复次数计数
- 真人回退: 库动画不匹配时, 配真人视频 (可选, 不强求)
- 可行性验证: 启动时先 Mixamo 测试, 不行再换方案 (用户决策: Q3)

**详细方案**: `~/Documents/hermes_files/VetBuddy/调研_3D动画方案.md`

#### F3 — 每日训练计划生成

**输入**: 用户分级 (F1) + HealthKit 当日数据 (F6)

**生成逻辑**:
- L1 用户: 每日 15-20 分钟, 4-5 个动作 (低强度起步, 椅子坐立+提踵+站姿提腿+直腿抬高+桥式)
- L2 用户: 每日 25-30 分钟, 6-7 个动作 (L1 全套 + 侧抬腿 + 串联走扶墙)
- L3 用户: 每日 30-40 分钟, 8 个动作全做 + 进阶变式
- 红旗禁止: 不生成计划, 仅饮食页

**数据存储**: `Core Data` (按日存 plan + completion)

#### F4 — 打卡 + 训练记录

**打卡触发**: 完成计划中所有动作后, 弹"今日完成"卡片 → 用户点"打卡" → 海报可分享 (F7)

**记录字段**:
- 日期 / 完成动作数 / 总时长 / 当日步数 (F6) / 心率 (F6, 如有) / 体重 (F6, 如有)

**激励**: 连续打卡天数 (用户本地可见, 不用作商业化)

#### F5 — 饮食建议 + 风险提示

**输入**: 启动问卷 (Q8 肾病/Q9 糖尿病) + 用户分级

**建议内容** (按 v0.1 调研的中国/ESPEN 指南):
- 蛋白质摄入 (按 CKD 分层):
  - **健康 (无 CKD)**: 1.0-1.2 g/kg/天
  - **肌少症风险**: 1.2-1.5 g/kg/天
  - **CKD 1-2 期 (eGFR ≥ 60)**: 1.0-1.2 g/kg/天 (监测)
  - **CKD 3 期 (eGFR 30-59)**: 0.8-1.0 g/kg/天 (优选植物蛋白)
  - **CKD 4-5 期 (eGFR < 30)**: 0.6-0.8 g/kg/天 (**必须医监**)
- 优质蛋白排序: 鸡蛋 > 鱼/禽 > 瘦肉 > 豆制品 > 乳清蛋白
- 碳水: 减少精制碳水 (白米/白面/糖), 增加全谷物 + 蔬菜
- 运动后 30min 黄金窗口: 蛋白质 + 碳水同步摄入

**风险提示**:
- ⚠️ "本建议不替代医生诊疗"
- ⚠️ "如您有肾病/糖尿病, 请咨询医生后再调整饮食"
- ⚠️ "蛋白粉/补剂不是必须, 日常饮食优先"

**数据源**: 预置 markdown 内容 (本地), 不联网

#### F6 — HealthKit 数据读取 (本期实现)

**读取字段** (按用户决策 + v0.1 调研):
- 步数 (`.stepCount`): 当日累计 — 综合评估当天运动量
- 心率 (`.heartRate`): 当日平均
- 体重 (`.bodyMass`): 最近一次

**技术方案** (按调研报告):
- iOS 17+ `HKHealthStore` + `HKStatisticsQuery`
- 前台读取 (启动时拉一次 + 主动刷新)
- 本地缓存 (UserDefaults + Core Data)
- **iPhone 无法单独测心率** (无内置传感器), 心率依赖 Apple Watch 或第三方设备

**降级**:
- 无 Watch: 心率模块显示"💔 暂未连接心率设备, 可在'我的'手动记录"
- 未授权: 卡片置灰, "未授权, 点击前往开启"
- 手动输入: 步数/心率/体重均可手填兜底

**权限文案** (Info.plist `NSHealthShareUsageDescription`):
> "老铁 VetBuddy 需要读取您的步数、心率和体重, 帮您记录每天的运动情况, 生成健康报告。数据仅保存在您的手机本地, 不会上传或分享给任何人。"

**详细方案**: `~/Documents/hermes_files/VetBuddy/调研_HealthKit读取方案.md`

#### F7 — 运动海报生成 + 微信分享

**触发**: 用户打卡后自动弹"生成海报"卡片 (可选, 不强推)

**海报内容** (iOS 17 SwiftUI 渲染, **用户决策 Q4**):
- 背景: **国风水墨风** (4 款可换: 山水/竹/松/鹤)
- 文字层:
  - 标题: "今日运动报告"
  - 用户名/头像 (可选)
  - **运动时间** (总时长, F4)
  - **动作类型** (如"椅子坐立 12 次 × 3 组", F4)
  - **使用时间** (累计 app 使用天数)
  - **HealthKit 步数 + 心率** (如有, F6)
  - **激励话** (随机从 10 句老人友好池子抽, 如"今天也是元气满满的一天! / 一小步, 一大步! / 你比昨天的自己更棒!")
- 二维码 (可选, v1.1 加, 下载 VetBuddy 链接)

**分享路径**:
- iOS 原生 Share Sheet → 微信好友/朋友圈
- 本地生成 PNG, **不上传任何服务器**

**用途** (用户决策):
- 用户炫耀 (给子女/朋友)
- 推广 (家人看到 → 帮老人装)

#### F8 — 视频动作 AI 纠错 (本期实现)

**范围** (v1 限定):
- ✅ 动作次数自动计数 (基于动作幅度检测)
- ✅ 训练时长自动记录
- ⚠️ 姿态识别 (前置 TrueDepth 摄像头, iPhone X 及以上可选模块, 不强求)

**技术**:
- Apple Vision Framework (本地, 无服务器)
- 摄像头权限: `NSCameraUsageDescription` 文案: "老铁 VetBuddy 使用摄像头识别您的动作, 帮助您更准确地完成训练, 视频数据仅在本地处理, 不上传。"

**降级**:
- 无摄像头/拒绝授权: 弹"无摄像头, 请手动计数" → 改手动打卡
- 老旧机型: 不支持 Vision → 手动模式

### 2.3 商业预留接口 (v1 不实现, 留接口)

```swift
// 订阅接口预留 (App Store IAP)
enum VetBuddySubscription {
    case free           // 当前默认
    case premium_monthly  // v3+
    case premium_yearly   // v3+
}

// 内容包接口预留 (v3+)
struct ContentPack: Codable {
    let id: String
    let title: String
    let isPremium: Bool
    // ...
}
```

---

## 3. 非功能需求

### 3.1 UI/UX 原则 (60+ 友好)

| 维度 | 标准 | 实现 |
|---|---|---|
| 字体 | 最小 18pt, 标题 24pt+ | SwiftUI `.font(.system(size:))` 集中常量 |
| 颜色 | 高对比度 (WCAG AAA, ≥7:1) | 主文字 #1A1A1A, 背景 #FFFFFF/浅米, 强调 #C73E1D, 警示 #D32F2F |
| 颜色 (国风水墨海报) | 水墨色板 | 黛色 #1A1A1A, 宣纸 #F5F0E1, 朱砂 #C73E1D, 远山 #8B9DC3 |
| 按钮 | 最小点击区域 60×60pt | SwiftUI `.frame(minWidth: 60, minHeight: 60)` |
| 动画 | 不超过 1.5s, 缓动 easeOut | 默认时长常量 |
| 引导 | 每页首屏 1 句话说明 | 文案简短直白, 不超过 15 字 |
| 音效 | 可选, 老人可关闭 | `UserDefaults` 持久化 |

### 3.2 性能

| 指标 | 目标 |
|---|---|
| 启动时间 | < 2s (iPhone 12 基准) |
| 动画加载 | < 500ms (本地 USDZ) |
| HealthKit 读取 | < 1s (前台) |
| 海报生成 | < 3s (SwiftUI 渲染) |
| 包体大小 | < 50MB (含 8 个 USDZ ~5MB) |

### 3.3 隐私
- ✅ **全部数据本地存储** (UserDefaults + Core Data)
- ✅ **不上传任何服务器**
- ✅ **不接入第三方分析 SDK**
- ✅ **不接入广告 SDK**
- 符合 GDPR / 中国《个人信息保护法》/ App Review 4.0+ 隐私要求

### 3.4 兼容性

| 项 | 要求 |
|---|---|
| iOS 版本 | iOS 17+ (锁定, 不支持 iOS 16 及以下) |
| 设备 | iPhone 12 及以上推荐 (RealityKit GPU 蒙皮) |
| Apple Watch | 可选, 不强求 (心率数据需 Watch 或第三方) |
| 语言 | 简体中文 (v1), 英文/繁体留 v2 |

---

## 4. 技术架构

### 4.1 项目结构 (SwiftUI + MVVM)

```
VetBuddy/
├── App/                          # App 入口, SceneDelegate
│   ├── VetBuddyApp.swift
│   └── AppRouter.swift
├── Core/                         # 核心服务
│   ├── HealthKit/                # F6 HealthKit 读取
│   │   ├── HealthKitService.swift
│   │   ├── HealthKitModels.swift
│   │   └── HealthKitPermissions.swift
│   ├── Assessment/               # F1 健康问卷 + 分级
│   │   ├── AssessmentService.swift
│   │   ├── AssessmentModels.swift
│   │   └── AssessmentRules.swift  # 红旗筛查 + L1/L2/L3
│   ├── Training/                 # F2/F3/F4 训练核心
│   │   ├── TrainingPlanService.swift
│   │   ├── ExerciseLibrary.swift  # 8 个动作元数据
│   │   └── TrainingRecordStore.swift
│   ├── Nutrition/                # F5 饮食建议
│   │   ├── NutritionAdvisor.swift
│   │   └── NutritionContent.swift  # 预置 markdown
│   ├── Poster/                   # F7 海报
│   │   ├── PosterRenderer.swift
│   │   └── PosterTemplates.swift   # 4 款水墨
│   ├── Vision/                   # F8 视频 AI 纠错
│   │   ├── PoseEstimator.swift
│   │   └── CameraSession.swift
│   └── Persistence/              # Core Data stack
│       ├── CoreDataStack.swift
│       └── VetBuddy.xcdatamodeld
├── Features/                     # UI 页面 (SwiftUI Views)
│   ├── Onboarding/               # 启动问卷
│   ├── Home/                     # 首页 (今日计划入口)
│   ├── Training/                 # 训练中 (3D 动画 + 计数)
│   ├── Nutrition/                # 饮食页
│   ├── Poster/                   # 海报预览/分享
│   ├── History/                  # 历史记录
│   └── Profile/                  # 我的 (设置, 重新评估)
├── Resources/                    # 静态资源
│   ├── Animations/               # 8 个 USDZ
│   ├── Posters/                  # 4 款水墨背景
│   └── Content/                  # 饮食 markdown
└── DesignSystem/                 # 设计系统
    ├── Colors.swift
    ├── Typography.swift
    └── Components/
        ├── BigButton.swift
        ├── StepCard.swift
        └── ProgressRing.swift
```

### 4.2 数据流

```
┌─────────────────────────────────────────────────┐
│                    UI Layer                      │
│  (SwiftUI Views, 响应 @Published / @State)        │
└────────────────────┬────────────────────────────┘
                     │ bind
┌────────────────────▼────────────────────────────┐
│              ViewModel Layer                     │
│  (ObservableObject, 业务逻辑编排)                  │
└──────┬──────────┬──────────┬──────────┬─────────┘
       │          │          │          │
┌──────▼───┐ ┌────▼────┐ ┌───▼────┐ ┌──▼──────┐
│ HealthKit│ │Assessment│ │Training│ │Nutrition│
│ Service  │ │ Service  │ │ Service│ │ Service │
└────┬─────┘ └────┬─────┘ └───┬────┘ └───┬─────┘
     │            │           │          │
     └────────────┴───────────┴──────────┘
                  │
       ┌──────────▼──────────┐
       │  Core Data + UserDefaults │
       │  (本地持久化)               │
       └──────────────────────┘
```

### 4.3 关键技术选型

| 项 | 选型 | 理由 |
|---|---|---|
| UI 框架 | SwiftUI | iOS 17+ 原生, 性能足够 |
| 架构 | MVVM | 简单清晰, 60+ 用户场景不需要复杂架构 |
| 3D 渲染 | RealityKit (非 AR) | GPU 蒙皮, 性能优, 不需摄像头 |
| 数据持久化 | Core Data + UserDefaults | 全部本地, 不上云 |
| HealthKit | HKHealthStore + HKStatisticsQuery | 官方 API, 前台足够 |
| 视觉 AI | Apple Vision Framework | 本地, 隐私友好 |
| 海报渲染 | SwiftUI ImageRenderer (iOS 16+) | 原生, 无需第三方 |
| 分享 | UIActivityViewController | iOS 原生 Share Sheet |

---

## 5. 开发计划

### 5.1 工作量估算

| 模块 | 人天 | 负责人 |
|---|---|---|
| F1 启动问卷 + 分级 (含红旗饮食页) | 2.0 | iOS 开发 |
| F2 3D 动画 (Mixamo 资产 + RealityKit 集成) | 5.0 | 美术 + iOS 开发 |
| F3/F4 训练计划 + 打卡 | 3.0 | iOS 开发 |
| F5 饮食建议 (CKD 分层 5 档) | 1.5 | 内容 + iOS 开发 |
| F6 HealthKit 读取 (步数/心率/体重) | 2.0 | iOS 开发 |
| F7 海报 + 国风水墨 + 微信分享 | 2.0 | iOS 开发 |
| F8 视频 AI 纠错 (v1 限定: 计数+时长) | 3.0 | iOS 开发 |
| 设计系统 (大字体/高对比/老人友好) | 2.0 | 设计 + iOS |
| Core Data 建模 + 持久化 | 1.5 | iOS 开发 |
| App Icon + 启动页 | 0.5 | 设计 |
| 内测 + 老人实测 (5 人) | 3.0 | QA + 产品 |
| App Store 审核准备 | 1.0 | iOS 开发 |
| **合计** | **26.5 人天** | — |

### 5.2 里程碑

| 阶段 | 周 | 交付物 |
|---|---|---|
| M0 资产准备 | W1 | Mixamo 8 动作下载 + Blender 转 USDZ + 海报水墨背景 4 款 |
| M1 核心框架 | W2-W3 | 项目脚手架 + 设计系统 + Core Data 模型 + 启动问卷 |
| M2 训练核心 | W4-W5 | 3D 动画集成 + 训练计划 + 打卡 (F2/F3/F4) |
| M3 数据+分享 | W6-W7 | HealthKit + 海报 + 视频 AI 计数 (F6/F7/F8) |
| M4 完善 | W8 | 饮食建议 + 老人实测 + Bug 修复 (F5 + QA) |
| M5 上架 | W9 | App Store 审核 + 灰度发布 |

### 5.3 风险与缓解

| 风险 | 等级 | 缓解 |
|---|---|---|
| 老人实测发现 UI 仍不好用 | 高 | M4 阶段提前找 5 位 60+ 用户实测, 早发现早改 |
| HealthKit 心率在 iPhone 单独使用无数据 | 中 | v1 文档明确, 海报/评估都降级到"无 Watch 不显示" |
| Mixamo 卡通人"看起来年轻"老人不认同 | 中 | 选 Kaya 中性, 文案说"通用示范者"非真实人; 留 v2 替换为定制卡通 |
| RealityKit 在 iPhone 12 以下卡顿 | 低 | 锁定 iOS 17+ 设备, App Store 上架 iPhone 12+ |
| 60+ 用户 iOS 17 升级率 | 中 | App Store 统计 iPhone 中 70%+ 已升 iOS 17+ (Apple 官方 WWDC 2024 数据) |
| 3D 动作时长 (30-60s) 老人觉得"太短/太长" | 中 | M4 实测调, 必要时拆 15s × 2 组 |
| Mixamo 商业授权 / 服务变更 | 低 | FBX 是本地资产一次性下载; 备选 Blender 自建 |

---

## 6. 上架与运营

### 6.1 App Store 文案要点
- **名称**: 老铁 - 60+ 腿部训练
- **副标题**: 给爸妈的腿部力量守护, 8 个动作 + 饮食建议
- **关键词**: 老人健身, 中老年运动, 腿部训练, 父母健康, 居家锻炼, 肌少症
- **宣传图**: 大字体, 老人实测截图, 国风水墨海报样例
- **分类**: 健康健美 > 健身
- **年龄分级**: 4+ (无任何内容限制)
- **隐私政策**: 本地存储声明, 不收集任何数据

### 6.2 隐私政策 URL
需托管一个静态页面 (GitHub Pages / Cloudflare Pages 免费), 声明:
- 全部数据本地存储
- 不收集任何使用分析
- 不接入广告/分析 SDK
- HealthKit 数据仅本地使用

### 6.3 推广策略 (零成本)
- 小红书: 老人实测视频 + 国风水墨海报样例 (子女视角)
- 知乎: "60+ 中老年用什么 App 锻炼" 内容
- 微信群: 让目标用户子女传播 (海报分享路径)

---

## 7. v2/v3 规划 (本期不实现)

| 版本 | 计划功能 | 优先级 |
|---|---|---|
| v2 | 鸿蒙 HarmonyOS 适配 | P0 |
| v2 | 家人账号 (iOS Family Sharing 或本地导二维码) | P1 |
| v2 | 后台 HealthKit 同步 (HKObserverQuery) | P1 |
| v2 | 全身训练 (除腿部外, 上肢/核心) | P1 |
| v2 | 医生/营养师审核 (云端审核系统) | P2 |
| v3 | 内容订阅 (高级训练包) | P3 |
| v3 | 社区 (同龄人打卡圈) | P3 |

> **v1.1 调整说明**: 原 v1.1 计划含"家人账号 / 医生审核", 根据用户 v0.2 决策 (本期不做), 上表已调整到 v2。

---

## 8. 附录

### 8.1 关键文件位置

| 类型 | 位置 |
|---|---|
| 项目主源 | `~/Documents/myObsidian/myObsidian/1_Projects/iOS/VetBuddy/` |
| 调研产物 | `~/Documents/hermes_files/VetBuddy/` |
| 3D 动画方案 | `~/Documents/hermes_files/VetBuddy/调研_3D动画方案.md` |
| HealthKit 方案 | `~/Documents/hermes_files/VetBuddy/调研_HealthKit读取方案.md` |
| 医学底稿 | `~/Documents/hermes_files/VetBuddy/VetBuddy_老铁_开发需求文档_v0.1_科学依据.md` |
| v1.0 本文档 | `~/Documents/hermes_files/VetBuddy/VetBuddy_需求文档_v1.0.md` |

### 8.2 参考资料
- WHO 2020 Guidelines on Physical Activity and Sedentary Behaviour
- ACSM's Guidelines for Exercise Testing and Prescription (11th ed., 2021)
- EWGSOP2 (European Working Group on Sarcopenia in Older People 2, 2019)
- 中国居民膳食指南 (2022) — 60+ 中老年膳食指导
- Apple Human Interface Guidelines — Accessibility
- Apple HealthKit Documentation
- Apple RealityKit Documentation
- Mixamo 官网 https://www.mixamo.com
- Deutz et al. (2014) ESPEN 老年蛋白质指南
- KDIGO 2024 CKD 营养管理指南

### 8.3 决策记录 (v0.1 → v0.2 → v1.0)

| 决策 | 来源 | 时间 |
|---|---|---|
| 60+ 起步用户 + 启动问卷 | Q1 | v0.1 → v0.2 |
| 红旗禁止用户可看饮食页 (不能动也能用) | Q1-1 | v0.2 → v1.0 |
| MVP 8 项 (必选 5 + HealthKit + 海报分享 + 视频 AI) | Q2 | v0.1 → v0.2 |
| 3D 动画, Mixamo 中性卡通人 (Kaya/Jake), 30-60s 示范 | Q3 + 调研 | v0.2 → v1.0 |
| 国风水墨海报背景 (4 款) | Q4 | v0.2 → v1.0 |
| 本地 + HealthKit + 海报分享微信 (炫耀 + 推广) | Q4 | v0.1 → v0.2 |
| 暂时免费, 商业后置 | Q5 | v0.1 → v0.2 |
| 命名: 老铁 / VetBuddy (删"IronBuddy 老年版"说法) | 用户 | v0.2 → v1.0 |
| 落款: ShaneStudio | 用户 | v1.0 |
| HealthKit 读取步数/心率/体重, 综合评估当天运动量 | 用户 | v0.2 → v1.0 |
| iOS 17+ 锁定 | 用户 | v0.2 → v1.0 |
| 教程不宜太长, 示范动作即可 | 用户 | v0.2 → v1.0 |
| Mixamo 可行性先测试, 不行再换 | 用户 | v0.2 → v1.0 |

---

## 9. 文档元信息

- **文档版本**: v1.0
- **建立日期**: 2026-06-09
- **作者**: ShaneStudio
- **锁定日期**: 2026-06-09
- **下一步**: 启动 M0 资产准备 (Mixamo 8 动作下载 + Blender USDZ 转换 + 海报水墨背景 4 款)

---

*本文档由 ShaneStudio 主导, 经多轮脑暴收敛. 所有医学/技术建议基于公开指南 (WHO/ACSM/EWGSOP2) + Apple 官方文档 + 行业实践, 最终实施前请医生/营养师/法务审阅.*
