# iOS 17+ HealthKit 读取方案 — 老铁 VetBuddy

> 调研日期: 2026-06-09
> 场景: 60+ 老人, 读步数/心率/体重, 评估当天运动量, iOS 17+ 单机 SwiftUI

---

## 1. 标准代码路径 (HKHealthStore + HKStatisticsQuery)

| 数据 | Type Identifier | Query | Statistic | 备注 |
|---|---|---|---|---|
| 步数 | `.stepCount` | `HKStatisticsQuery` | `.cumulativeSum` | 当天累计 |
| 心率 | `.heartRate` | `HKStatisticsQuery` | `.discreteAverage` | 取平均 BPM |
| 体重 | `.bodyMass` | `HKSampleQuery` + `sortDescriptor` | 取最新 1 条 | 不聚合 |

**Swift 关键代码** (5 行核心路径):
```swift
let store = HKHealthStore()
let step  = HKQuantityType(.stepCount)
let pred  = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
let q     = HKStatisticsQuery(quantityType: step, quantitySamplePredicate: pred,
                               options: .cumulativeSum) { _, r, _ in
    let steps = r?.sumQuantity()?.doubleValue(for: .count()) ?? 0
}
store.execute(q)
```
心率/体重同理，改 `options` 与 type。心率用 `HKStatisticsQuery` + `.discreteAverage`；体重用 `HKSampleQuery` + `endDate DESC, limit 1` 取最近。

## 2. 后台 vs 前台 (60+ 场景对比)

| 模式 | 触发 | 对 60+ 用户 |
|---|---|---|
| **前台** (`execute` 直接查) | App 内触发, 实时返回 | ✅ 老人多主动打开 App 看步数, 够用 |
| **后台** (`HKObserverQuery` + `enableBackgroundDelivery`) | 系统唤醒, 延迟 ≤ 数十分钟 | ⚠️ iOS 对后台唤醒严格, 首次需 `UIApplication.shared.registerForRemoteNotifications()`；老人不依赖推送, 价值低 |

**结论: 本项目只做前台 + 启动时拉一次, 后台方案列为 v2。**

## 3. Info.plist 权限文案 (中文, 老人友好)

`Info.plist` 加 `NSHealthShareUsageDescription` (iOS 17 也支持 `NSHealthUpdateUsageDescription` 写权限, 本版本先不写):

> **"老铁 VetBuddy 需要读取您的步数、心率和体重, 帮您记录每天的运动情况, 生成健康报告。数据仅保存在您的手机本地, 不会上传或分享给任何人。"**

要点：① 说清"读什么" ② 说清"干嘛用" ③ 明确"不外传"打消老人顾虑。

## 4. 聚合 Query Pattern (今日 00:00 → now)

```swift
let startOfDay = Calendar.current.startOfDay(for: Date())
let pred = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
```
- 步数：`HKStatisticsQuery` + `.cumulativeSum` → 当日总步数
- 心率：`HKStatisticsQuery` + `.discreteAverage` → 当日平均心率 (单位 `.count().unitDivided(by: .minute())`)
- 体重：`HKSampleQuery` + `NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)` + `limit = 1` → 最近一次体重

## 5. ⚠️ iPhone "实时"心率 — 明确说明

**iPhone 自带传感器无法获取实时心率**。心率数据来源仅：
1. 配对的 **Apple Watch** (主动/被动同步)
2. 第三方蓝牙心率带 (写入 HealthKit)
3. 手动输入

**PRD 必须明确写**: "心率监测需配合 Apple Watch 或支持 HealthKit 的心率设备；iPhone 单独使用时不显示实时心率。"

## 6. 数据缺失 / 未授权降级策略

| 场景 | 降级 UI |
|---|---|
| 未授权 (`authorizationStatus == .notDetermined`) | 弹权限引导弹窗 + 跳"设置"按钮 |
| 已拒绝 (`.sharingDenied`) | 卡片置灰, 文案"未授权, 点击前往开启" |
| 无 Apple Watch (心率为空) | 心率模块显示"💔 暂未连接心率设备, 可在'我的'手动记录" |
| 当日无步数 | "今日暂无数据, 起来走两步吧~" |
| 全无数据 | 引导**手动输入**兜底 (体重/心率/步数都能手填) |

**降级原则**: 永远不阻塞主流程, 任何空数据都给一句鼓励文案而非报错。

## 7. 缓存策略 (本地 daily summary)

| 字段 | 存储 | 更新时机 |
|---|---|---|
| `todaySteps`, `avgHeartRate`, `latestWeight` | `UserDefaults` (小) / `Core Data` (历史趋势) | ① App 启动 ② 跨天 (`lastSyncDate` < 今天 0 点) ③ 手动刷新按钮 |
| 7/30 天趋势 | `Core Data` (按日聚合) | 每日首次同步时写一条 |
| 最近一次原始采样时间 | `UserDefaults` | 同步时更新 |

**策略**: HealthKit 可高频 query，但**每日首次启动 + 主动刷新 = 2 次**足够，缓存优先读取，失败再回源。

---

## 实施步骤 (5 步)

1. **Xcode**: Signing & Capabilities → 添加 HealthKit；`Info.plist` 填 `NSHealthShareUsageDescription` (上述中文文案)
2. **启动时** 调 `HKHealthStore.requestAuthorization(toShare: [], read: readTypes)` 仅请求读权限 (步数/心率/体重)
3. **封装 `HealthKitService`**: 单例, 暴露 `fetchTodaySummary() async -> DailySummary`, 内部按上述 3 个 query 聚合
4. **缓存层**: `DailySummaryCache` 写 `UserDefaults` + `Core Data`, 带 `lastSyncDate` 跨天失效
5. **UI 层**: 数据加载前显示骨架屏, 缺失走降级文案, 空心率不报错而是引导连 Watch / 手输

## 风险

| 风险 | 缓解 |
|---|---|
| 老人看不懂系统权限弹窗 → 误拒 | 自家 UI 先解释, 再触发系统弹窗；提供"去设置"快捷入口 |
| 心率无设备 → 用户投诉"功能不可用" | 首次引导明确"需 Apple Watch", 并在功能入口标"需硬件" |
| HealthKit query 异步失败 (罕见) | try/catch + 重试 1 次, 失败展示"同步失败, 下拉重试" |
| 后台模式被苹果审核质疑 | v1 不做后台, 避免 `UIBackgroundModes` 审核风险 |
| iOS 17 HealthKit 隐私新规 | 文案按"最小必要"写, 声明本地存储, 符合 App Review 4.0+ |

---

## 一句话结论 (可直接抄 PRD)

> **老铁 VetBuddy v1 通过 iOS 17+ HealthKit (HKHealthStore + HKStatisticsQuery) 在前台同步步数/心率/体重, 本地缓存为 daily summary, 心率依赖 Apple Watch 或第三方设备, 所有数据缺失场景均有引导降级 (手动输入 + 鼓励文案), 权限文案中文友好、声明本地存储不外传, 严守"最小必要"原则以通过 App Review。**
