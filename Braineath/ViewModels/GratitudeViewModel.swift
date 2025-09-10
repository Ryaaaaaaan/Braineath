//
//  GratitudeViewModel.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import Foundation
import SwiftUI
import Combine

class GratitudeViewModel: ObservableObject {
    @Published var newGratitudeText: String = ""
    @Published var selectedCategory: String = ""
    @Published var recentEntries: [GratitudeEntry] = []
    @Published var isLoading = false
    
    // Statistiques
    @Published var totalEntries: Int = 0
    @Published var entriesThisWeek: Int = 0
    @Published var currentStreak: Int = 0
    
    let categories = [
        "Famille", "Amis", "Santé", "Travail", "Nature", 
        "Moments", "Apprentissage", "Réalisations", "Petits plaisirs", "Autre"
    ]
    
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadRecentEntries()
        calculateStats()
    }
    
    func loadRecentEntries() {
        isLoading = true
        recentEntries = dataManager.fetchGratitudeEntries(limit: 20)
        isLoading = false
    }
    
    func addGratitudeEntry() {
        guard !newGratitudeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let category = selectedCategory.isEmpty ? nil : selectedCategory
        _ = dataManager.createGratitudeEntry(text: newGratitudeText.trimmingCharacters(in: .whitespacesAndNewlines), category: category)
        
        // Réinitialiser le formulaire
        newGratitudeText = ""
        selectedCategory = ""
        
        // Recharger les données
        loadRecentEntries()
        calculateStats()
        
        // Feedback positif
        AudioManager.shared.playNotificationHaptic(type: .success)
    }
    
    private func calculateStats() {
        totalEntries = recentEntries.count
        
        // Calculer les entrées de cette semaine
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        entriesThisWeek = recentEntries.filter { entry in
            guard let date = entry.date else { return false }
            return date >= weekAgo
        }.count
        
        // Calculer le streak actuel
        currentStreak = calculateCurrentStreak()
    }
    
    private func calculateCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var currentDate = today
        var streak = 0
        
        // Grouper les entrées par jour
        let entriesByDay = Dictionary(grouping: recentEntries) { entry in
            guard let date = entry.date else { return Date.distantPast }
            return calendar.startOfDay(for: date)
        }
        
        // Compter les jours consécutifs avec au moins une entrée
        while let entries = entriesByDay[currentDate], !entries.isEmpty {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            
            // Limiter à 100 jours pour éviter les boucles infinies
            if streak > 100 { break }
        }
        
        return streak
    }
    
    // Obtenir les insights de gratitude
    func getGratitudeInsights() -> [String] {
        var insights: [String] = []
        
        if totalEntries == 0 {
            insights.append("Commencez votre voyage de gratitude aujourd'hui !")
            return insights
        }
        
        if currentStreak >= 7 {
            insights.append("Félicitations ! Vous maintenez votre pratique de gratitude depuis \(currentStreak) jours.")
        } else if currentStreak >= 3 {
            insights.append("Belle constance ! Continuez votre série de \(currentStreak) jours.")
        }
        
        if entriesThisWeek >= 5 {
            insights.append("Excellente semaine de gratitude avec \(entriesThisWeek) entrées !")
        } else if entriesThisWeek == 0 {
            insights.append("Prenez quelques minutes cette semaine pour noter vos gratitudes.")
        }
        
        // Analyser les catégories les plus fréquentes
        let categories = recentEntries.compactMap { $0.category }
        let categoryCount = Dictionary(grouping: categories, by: { $0 }).mapValues { $0.count }
        
        if let topCategory = categoryCount.max(by: { $0.value < $1.value })?.key {
            insights.append("Vous appréciez particulièrement les moments liés à : \(topCategory)")
        }
        
        return insights.isEmpty ? ["Continuez à cultiver la gratitude dans votre quotidien."] : insights
    }
    
    // Obtenir une suggestion de gratitude
    func getGratitudeSuggestion() -> String {
        let suggestions = [
            "Pensez à quelqu'un qui vous a souri aujourd'hui",
            "Quel moment de beauté avez-vous remarqué récemment ?",
            "Quelle compétence ou qualité personnelle vous aide au quotidien ?",
            "Quel objet du quotidien facilite votre vie ?",
            "Quelle expérience récente vous a apporté de la joie ?",
            "De quelle partie de votre corps êtes-vous reconnaissant(e) ?",
            "Quel aspect de votre environnement appréciez-vous ?",
            "Quelle tradition ou habitude vous fait du bien ?",
            "Quel apprentissage récent vous a enrichi(e) ?",
            "Quelle qualité admirez-vous chez un proche ?"
        ]
        
        return suggestions.randomElement() ?? "Pour quoi êtes-vous reconnaissant(e) aujourd'hui ?"
    }
    
    // Exporter les gratitudes (pour sauvegarde personnelle)
    func exportGratitudes() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        var exportText = "Mes Gratitudes - Braineath\n"
        exportText += "Exporté le : \(dateFormatter.string(from: Date()))\n\n"
        
        for entry in recentEntries.reversed() {
            if let date = entry.date, let text = entry.gratitudeText {
                exportText += "📅 \(dateFormatter.string(from: date))\n"
                if let category = entry.category {
                    exportText += "🏷️ \(category)\n"
                }
                exportText += "💝 \(text)\n\n"
            }
        }
        
        return exportText
    }
}