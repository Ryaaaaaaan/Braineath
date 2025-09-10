//
//  MoodViewModel.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import Foundation
import SwiftUI
import Combine
import CoreData

class MoodViewModel: ObservableObject {
    @Published var selectedEmotion: Emotion?
    @Published var emotionIntensity: Int = 5
    @Published var energyLevel: Int = 5
    @Published var stressLevel: Int = 5
    @Published var notes: String = ""
    @Published var triggers: [String] = []
    @Published var weatherImpact: String = ""
    @Published var sleepQuality: Int?
    
    @Published var recentMoodEntries: [MoodEntry] = []
    @Published var moodTrends: [(Date, Double)] = []
    @Published var isLoading = false
    @Published var showingMoodDetail = false
    
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Émotions suggérées basées sur les patterns
    @Published var suggestedEmotions: [Emotion] = []
    
    init() {
        loadRecentMoods()
        loadMoodTrends()
        generateSuggestedEmotions()
    }
    
    func loadRecentMoods() {
        isLoading = true
        recentMoodEntries = dataManager.fetchMoodEntries(limit: 14) // 2 semaines
        isLoading = false
    }
    
    func loadMoodTrends() {
        moodTrends = dataManager.getMoodTrends(days: 30)
    }
    
    func saveMoodEntry() {
        guard let emotion = selectedEmotion else { return }
        
        let triggersArray = triggers.isEmpty ? nil : triggers
        let notesText = notes.isEmpty ? nil : notes
        let weather = weatherImpact.isEmpty ? nil : weatherImpact
        
        let entry = dataManager.createMoodEntry(
            emotion: emotion.name,
            intensity: emotionIntensity,
            notes: notesText,
            triggers: triggersArray,
            energyLevel: energyLevel,
            stressLevel: stressLevel
        )
        
        if let sleepQuality = sleepQuality {
            entry.sleepQuality = Int16(sleepQuality)
        }
        
        entry.weatherImpact = weather
        
        // Sauvegarder et recharger
        dataManager.save()
        loadRecentMoods()
        loadMoodTrends()
        
        // Réinitialiser le formulaire
        resetForm()
        
        // Notification haptique
        AudioManager.shared.playNotificationHaptic(type: .success)
    }
    
    private func resetForm() {
        selectedEmotion = nil
        emotionIntensity = 5
        energyLevel = 5
        stressLevel = 5
        notes = ""
        triggers = []
        weatherImpact = ""
        sleepQuality = nil
    }
    
    func addTrigger(_ trigger: String) {
        if !trigger.isEmpty && !triggers.contains(trigger) {
            triggers.append(trigger)
        }
    }
    
    func removeTrigger(_ trigger: String) {
        triggers.removeAll { $0 == trigger }
    }
    
    private func generateSuggestedEmotions() {
        // Analyse intelligente des patterns pour suggérer des émotions
        let recentEmotions = recentMoodEntries.prefix(7).compactMap { entry in
            Emotion.allEmotions.first { $0.name == entry.primaryEmotion }
        }
        
        if recentEmotions.isEmpty {
            // Premières suggestions pour nouveaux utilisateurs
            suggestedEmotions = [
                Emotion.allEmotions.first { $0.name == "Calme" }!,
                Emotion.allEmotions.first { $0.name == "Joyeux" }!,
                Emotion.allEmotions.first { $0.name == "Pensif" }!,
                Emotion.allEmotions.first { $0.name == "Énergique" }!
            ]
        } else {
            // Suggestions basées sur les patterns
            let categories = Set(recentEmotions.map { $0.category })
            var suggestions: [Emotion] = []
            
            // Suggérer des émotions d'équilibre
            if categories.contains(.negative) && !categories.contains(.positive) {
                suggestions.append(contentsOf: Emotion.allEmotions.filter { $0.category == .positive }.prefix(2))
            }
            
            if categories.contains(.positive) && !categories.contains(.negative) {
                suggestions.append(contentsOf: Emotion.allEmotions.filter { $0.category == .neutral }.prefix(2))
            }
            
            // Ajouter des émotions similaires mais nuancées
            let recentNames = Set(recentEmotions.map { $0.name })
            suggestions.append(contentsOf: Emotion.allEmotions.filter { !recentNames.contains($0.name) }.prefix(4 - suggestions.count))
            
            suggestedEmotions = suggestions
        }
    }
    
    // Analyse des patterns émotionnels
    func getEmotionalInsights() -> [String] {
        var insights: [String] = []
        
        let recentWeek = recentMoodEntries.prefix(7)
        let averageIntensity = Double(recentWeek.reduce(0) { $0 + Int($1.emotionIntensity) }) / Double(recentWeek.count)
        
        if averageIntensity > 7 {
            insights.append("Vos émotions ont été particulièrement intenses cette semaine.")
        } else if averageIntensity < 4 {
            insights.append("Vos émotions semblent plus neutres ces derniers temps.")
        }
        
        let averageStress = Double(recentWeek.reduce(0) { $0 + Int($1.stressLevel) }) / Double(recentWeek.count)
        if averageStress > 7 {
            insights.append("Votre niveau de stress semble élevé. Pensez aux exercices de respiration.")
        }
        
        let averageEnergy = Double(recentWeek.reduce(0) { $0 + Int($1.energyLevel) }) / Double(recentWeek.count)
        if averageEnergy < 4 {
            insights.append("Votre énergie est basse. Assurez-vous de bien dormir et de prendre soin de vous.")
        }
        
        // Analyse des patterns de triggers
        let allTriggers = recentWeek.flatMap { $0.triggers ?? [] }
        let triggerCounts = Dictionary(grouping: allTriggers, by: { $0 }).mapValues { $0.count }
        if let commonTrigger = triggerCounts.max(by: { $0.value < $1.value })?.key, triggerCounts[commonTrigger]! > 2 {
            insights.append("Le déclencheur '\(commonTrigger)' revient souvent. Explorez des stratégies d'adaptation.")
        }
        
        return insights.isEmpty ? ["Continuez à suivre vos émotions pour obtenir des insights personnalisés."] : insights
    }
    
    // Fonction pour obtenir la couleur d'une émotion
    func colorForEmotion(_ emotionName: String) -> Color {
        guard let emotion = Emotion.allEmotions.first(where: { $0.name == emotionName }),
              let uiColor = UIColor(hex: emotion.color) else {
            return .gray
        }
        return Color(uiColor)
    }
}

// Extension pour UIColor hex
extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }
        
        return nil
    }
}