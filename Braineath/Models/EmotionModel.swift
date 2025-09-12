//
//  EmotionModel.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import Foundation
import SwiftUI

struct Emotion: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let category: EmotionCategory
    let color: String
    let intensity: Int
    let icon: String
    let description: String
    
    static let allEmotions: [Emotion] = [
        // Émotions positives
        Emotion(name: "Joyeux", category: .positive, color: "#FFD700", intensity: 8, icon: "face.smiling", description: "Sentiment de bonheur et de contentement"),
        Emotion(name: "Serein", category: .positive, color: "#87CEEB", intensity: 6, icon: "leaf", description: "État de paix intérieure et de tranquillité"),
        Emotion(name: "Énergique", category: .positive, color: "#FF6347", intensity: 9, icon: "bolt", description: "Plein de vitalité et de dynamisme"),
        Emotion(name: "Confiant", category: .positive, color: "#32CD32", intensity: 7, icon: "star", description: "Sentiment de sécurité et d'assurance"),
        Emotion(name: "Reconnaissant", category: .positive, color: "#DDA0DD", intensity: 6, icon: "heart", description: "Sentiment de gratitude et d'appréciation"),
        
        // Émotions négatives
        Emotion(name: "Anxieux", category: .negative, color: "#FF4500", intensity: 7, icon: "exclamationmark.triangle", description: "Inquiétude et nervosité"),
        Emotion(name: "Triste", category: .negative, color: "#4169E1", intensity: 6, icon: "cloud.rain", description: "Sentiment de mélancolie et de chagrin"),
        Emotion(name: "Stressé", category: .negative, color: "#DC143C", intensity: 8, icon: "timer", description: "Tension et pression ressentie"),
        Emotion(name: "Frustré", category: .negative, color: "#FF69B4", intensity: 7, icon: "xmark.circle", description: "Irritation face aux obstacles"),
        Emotion(name: "Épuisé", category: .negative, color: "#696969", intensity: 5, icon: "battery.0", description: "Fatigue physique et mentale"),
        
        // Émotions neutres
        Emotion(name: "Calme", category: .neutral, color: "#20B2AA", intensity: 4, icon: "moon", description: "État de tranquillité paisible"),
        Emotion(name: "Pensif", category: .neutral, color: "#9370DB", intensity: 5, icon: "brain.head.profile", description: "État de réflexion profonde"),
        Emotion(name: "Indifférent", category: .neutral, color: "#708090", intensity: 3, icon: "minus.circle", description: "Absence d'émotion particulière"),
        Emotion(name: "Curieux", category: .neutral, color: "#FF8C00", intensity: 6, icon: "questionmark.circle", description: "Désir d'apprendre et de découvrir"),
        Emotion(name: "Concentré", category: .neutral, color: "#4682B4", intensity: 7, icon: "target", description: "État de focus et d'attention")
    ]
}

enum EmotionCategory: String, CaseIterable, Codable {
    case positive = "Positive"
    case negative = "Négative"
    case neutral = "Neutre"
    
    var color: Color {
        switch self {
        case .positive:
            return .green
        case .negative:
            return .red
        case .neutral:
            return .gray
        }
    }
}

enum BreathingPattern: String, CaseIterable, Codable {
    case basic478 = "4-7-8"
    case boxBreathing = "Respiration Carrée"
    case coherentBreathing = "Cohérence Cardiaque"
    case deepBreathing = "Respiration Profonde"
    case quickCalm = "Calme Rapide"
    
    var description: String {
        switch self {
        case .basic478:
            return "Inspirez 4s, retenez 7s, expirez 8s"
        case .boxBreathing:
            return "Inspirez 4s, retenez 4s, expirez 4s, pause 4s"
        case .coherentBreathing:
            return "Respirez à un rythme régulier de 5s"
        case .deepBreathing:
            return "Respirations lentes et profondes"
        case .quickCalm:
            return "Technique rapide de 2 minutes"
        }
    }
    
    var inhaleTime: Double {
        switch self {
        case .basic478: return 4.0
        case .boxBreathing: return 4.0
        case .coherentBreathing: return 5.0
        case .deepBreathing: return 6.0
        case .quickCalm: return 3.0
        }
    }
    
    var holdTime: Double {
        switch self {
        case .basic478: return 7.0
        case .boxBreathing: return 4.0
        case .coherentBreathing: return 0.0
        case .deepBreathing: return 2.0
        case .quickCalm: return 1.0
        }
    }
    
    var exhaleTime: Double {
        switch self {
        case .basic478: return 8.0
        case .boxBreathing: return 4.0
        case .coherentBreathing: return 5.0
        case .deepBreathing: return 8.0
        case .quickCalm: return 4.0
        }
    }
    
    var pauseTime: Double {
        switch self {
        case .boxBreathing: return 4.0
        default: return 0.0
        }
    }
}

enum CognitiveDistortion: String, CaseIterable, Codable {
    case allOrNothing = "Tout ou rien"
    case overgeneralization = "Généralisation excessive"
    case mentalFilter = "Filtre mental"
    case discountingPositive = "Minimiser le positif"
    case jumpingToConclusions = "Conclusions hâtives"
    case magnification = "Amplification"
    case emotionalReasoning = "Raisonnement émotionnel"
    case shouldStatements = "Tyrannies des 'il faut'"
    case labeling = "Étiquetage"
    case personalization = "Personnalisation"
    case catastrophizing = "Catastrophisme"
    case mindReading = "Lecture de pensée"
    
    var description: String {
        switch self {
        case .allOrNothing:
            return "Voir les choses en noir ou blanc, sans nuances"
        case .overgeneralization:
            return "Tirer des conclusions générales d'un seul événement"
        case .mentalFilter:
            return "Se concentrer uniquement sur les aspects négatifs"
        case .discountingPositive:
            return "Ignorer ou minimiser les expériences positives"
        case .jumpingToConclusions:
            return "Interpréter les situations sans preuves suffisantes"
        case .magnification:
            return "Exagérer l'importance des problèmes"
        case .emotionalReasoning:
            return "Croire que nos émotions reflètent la réalité"
        case .shouldStatements:
            return "Utiliser des 'je dois' et 'il faut' rigides"
        case .labeling:
            return "S'attacher des étiquettes négatives"
        case .personalization:
            return "Se blâmer pour des événements hors de contrôle"
        case .catastrophizing:
            return "Imaginer le pire scénario possible"
        case .mindReading:
            return "Supposer connaître les pensées des autres"
        }
    }
}