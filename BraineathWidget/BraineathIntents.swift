//
//  BraineathIntents.swift
//  BraineathWidget
//
//  Created by Ryan Zemri on 12/09/2025.
//

import AppIntents
import WidgetKit

@available(iOS 16.0, *)
struct QuickBreathingIntent: AppIntent {
    static var title: LocalizedStringResource = "Respiration rapide"
    static var description = IntentDescription("Lance une session de respiration de 2 minutes")
    
    func perform() async throws -> some IntentResult {
        // Ouvrir l'application sur la vue de respiration
        return .result()
    }
}

@available(iOS 16.0, *)
struct QuickMoodIntent: AppIntent {
    static var title: LocalizedStringResource = "Ajouter humeur"
    static var description = IntentDescription("Enregistre rapidement votre humeur actuelle")
    
    func perform() async throws -> some IntentResult {
        // Ouvrir l'application sur la vue d'ajout d'humeur
        return .result()
    }
}

@available(iOS 16.0, *)
struct EmergencySOSIntent: AppIntent {
    static var title: LocalizedStringResource = "SOS Urgence"
    static var description = IntentDescription("Accède rapidement aux ressources d'urgence")
    
    func perform() async throws -> some IntentResult {
        // Ouvrir l'application sur la vue d'urgence
        return .result()
    }
}