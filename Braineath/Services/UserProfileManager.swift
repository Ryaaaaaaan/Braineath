//
//  UserProfileManager.swift
//  Braineath
//
//  Created by Ryan Zemri on 12/09/2025.
//

import Foundation
import Combine

@MainActor
class UserProfileManager: ObservableObject {
    static let shared = UserProfileManager()
    
    @Published var currentProfile: UserProfile?
    @Published var isOnboardingComplete: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let profileKey = "user_profile"
    private let onboardingKey = "onboarding_complete"
    
    private init() {
        loadProfile()
        isOnboardingComplete = userDefaults.bool(forKey: onboardingKey)
    }
    
    func saveProfile(_ profile: UserProfile) {
        currentProfile = profile
        isOnboardingComplete = true
        
        do {
            let data = try JSONEncoder().encode(profile)
            userDefaults.set(data, forKey: profileKey)
            userDefaults.set(true, forKey: onboardingKey)
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
    
    private func loadProfile() {
        guard let data = userDefaults.data(forKey: profileKey) else { return }
        
        do {
            currentProfile = try JSONDecoder().decode(UserProfile.self, from: data)
        } catch {
            print("Failed to load profile: \(error)")
        }
    }
    
    func updateProfile(_ profile: UserProfile) {
        saveProfile(profile)
    }
    
    func clearProfile() {
        currentProfile = nil
        isOnboardingComplete = false
        userDefaults.removeObject(forKey: profileKey)
        userDefaults.removeObject(forKey: onboardingKey)
    }
    
    // Suggestions personnalisées basées sur le profil
    func getPersonalizedGreeting() -> String {
        guard let profile = currentProfile else { return "Bonjour" }
        
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting = switch hour {
        case 5..<12: "Bonjour"
        case 12..<17: "Bon après-midi" 
        case 17..<21: "Bonsoir"
        default: "Bonne nuit"
        }
        
        return "\(timeGreeting), \(profile.name)"
    }
    
    func getPersonalizedQuotes() -> [String] {
        guard let profile = currentProfile else {
            return [
                "Respirez profondément, tout va bien se passer.",
                "Chaque moment est une nouvelle opportunité.",
                "Votre paix intérieure est votre superpouvoir."
            ]
        }
        
        var quotes: [String] = []
        
        if profile.primaryGoals.contains(.reduceStress) {
            quotes.append("Le stress est comme un nuage, il finit toujours par passer.")
            quotes.append("Respirez profondément, \(profile.name), vous êtes plus fort que vos soucis.")
        }
        
        if profile.primaryGoals.contains(.improveAnxiety) {
            quotes.append("L'anxiété est un visiteur, pas un résident permanent.")
            quotes.append("Chaque respiration consciente vous ramène au moment présent.")
        }
        
        if profile.primaryGoals.contains(.betterSleep) {
            quotes.append("Un esprit calme trouve facilement le repos.")
            quotes.append("Laissez vos pensées s'apaiser comme les vagues sur la plage.")
        }
        
        if profile.primaryGoals.contains(.mindfulness) {
            quotes.append("La pleine conscience est le cadeau que vous vous offrez.")
            quotes.append("Être présent, c'est être vivant.")
        }
        
        // Ajouter des quotes générales si pas assez spécifiques
        if quotes.count < 5 {
            quotes.append(contentsOf: [
                "Votre bien-être mental mérite toute votre attention, \(profile.name).",
                "Chaque petit pas compte sur votre chemin de guérison.",
                "Vous avez en vous tout ce qu'il faut pour vous épanouir."
            ])
        }
        
        return quotes.shuffled()
    }
    
    func getRecommendedExercise() -> String {
        guard let profile = currentProfile else {
            return "Essayez 5 minutes de respiration profonde"
        }
        
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch profile.experienceLevel {
        case .beginner:
            if hour < 12 {
                return "Commencez par 3 minutes de respiration 4-7-8"
            } else {
                return "Essayez 5 minutes de respiration consciente"
            }
        case .intermediate:
            if profile.stressLevel > 7 {
                return "Session de cohérence cardiaque - 10 minutes"
            } else {
                return "Respiration carrée - 8 minutes"
            }
        case .advanced:
            return "Session personnalisée - 15 minutes avec visualisation"
        }
    }
}