import Foundation

/// ViewModel for the training history screen.
final class HistoryViewModel: ObservableObject {

    @Published var checkins: [DailyCheckin] = []
    @Published var streak: Int = 0
    @Published var totalDays: Int = 0

    private let recordStore: TrainingRecordStore

    init(recordStore: TrainingRecordStore = .shared) {
        self.recordStore = recordStore
    }

    func loadHistory() async {
        let allCheckins = await recordStore.allCheckins()
        let currentStreak = await recordStore.consecutiveStreak()
        let days = await recordStore.totalTrainingDays()

        await MainActor.run {
            self.checkins = allCheckins
            self.streak = currentStreak
            self.totalDays = days
        }
    }

    func checkinDates(lastDays: Int = 30) -> Set<Date> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -lastDays, to: today) else {
            return []
        }

        return Set(
            checkins
                .filter { $0.date >= startDate }
                .map { calendar.startOfDay(for: $0.date) }
        )
    }
}
