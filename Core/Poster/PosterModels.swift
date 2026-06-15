import SwiftUI

// MARK: - Poster Template

enum PosterTemplate: String, CaseIterable, Identifiable {
    case mountain, bamboo, pine, crane

    var id: String { rawValue }

    var name: String {
        switch self {
        case .mountain: return "山水"
        case .bamboo: return "竹"
        case .pine: return "松"
        case .crane: return "鹤"
        }
    }

    var primaryColor: Color {
        switch self {
        case .mountain: return Color(red: 0.10, green: 0.10, blue: 0.10)   // 黛色 #1A1A1A
        case .bamboo:  return Color(red: 0.10, green: 0.10, blue: 0.10)
        case .pine:    return Color(red: 0.10, green: 0.10, blue: 0.10)
        case .crane:   return Color(red: 0.10, green: 0.10, blue: 0.10)
        }
    }

    var secondaryColor: Color {
        switch self {
        case .mountain: return Color(red: 0.96, green: 0.94, blue: 0.88)  // 宣纸 #F5F0E1
        case .bamboo:  return Color(red: 0.96, green: 0.94, blue: 0.88)
        case .pine:    return Color(red: 0.96, green: 0.94, blue: 0.88)
        case .crane:   return Color(red: 0.96, green: 0.94, blue: 0.88)
        }
    }

    var accentColor: Color {
        switch self {
        case .mountain: return Color(red: 0.55, green: 0.62, blue: 0.76)  // 远山 #8B9DC3
        case .bamboo:  return Color(red: 0.45, green: 0.56, blue: 0.35)   // 竹绿
        case .pine:    return Color(red: 0.25, green: 0.38, blue: 0.28)   // 松绿
        case .crane:   return Color(red: 0.78, green: 0.24, blue: 0.11)   // 朱砂 #C73E1D
        }
    }

    var backgroundImageName: String {
        switch self {
        case .mountain: return "poster_mountain"
        case .bamboo: return "poster_bamboo"
        case .pine: return "poster_pine"
        case .crane: return "poster_crane"
        }
    }
}

// MARK: - Poster Data

struct PosterData: Equatable {
    let date: Date
    let totalDuration: String
    let exerciseNames: [String]
    let steps: Int?
    let heartRate: Double?
    let quote: String
    let totalDays: Int
    let completedExercises: Int?
    let totalExercises: Int?

    init(
        date: Date,
        totalDuration: String,
        exerciseNames: [String],
        steps: Int?,
        heartRate: Double?,
        quote: String,
        totalDays: Int,
        completedExercises: Int? = nil,
        totalExercises: Int? = nil
    ) {
        self.date = date
        self.totalDuration = totalDuration
        self.exerciseNames = exerciseNames
        self.steps = steps
        self.heartRate = heartRate
        self.quote = quote
        self.totalDays = totalDays
        self.completedExercises = completedExercises
        self.totalExercises = totalExercises
    }
}
