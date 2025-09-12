//
//  ThoughtRecordViewModel.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import Foundation
import SwiftUI
import Combine
import CoreData

class ThoughtRecordViewModel: ObservableObject {
    @Published var thoughtRecords: [ThoughtRecord] = []
    @Published var isLoading = false
    
    // Statistiques
    @Published var recordsThisWeek: Int = 0
    @Published var identifiedDistortions: Int = 0
    
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadRecentRecords()
        calculateStats()
    }
    
    func loadRecentRecords() {
        isLoading = true
        thoughtRecords = dataManager.fetchThoughtRecords(limit: 20)
        isLoading = false
    }
    
    func calculateStats() {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        recordsThisWeek = thoughtRecords.filter { record in
            guard let date = record.date else { return false }
            return date >= weekAgo
        }.count
        
        let allDistortions = thoughtRecords.compactMap { $0.cognitiveDistortions }.flatMap { $0 }
        identifiedDistortions = Set(allDistortions).count
    }
    
    func createThoughtRecord(
        situation: String,
        automaticThought: String,
        emotionBefore: String,
        intensityBefore: Int
    ) -> ThoughtRecord {
        let record = dataManager.createThoughtRecord(
            situation: situation,
            automaticThought: automaticThought,
            emotionBefore: emotionBefore,
            intensityBefore: intensityBefore
        )
        
        loadRecentRecords()
        calculateStats()
        
        return record
    }
    
    func updateThoughtRecord(
        _ record: ThoughtRecord,
        cognitiveDistortions: [String]? = nil,
        balancedThought: String? = nil,
        emotionAfter: String? = nil,
        intensityAfter: Int? = nil,
        actionPlan: String? = nil
    ) {
        if let distortions = cognitiveDistortions {
            record.cognitiveDistortions = distortions
        }
        
        if let balanced = balancedThought {
            record.balancedThought = balanced
        }
        
        if let emotion = emotionAfter {
            record.emotionAfter = emotion
        }
        
        if let intensity = intensityAfter {
            record.intensityAfter = Int16(intensity)
        }
        
        if let action = actionPlan {
            record.actionPlan = action
        }
        
        dataManager.save()
        loadRecentRecords()
        calculateStats()
    }
    
    // Suggestions de pensées équilibrées basées sur les distorsions identifiées
    func getSuggestedBalancedThought(
        for automaticThought: String,
        distortions: [CognitiveDistortion]
    ) -> String {
        var suggestions: [String] = []
        
        for distortion in distortions {
            switch distortion {
            case .allOrNothing:
                suggestions.append("Quelles nuances puis-je voir dans cette situation ?")
                
            case .overgeneralization:
                suggestions.append("Est-ce que cette situation représente vraiment un pattern général ?")
                
            case .mentalFilter:
                suggestions.append("Quels aspects positifs ou neutres puis-je également considérer ?")
                
            case .discountingPositive:
                suggestions.append("Comment puis-je reconnaître et valoriser les aspects positifs ?")
                
            case .jumpingToConclusions:
                suggestions.append("Quelles autres explications sont possibles ? Ai-je toutes les informations ?")
                
            case .magnification:
                suggestions.append("Dans 5 ans, quelle importance aura réellement cette situation ?")
                
            case .emotionalReasoning:
                suggestions.append("Mes émotions sont valides, mais reflètent-elles nécessairement la réalité ?")
                
            case .shouldStatements:
                suggestions.append("Que se passerait-il si je remplaçais 'je dois' par 'j'aimerais' ?")
                
            case .labeling:
                suggestions.append("Comment puis-je décrire mes actions sans me définir entièrement par elles ?")
                
            case .personalization:
                suggestions.append("Quels autres facteurs ont pu contribuer à cette situation ?")
                
            case .catastrophizing:
                suggestions.append("Quel est le scénario le plus réaliste plutôt que le pire ?")
                
            case .mindReading:
                suggestions.append("Ai-je vraiment des preuves de ce que l'autre personne pense ?")
            }
        }
        
        return suggestions.randomElement() ?? "Comment puis-je voir cette situation de manière plus équilibrée ?"
    }
    
    // Questions guidées pour la restructuration
    func getGuidedQuestions(for distortions: [CognitiveDistortion]) -> [String] {
        var questions: [String] = []
        
        questions.append("Quelles preuves soutiennent cette pensée ?")
        questions.append("Quelles preuves contredisent cette pensée ?")
        questions.append("Que dirais-je à un(e) ami(e) dans cette situation ?")
        questions.append("Quelle serait une pensée plus réaliste et équilibrée ?")
        
        if distortions.contains(.catastrophizing) {
            questions.append("Quel est le scénario le plus probable ?")
        }
        
        if distortions.contains(.mindReading) {
            questions.append("Comment puis-je vérifier ce que les autres pensent vraiment ?")
        }
        
        return questions
    }
    
    // Analyse des patterns dans les pensées automatiques
    func getThoughtPatterns() -> [String: Int] {
        let allThoughts = thoughtRecords.compactMap { $0.automaticThought?.lowercased() }
        
        var patterns: [String: Int] = [:]
        let commonPatterns = [
            "je ne suis pas": 0,
            "je ne peux pas": 0,
            "c'est terrible": 0,
            "tout le monde": 0,
            "jamais": 0,
            "toujours": 0,
            "personne": 0
        ]
        
        patterns = commonPatterns
        
        for thought in allThoughts {
            for (pattern, _) in commonPatterns {
                if thought.contains(pattern) {
                    patterns[pattern, default: 0] += 1
                }
            }
        }
        
        return patterns.filter { $0.value > 0 }
    }
    
    // Recommandations personnalisées
    func getPersonalizedRecommendations() -> [String] {
        var recommendations: [String] = []
        
        let recentRecords = Array(thoughtRecords.prefix(5))
        let commonDistortions = recentRecords
            .compactMap { $0.cognitiveDistortions }
            .flatMap { $0 }
            .reduce(into: [String: Int]()) { counts, distortion in
                counts[distortion, default: 0] += 1
            }
        
        if let mostCommon = commonDistortions.max(by: { $0.value < $1.value })?.key {
            if let distortion = CognitiveDistortion.allCases.first(where: { $0.rawValue == mostCommon }) {
                switch distortion {
                case .allOrNothing:
                    recommendations.append("Pratiquez la recherche de nuances dans vos évaluations")
                case .overgeneralization:
                    recommendations.append("Questionnez vos généralisations avec des contre-exemples")
                case .mentalFilter:
                    recommendations.append("Défiez-vous de noter 3 aspects positifs chaque jour")
                default:
                    recommendations.append("Continuez à identifier vos patterns de pensée")
                }
            }
        }
        
        if recordsThisWeek < 2 {
            recommendations.append("Essayez de faire au moins 2-3 enregistrements par semaine")
        }
        
        recommendations.append("Relisez vos anciens enregistrements pour voir vos progrès")
        
        return recommendations
    }
}

// Extension pour DataManager avec les opérations ThoughtRecord
extension DataManager {
    func fetchThoughtRecords(limit: Int = 50) -> [ThoughtRecord] {
        let request: NSFetchRequest<ThoughtRecord> = ThoughtRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ThoughtRecord.date, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch thought records: \(error)")
            return []
        }
    }
}