//
//  EmergencyViewModel.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import Foundation
import SwiftUI
import Combine

class EmergencyViewModel: ObservableObject {
    @Published var distressLevel: Int = 7
    @Published var selectedTechnique: EmergencyTechnique?
    @Published var currentSession: EmergencySession?
    
    // Animation de respiration
    @Published var breathingScale: CGFloat = 1.0
    @Published var breathingInstruction: String = "Inspirez"
    
    // Technique de grounding
    @Published var groundingStep: Int = 0
    
    // Pleine conscience
    @Published var mindfulnessGuidance: String = "Fermez les yeux et concentrez-vous sur votre respiration..."
    @Published var mindfulnessTimer: TimeInterval = 0
    
    // Instructions de mouvement
    let movementInstructions = [
        "Secouez doucement vos mains pendant 10 secondes",
        "Roulez vos épaules vers l'arrière 5 fois",
        "Étirez vos bras vers le ciel",
        "Prenez 3 grandes respirations profondes",
        "Tapez doucement sur votre poitrine avec vos poings"
    ]
    
    let positiveReminders = [
        "Ce que vous ressentez maintenant est temporaire",
        "Vous avez déjà surmonté des moments difficiles avant",
        "Vous méritez compassion et bienveillance",
        "Il est courageux de demander de l'aide",
        "Chaque respiration vous rapproche du calme"
    ]
    
    private var breathingTimer: Timer?
    private var mindfulnessTimerInstance: Timer?
    private let dataManager = DataManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        startEmergencySession()
    }
    
    func startEmergencySession() {
        // Créer une nouvelle session d'urgence
        let triggerEmotion = determineTriggerEmotion()
        currentSession = dataManager.createEmergencySession(
            triggerEmotion: triggerEmotion,
            intensityBefore: distressLevel
        )
        
        // Envoyer une notification de suivi dans 1 heure
        NotificationManager.shared.scheduleEmergencyFollowUp()
    }
    
    func startTechnique(_ technique: EmergencyTechnique) {
        selectedTechnique = technique
        
        switch technique.type {
        case .breathing:
            startBreathingAnimation()
        case .grounding:
            startGroundingTechnique()
        case .mindfulness:
            startMindfulnessTechnique()
        case .movement:
            // Pas de timer spécial pour le mouvement
            break
        }
        
        // Haptic feedback
        AudioManager.shared.playHapticFeedback(style: .medium)
    }
    
    func startBreathingAnimation() {
        breathingTimer?.invalidate()
        
        var inhalePhase = true
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 4.0)) {
                if inhalePhase {
                    self.breathingScale = 1.3
                    self.breathingInstruction = "Inspirez lentement"
                } else {
                    self.breathingScale = 0.8
                    self.breathingInstruction = "Expirez doucement"
                }
            }
            inhalePhase.toggle()
        }
        
        // Commencer par inspirer
        withAnimation(.easeInOut(duration: 4.0)) {
            breathingScale = 1.3
            breathingInstruction = "Inspirez lentement"
        }
    }
    
    func startGroundingTechnique() {
        groundingStep = 0
    }
    
    func nextGroundingStep() {
        if groundingStep < 4 {
            groundingStep += 1
            AudioManager.shared.playHapticFeedback()
        }
    }
    
    func startMindfulnessTechnique() {
        mindfulnessTimer = 0
        updateMindfulnessGuidance()
        
        mindfulnessTimerInstance = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.mindfulnessTimer += 1
            
            // Changer les instructions toutes les 30 secondes
            if Int(self.mindfulnessTimer) % 30 == 0 {
                self.updateMindfulnessGuidance()
            }
        }
    }
    
    private func updateMindfulnessGuidance() {
        let guidances = [
            "Fermez les yeux et concentrez-vous sur votre respiration naturelle...",
            "Remarquez les sensations de votre corps contre la chaise ou le sol...",
            "Écoutez les sons autour de vous sans les juger...",
            "Si des pensées arrivent, observez-les comme des nuages qui passent...",
            "Revenez doucement à votre respiration quand votre esprit s'évade...",
            "Sentez la paix qui grandit en vous à chaque respiration..."
        ]
        
        let index = min(Int(mindfulnessTimer / 30), guidances.count - 1)
        mindfulnessGuidance = guidances[index]
    }
    
    func completeTechnique() {
        breathingTimer?.invalidate()
        mindfulnessTimerInstance?.invalidate()
        
        // Marquer la technique comme utilisée dans la session
        if let session = currentSession, let technique = selectedTechnique {
            var techniquesUsed = session.techniquesUsed ?? []
            techniquesUsed.append(technique.name)
            session.techniquesUsed = techniquesUsed
            
            // Calculer la durée totale de la session
            if let startDate = session.date {
                let duration = Int(Date().timeIntervalSince(startDate))
                session.duration = Int32(duration)
            }
            
            dataManager.save()
        }
        
        // Feedback haptique positif
        AudioManager.shared.playNotificationHaptic(type: .success)
    }
    
    func updateDistressAfter(_ newLevel: Int) {
        currentSession?.intensityAfter = Int16(newLevel)
        dataManager.save()
    }
    
    private func determineTriggerEmotion() -> String {
        // Logique simple pour déterminer l'émotion déclenchante basée sur le niveau
        switch distressLevel {
        case 8...10:
            return "Panique"
        case 6...7:
            return "Anxiété intense"
        case 4...5:
            return "Stress"
        default:
            return "Inquiétude"
        }
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    deinit {
        breathingTimer?.invalidate()
        mindfulnessTimerInstance?.invalidate()
    }
}

// Modèles pour les techniques d'urgence
struct EmergencyTechnique: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let type: TechniqueType
    let duration: Int // en minutes
    let icon: String
    let color: Color
    
    enum TechniqueType {
        case breathing, grounding, mindfulness, movement
    }
    
    static let allTechniques: [EmergencyTechnique] = [
        EmergencyTechnique(
            name: "Respiration calmante",
            description: "Respirations lentes et profondes pour apaiser le système nerveux",
            type: .breathing,
            duration: 3,
            icon: "lungs.fill",
            color: .blue
        ),
        
        EmergencyTechnique(
            name: "Ancrage 5-4-3-2-1",
            description: "Reconnectez-vous au moment présent grâce à vos sens",
            type: .grounding,
            duration: 5,
            icon: "hand.point.down.fill",
            color: .green
        ),
        
        EmergencyTechnique(
            name: "Pleine conscience",
            description: "Méditation guidée pour retrouver la sérénité",
            type: .mindfulness,
            duration: 5,
            icon: "brain.head.profile",
            color: .purple
        ),
        
        EmergencyTechnique(
            name: "Libération corporelle",
            description: "Mouvements doux pour évacuer les tensions",
            type: .movement,
            duration: 3,
            icon: "figure.arms.open",
            color: .orange
        )
    ]
}