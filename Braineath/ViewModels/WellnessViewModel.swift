//
//  WellnessViewModel.swift
//  Braineath
//
//  Created by Ryan Zemri on 15/09/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class WellnessViewModel: ObservableObject {
    @Published var dailyWellnessEntries: [DailyWellness] = []
    @Published var todaysEntry: DailyWellness?
    @Published var weeklySummary: WeeklyWellnessSummary?
    @Published var insights: [WellnessInsight] = []
    @Published var isLoading = false
    
    private let userDefaults = UserDefaults.standard
    private let storageKey = "DailyWellnessEntries"
    
    init() {
        loadWellnessData()
        setupTodaysEntry()
        generateWeeklySummary()
    }
    
    // MARK: - Data Loading
    func loadWellnessData() {
        isLoading = true
        
        if let data = userDefaults.data(forKey: storageKey),
           let entries = try? JSONDecoder().decode([DailyWellness].self, from: data) {
            dailyWellnessEntries = entries.sorted { $0.date > $1.date }
        }
        
        isLoading = false
    }
    
    private func saveWellnessData() {
        if let data = try? JSONEncoder().encode(dailyWellnessEntries) {
            userDefaults.set(data, forKey: storageKey)
        }
    }
    
    // MARK: - Today's Entry Management
    private func setupTodaysEntry() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let existingEntry = dailyWellnessEntries.first(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: today) 
        }) {
            todaysEntry = existingEntry
        } else {
            todaysEntry = DailyWellness(date: today)
        }
    }
    
    func updateTodaysWellness(_ wellness: DailyWellness) {
        todaysEntry = wellness
        
        // Update or add to the array
        if let index = dailyWellnessEntries.firstIndex(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: wellness.date) 
        }) {
            dailyWellnessEntries[index] = wellness
        } else {
            dailyWellnessEntries.insert(wellness, at: 0)
        }
        
        saveWellnessData()
        generateWeeklySummary()
        
        // Haptic feedback
        AudioManager.shared.playHapticFeedback(style: .medium)
    }
    
    // MARK: - Quick Updates
    func updateMood(_ mood: Int) {
        guard var today = todaysEntry else { return }
        today.overallMood = mood
        updateTodaysWellness(today)
    }
    
    func updateEnergyLevel(_ energy: Int) {
        guard var today = todaysEntry else { return }
        today.energyLevel = energy
        updateTodaysWellness(today)
    }
    
    func updateStressLevel(_ stress: Int) {
        guard var today = todaysEntry else { return }
        today.stressLevel = stress
        updateTodaysWellness(today)
    }
    
    func updateSleepQuality(_ sleep: Int) {
        guard var today = todaysEntry else { return }
        today.sleepQuality = sleep
        updateTodaysWellness(today)
    }
    
    func addMindfulnessMinutes(_ minutes: Int) {
        guard var today = todaysEntry else { return }
        today.mindfulnessMinutes += minutes
        updateTodaysWellness(today)
    }
    
    func incrementBreathingSessions() {
        guard var today = todaysEntry else { return }
        today.breathingSessionsCompleted += 1
        updateTodaysWellness(today)
    }
    
    func incrementGratitudeEntries() {
        guard var today = todaysEntry else { return }
        today.gratitudeEntriesCount += 1
        updateTodaysWellness(today)
    }
    
    func incrementThoughtRecords() {
        guard var today = todaysEntry else { return }
        today.thoughtRecordsCount += 1
        updateTodaysWellness(today)
    }
    
    // MARK: - Weekly Summary
    private func generateWeeklySummary() {
        let calendar = Calendar.current
        let today = Date()
        
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return }
        
        let weekEntries = dailyWellnessEntries.filter { entry in
            let daysSinceWeekStart = calendar.dateComponents([.day], from: weekStart, to: entry.date).day ?? 0
            return daysSinceWeekStart >= 0 && daysSinceWeekStart < 7
        }
        
        weeklySummary = WeeklyWellnessSummary(weekStartDate: weekStart, dailyEntries: weekEntries)
        insights = weeklySummary?.insights ?? []
    }
    
    // MARK: - Analytics
    func getWellnessScore(for date: Date) -> Int {
        return dailyWellnessEntries.first { 
            Calendar.current.isDate($0.date, inSameDayAs: date) 
        }?.wellnessScore ?? 0
    }
    
    var mindfulnessMinutesThisWeek: Int {
        let calendar = Calendar.current
        let today = Date()
        
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return 0 }
        
        let weekEntries = dailyWellnessEntries.filter { entry in
            let daysSinceWeekStart = calendar.dateComponents([.day], from: weekStart, to: entry.date).day ?? 0
            return daysSinceWeekStart >= 0 && daysSinceWeekStart < 7
        }
        
        return weekEntries.reduce(0) { $0 + $1.mindfulnessMinutes }
    }
    
    func getAverageWellnessScore(days: Int = 7) -> Double {
        let recentEntries = Array(dailyWellnessEntries.prefix(days))
        guard !recentEntries.isEmpty else { return 0 }
        
        let total = recentEntries.map(\.wellnessScore).reduce(0, +)
        return Double(total) / Double(recentEntries.count)
    }
    
    func getMoodTrend(days: Int = 7) -> Double {
        let recentEntries = Array(dailyWellnessEntries.prefix(days))
        guard recentEntries.count > 1 else { return 0 }
        
        let firstHalf = recentEntries.suffix(recentEntries.count / 2)
        let secondHalf = recentEntries.prefix(recentEntries.count / 2)
        
        let firstAvg = Double(firstHalf.map(\.overallMood).reduce(0, +)) / Double(firstHalf.count)
        let secondAvg = Double(secondHalf.map(\.overallMood).reduce(0, +)) / Double(secondHalf.count)
        
        return secondAvg - firstAvg
    }
    
    // MARK: - Smart Suggestions
    func getSmartSuggestions() -> [String] {
        guard let today = todaysEntry else { return [] }
        
        var suggestions: [String] = []
        
        if today.overallMood < 5 {
            suggestions.append("Essayez une session de respiration pour améliorer votre humeur")
        }
        
        if today.energyLevel < 4 {
            suggestions.append("Une courte promenade pourrait augmenter votre énergie")
        }
        
        if today.stressLevel < 4 {
            suggestions.append("Prenez 5 minutes pour noter vos pensées et les restructurer")
        }
        
        if today.mindfulnessMinutes < 10 {
            suggestions.append("10 minutes de pleine conscience peuvent transformer votre journée")
        }
        
        if today.gratitudeEntriesCount == 0 {
            suggestions.append("Notez 3 choses pour lesquelles vous êtes reconnaissant")
        }
        
        return suggestions
    }
}