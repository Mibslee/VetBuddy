import SwiftUI

/// Training history with calendar grid, streak display, and recent records.
struct HistoryView: View {

    @StateObject private var viewModel = HistoryViewModel()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols = ["日", "一", "二", "三", "四", "五", "六"]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                streakCard
                totalDaysCard
                calendarSection
                recentRecordsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color.vbCream.ignoresSafeArea())
        .task { await viewModel.loadHistory() }
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("连续打卡")
                    .vbHeadline()
                Text("\(viewModel.streak) 天")
                    .font(VBFont.hero)
                    .foregroundStyle(Color.vbAccent)
            }
            Spacer()
            Image(systemName: "flame.fill")
                .font(.system(size: 48))
                .foregroundStyle(viewModel.streak > 0 ? Color.vbAccent : Color.vbSecondaryText.opacity(0.3))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Total Days Card

    private var totalDaysCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("累计训练天数")
                    .vbHeadline()
                Text("\(viewModel.totalDays) 天")
                    .font(VBFont.hero)
                    .foregroundStyle(Color.vbSuccess)
            }
            Spacer()
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 48))
                .foregroundStyle(viewModel.totalDays > 0 ? Color.vbSuccess : Color.vbSecondaryText.opacity(0.3))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Calendar Section

    private var calendarSection: some View {
        VStack(spacing: 16) {
            Text("最近 30 天")
                .vbHeadline()

            weekdayHeader

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(calendarDays, id: \.self) { day in
                    calendarDayCell(day)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .vbCaption()
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarDays: [Date?] {
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -29, to: today) else {
            return []
        }

        var days: [Date?] = []

        // Add leading empty cells for weekday alignment
        let weekday = calendar.component(.weekday, from: startDate)
        let leadingEmpty = (weekday - calendar.firstWeekday + 7) % 7
        for _ in 0..<leadingEmpty {
            days.append(nil)
        }

        // Add 30 days
        for offset in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: offset, to: startDate) {
                days.append(date)
            }
        }

        return days
    }

    @ViewBuilder
    private func calendarDayCell(_ date: Date?) -> some View {
        if let date {
            let isCheckedIn = viewModel.checkins.contains {
                calendar.isDate($0.date, inSameDayAs: date)
            }
            let isToday = calendar.isDateInToday(date)

            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(VBFont.body)
                    .foregroundStyle(
                        isToday ? .white : Color.vbMainText
                    )
                    .frame(width: 36, height: 36)
                    .background(
                        isToday ? Color.vbAccent : Color.clear
                    )
                    .clipShape(Circle())

                Circle()
                    .fill(isCheckedIn ? Color.vbSuccess : Color.clear)
                    .frame(width: 8, height: 8)
            }
            .frame(minHeight: 52)
        } else {
            Color.clear
                .frame(height: 52)
        }
    }

    // MARK: - Recent Records

    private var recentRecordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("训练记录")
                .vbHeadline()

            if viewModel.checkins.isEmpty {
                Text("暂无训练记录，开始您的第一次训练吧！")
                    .vbBody()
                    .foregroundStyle(Color.vbSecondaryText)
                    .padding(.vertical, 8)
            } else {
                ForEach(viewModel.checkins.prefix(10)) { checkin in
                    recordRow(checkin)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func recordRow(_ checkin: DailyCheckin) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.vbSuccess)
                .font(.system(size: 24))

            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(checkin.date))
                    .vbBody()
                Text("\(checkin.completedExerciseCount)/\(checkin.totalExerciseCount) 个动作")
                    .vbCaption()
            }

            Spacer()

            Text("\(checkin.totalDurationSeconds / 60) 分钟")
                .font(VBFont.headline)
                .foregroundStyle(Color.vbAccent)
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("History") {
    HistoryView()
}
