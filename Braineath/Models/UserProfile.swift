//
//  UserProfile.swift
//  Braineath
//
//  Created by Ryan Zemri on 12/09/2025.
//

import Foundation

struct UserProfile: Codable {
    let name: String
    let age: Int?
    let primaryGoals: [WellnessGoal]
    let stressLevel: Int // 1-10
    let experienceLevel: ExperienceLevel
    let preferredTimes: [PreferredTime]
    let triggers: [String]
    let createdAt: Date
    
    init(name: String, age: Int? = nil, primaryGoals: [WellnessGoal] = [], stressLevel: Int = 5, experienceLevel: ExperienceLevel = .beginner, preferredTimes: [PreferredTime] = [], triggers: [String] = []) {
        self.name = name
        self.age = age
        self.primaryGoals = primaryGoals
        self.stressLevel = stressLevel
        self.experienceLevel = experienceLevel
        self.preferredTimes = preferredTimes
        self.triggers = triggers
        self.createdAt = Date()
    }
}

enum WellnessGoal: String, CaseIterable, Codable {
    case reduceStress = "Réduire le stress"
    case improveAnxiety = "Gérer l'anxiété"
    case betterSleep = "Améliorer le sommeil"
    case emotional = "Régulation émotionnelle"
    case focus = "Améliorer la concentration"
    case selfCare = "Prendre soin de soi"
    case mindfulness = "Développer la pleine conscience"
    case depression = "Soutien pour la dépression"
    
    var icon: String {
        switch self {
        case .reduceStress: return "leaf.fill"
        case .improveAnxiety: return "heart.fill"
        case .betterSleep: return "moon.fill"
        case .emotional: return "brain.head.profile"
        case .focus: return "target"
        case .selfCare: return "hands.sparkles.fill"
        case .mindfulness: return "circle.dotted"
        case .depression: return "sun.max.fill"
        }
    }
    
    var color: String {
        switch self {
        case .reduceStress: return "green"
        case .improveAnxiety: return "blue"
        case .betterSleep: return "purple"
        case .emotional: return "orange"
        case .focus: return "red"
        case .selfCare: return "pink"
        case .mindfulness: return "indigo"
        case .depression: return "yellow"
        }
    }
}

enum ExperienceLevel: String, CaseIterable, Codable {
    case beginner = "Débutant"
    case intermediate = "Intermédiaire"
    case advanced = "Avancé"
    
    var description: String {
        switch self {
        case .beginner: return "Je découvre les techniques de bien-être mental"
        case .intermediate: return "J'ai déjà essayé quelques techniques"
        case .advanced: return "Je pratique régulièrement la méditation/respiration"
        }
    }
}

enum PreferredTime: String, CaseIterable, Codable {
    case morning = "Matin"
    case afternoon = "Après-midi"
    case evening = "Soir"
    case night = "Nuit"
    
    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.stars.fill"
        }
    }
}