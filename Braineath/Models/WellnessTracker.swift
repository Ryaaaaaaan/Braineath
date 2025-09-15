//
//  WellnessTracker.swift
//  Braineath
//
//  Created by Ryan Zemri on 15/09/2025.
//

import Foundation
import SwiftUI

// MARK: - Daily Wellness Model
struct DailyWellness: Identifiable, Codable {
    var id = UUID()
    let date: Date
    var overallMood: Int = 5 // 1-10 scale
    var energyLevel: Int = 5 // 1-10 scale
    var stressLevel: Int = 5 // 1-10 scale (reversed - 1 is high stress, 10 is low stress)
    var sleepQuality: Int = 5 // 1-10 scale
    var mindfulnessMinutes: Int = 0
    var breathingSessionsCompleted: Int = 0
    var gratitudeEntriesCount: Int = 0
    var thoughtRecordsCount: Int = 0
    var notes: String = ""
    
    // Calculated wellness score (0-100)
    var wellnessScore: Int {
        let components = [overallMood, energyLevel, stressLevel, sleepQuality]
        let average = components.reduce(0, +) / components.count
        let bonusPoints = min(20, mindfulnessMinutes / 5) // Up to 20 bonus points for mindfulness
        return min(100, (average * 8) + bonusPoints) // Scale to 0-100
    }
    
    var wellnessLevel: WellnessLevel {
        switch wellnessScore {
        case 0..<30: return .struggling
        case 30..<50: return .challenging
        case 50..<70: return .stable
        case 70..<85: return .good
        default: return .excellent
        }
    }
}

enum WellnessLevel: String, CaseIterable {
    case struggling = "En difficulté"
    case challenging = "Difficile"
    case stable = "Stable"
    case good = "Bien"
    case excellent = "Excellent"
    
    var color: Color {
        switch self {
        case .struggling: return .red
        case .challenging: return .orange
        case .stable: return .yellow
        case .good: return .green
        case .excellent: return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .struggling: return "exclamationmark.triangle.fill"
        case .challenging: return "minus.circle.fill"
        case .stable: return "equal.circle.fill"
        case .good: return "checkmark.circle.fill"
        case .excellent: return "star.circle.fill"
        }
    }
    
    var message: String {
        switch self {
        case .struggling:
            return "Prenez soin de vous aujourd'hui. Essayez une session de respiration ou parlez à quelqu'un."
        case .challenging:
            return "Les jours difficiles font partie de la vie. Soyez gentil avec vous-même."
        case .stable:
            return "Vous maintenez un bon équilibre. Continuez vos bonnes habitudes."
        case .good:
            return "Excellente journée ! Votre bien-être est sur la bonne voie."
        case .excellent:
            return "Extraordinaire ! Vous rayonnez de bien-être aujourd'hui."
        }
    }
}

// MARK: - Wellness Insights
struct WellnessInsight {
    let title: String
    let description: String
    let actionable: String
    let category: InsightCategory
    
    enum InsightCategory {
        case mood, energy, stress, sleep, mindfulness
        
        var color: Color {
            switch self {
            case .mood: return .pink
            case .energy: return .orange
            case .stress: return .red
            case .sleep: return .purple
            case .mindfulness: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .mood: return "heart.fill"
            case .energy: return "bolt.fill"
            case .stress: return "exclamationmark.triangle.fill"
            case .sleep: return "bed.double.fill"
            case .mindfulness: return "brain.head.profile.fill"
            }
        }
    }
}

// MARK: - Weekly Wellness Summary
struct WeeklyWellnessSummary {
    let weekStartDate: Date
    let dailyEntries: [DailyWellness]
    
    var averageWellnessScore: Double {
        guard !dailyEntries.isEmpty else { return 0 }
        return Double(dailyEntries.map(\.wellnessScore).reduce(0, +)) / Double(dailyEntries.count)
    }
    
    var totalMindfulnessMinutes: Int {
        dailyEntries.map(\.mindfulnessMinutes).reduce(0, +)
    }
    
    var totalBreathingSessions: Int {
        dailyEntries.map(\.breathingSessionsCompleted).reduce(0, +)
    }
    
    var insights: [WellnessInsight] {
        generateInsights()
    }
    
    private func generateInsights() -> [WellnessInsight] {
        var insights: [WellnessInsight] = []
        
        // Mood trend analysis
        let moodTrend = analyzeTrend(values: dailyEntries.map(\.overallMood))
        if moodTrend.isDecreasing {
            insights.append(WellnessInsight(
                title: "Humeur en baisse",
                description: "Votre humeur moyenne a diminué cette semaine.",
                actionable: "Essayez d'ajouter plus d'activités qui vous rendent heureux.",
                category: .mood
            ))
        }
        
        // Stress analysis
        let avgStress = Double(dailyEntries.map(\.stressLevel).reduce(0, +)) / Double(dailyEntries.count)
        if avgStress < 4 {
            insights.append(WellnessInsight(
                title: "Niveau de stress élevé",
                description: "Votre niveau de stress a été élevé cette semaine.",
                actionable: "Augmentez vos sessions de respiration et prenez des pauses régulières.",
                category: .stress
            ))
        }
        
        // Sleep analysis
        let avgSleep = Double(dailyEntries.map(\.sleepQuality).reduce(0, +)) / Double(dailyEntries.count)
        if avgSleep < 6 {
            insights.append(WellnessInsight(
                title: "Qualité de sommeil faible",
                description: "Votre sommeil pourrait être amélioré.",
                actionable: "Créez une routine du soir apaisante et évitez les écrans avant le coucher.",
                category: .sleep
            ))
        }
        
        // Mindfulness encouragement
        if totalMindfulnessMinutes < 70 { // Less than 10 minutes per day
            insights.append(WellnessInsight(
                title: "Plus de pleine conscience",
                description: "Vous pourriez bénéficier de plus de temps en pleine conscience.",
                actionable: "Essayez de pratiquer 10 minutes de méditation ou respiration par jour.",
                category: .mindfulness
            ))
        }
        
        return insights
    }
    
    private func analyzeTrend(values: [Int]) -> (isIncreasing: Bool, isDecreasing: Bool) {
        guard values.count > 1 else { return (false, false) }
        
        let firstHalf = values.prefix(values.count / 2)
        let secondHalf = values.suffix(values.count / 2)
        
        let firstAvg = Double(firstHalf.reduce(0, +)) / Double(firstHalf.count)
        let secondAvg = Double(secondHalf.reduce(0, +)) / Double(secondHalf.count)
        
        let threshold = 0.5
        return (
            isIncreasing: secondAvg - firstAvg > threshold,
            isDecreasing: firstAvg - secondAvg > threshold
        )
    }
}