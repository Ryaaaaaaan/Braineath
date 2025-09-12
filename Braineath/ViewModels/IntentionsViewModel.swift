//
//  IntentionsViewModel.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import Foundation
import SwiftUI
import Combine
import CoreData

class IntentionsViewModel: ObservableObject {
    @Published var newIntentionText: String = ""
    @Published var selectedCategory: String = ""
    @Published var recentIntentions: [DailyIntention] = []
    @Published var todaysIntention: DailyIntention?
    @Published var freeWritingText: String = ""
    @Published var isLoading = false
    
    let intentionCategories = [
        "Bien-être", "Relations", "Productivité", "Créativité", 
        "Apprentissage", "Santé", "Spiritualité", "Gratitude", "Autre"
    ]
    
    let reflectionPrompts = [
        "Qu'ai-je appris sur moi-même aujourd'hui ?",
        "Quel moment m'a apporté le plus de joie récemment ?",
        "Comment puis-je être plus bienveillant(e) envers moi-même ?",
        "Quelle habitude aimerais-je développer ?",
        "Qu'est-ce qui me donne de l'énergie en ce moment ?",
        "Comment puis-je contribuer positivement à mon entourage ?",
        "Quelle peur aimerais-je dépasser ?",
        "De quoi suis-je le plus fier/fière récemment ?",
        "Comment puis-je mieux équilibrer ma vie ?",
        "Quelle valeur souhaite-je incarner davantage ?"
    ]
    
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadRecentIntentions()
        loadTodaysIntention()
    }
    
    func loadRecentIntentions() {
        isLoading = true
        recentIntentions = dataManager.fetchDailyIntentions(limit: 14)
        isLoading = false
    }
    
    func loadTodaysIntention() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        todaysIntention = recentIntentions.first { intention in
            guard let date = intention.date else { return false }
            return calendar.isDate(date, inSameDayAs: today)
        }
    }
    
    func createIntention() {
        guard !newIntentionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let category = selectedCategory.isEmpty ? nil : selectedCategory
        _ = dataManager.createDailyIntention(
            text: newIntentionText.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category
        )
        
        // Réinitialiser le formulaire
        newIntentionText = ""
        selectedCategory = ""
        
        // Recharger les données
        loadRecentIntentions()
        loadTodaysIntention()
        
        // Feedback positif
        AudioManager.shared.playNotificationHaptic(type: .success)
    }
    
    func toggleIntentionCompletion(_ intention: DailyIntention) {
        intention.isCompleted.toggle()
        
        // Ajouter une réflexion si l'intention est marquée comme complétée
        if intention.isCompleted && (intention.reflection?.isEmpty ?? true) {
            intention.reflection = "Intention accomplie le \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))"
        }
        
        dataManager.save()
        
        // Recharger pour mettre à jour l'interface
        loadRecentIntentions()
        loadTodaysIntention()
        
        // Feedback haptique
        AudioManager.shared.playHapticFeedback()
    }
    
    func addReflectionToIntention(_ intention: DailyIntention, reflection: String) {
        intention.reflection = reflection.isEmpty ? nil : reflection
        dataManager.save()
        loadRecentIntentions()
        loadTodaysIntention()
    }
    
    // Obtenir les statistiques d'intentions
    func getIntentionStats() -> (total: Int, completed: Int, thisWeek: Int) {
        let total = recentIntentions.count
        let completed = recentIntentions.filter { $0.isCompleted }.count
        
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let thisWeek = recentIntentions.filter { intention in
            guard let date = intention.date else { return false }
            return date >= weekAgo
        }.count
        
        return (total: total, completed: completed, thisWeek: thisWeek)
    }
    
    // Obtenir des insights sur les intentions
    func getIntentionInsights() -> [String] {
        let stats = getIntentionStats()
        var insights: [String] = []
        
        if stats.total == 0 {
            insights.append("Définissez votre première intention pour commencer votre pratique consciente.")
            return insights
        }
        
        let completionRate = stats.total > 0 ? Double(stats.completed) / Double(stats.total) : 0
        
        if completionRate >= 0.8 {
            insights.append("Excellent ! Vous accomplissez \(Int(completionRate * 100))% de vos intentions.")
        } else if completionRate >= 0.6 {
            insights.append("Bon rythme ! \(Int(completionRate * 100))% de vos intentions sont accomplies.")
        } else if completionRate > 0 {
            insights.append("Continuez vos efforts ! Chaque intention compte dans votre croissance.")
        }
        
        if stats.thisWeek >= 5 {
            insights.append("Semaine très intentionnelle avec \(stats.thisWeek) intentions définies !")
        } else if stats.thisWeek == 0 {
            insights.append("Prenez un moment cette semaine pour définir une intention quotidienne.")
        }
        
        // Analyser les catégories favorites
        let categories = recentIntentions.compactMap { $0.category }
        if !categories.isEmpty {
            let categoryCount = Dictionary(grouping: categories, by: { $0 }).mapValues { $0.count }
            if let favoriteCategory = categoryCount.max(by: { $0.value < $1.value })?.key {
                insights.append("Vos intentions se concentrent souvent sur : \(favoriteCategory)")
            }
        }
        
        return insights
    }
    
    // Suggérer des intentions basées sur l'historique
    func getSuggestedIntentions() -> [String] {
        var suggestions = [
            "Pratiquer la pleine conscience pendant 10 minutes",
            "Exprimer ma gratitude à quelqu'un d'important",
            "Faire une pause dans la nature",
            "Écouter activement lors de mes conversations",
            "Prendre soin de mon corps avec bienveillance",
            "Apprendre quelque chose de nouveau aujourd'hui",
            "Être présent(e) dans mes activités",
            "Cultiver la patience dans les moments difficiles",
            "Créer un moment de beauté dans ma journée",
            "Pratiquer l'auto-compassion"
        ]
        
        // Personnaliser selon les catégories fréquentes
        let categories = recentIntentions.compactMap { $0.category }
        let categoryCount = Dictionary(grouping: categories, by: { $0 }).mapValues { $0.count }
        
        if let topCategory = categoryCount.max(by: { $0.value < $1.value })?.key {
            switch topCategory {
            case "Relations":
                suggestions.insert("Renforcer une relation importante aujourd'hui", at: 0)
            case "Santé":
                suggestions.insert("Honorer les besoins de mon corps", at: 0)
            case "Créativité":
                suggestions.insert("Exprimer ma créativité d'une nouvelle façon", at: 0)
            default:
                break
            }
        }
        
        return Array(suggestions.prefix(5))
    }
    
    // Générer un prompt de réflexion personnalisé
    func getPersonalizedReflectionPrompt() -> String {
        let recent = recentIntentions.prefix(3)
        
        if recent.contains(where: { !$0.isCompleted }) {
            return "Qu'est-ce qui m'aide ou me freine dans l'accomplissement de mes intentions ?"
        }
        
        if recent.allSatisfy({ $0.isCompleted }) {
            return "Comment mes récentes intentions accomplies ont-elles impacté ma vie ?"
        }
        
        return reflectionPrompts.randomElement() ?? "Qu'ai-je appris sur moi-même aujourd'hui ?"
    }
}

// Extension pour DataManager avec les opérations DailyIntention
extension DataManager {
    func fetchDailyIntentions(limit: Int = 30) -> [DailyIntention] {
        let request: NSFetchRequest<DailyIntention> = DailyIntention.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyIntention.date, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch daily intentions: \(error)")
            return []
        }
    }
}