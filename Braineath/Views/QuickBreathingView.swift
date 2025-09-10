//
//  QuickBreathingView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct QuickBreathingView: View {
    @EnvironmentObject var viewModel: BreathingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isActive = false
    @State private var currentPhase = "Prêt"
    @State private var cycleCount = 0
    @State private var timeRemaining = 120.0 // 2 minutes
    @State private var circleScale: CGFloat = 0.8
    @State private var timer: Timer?
    
    private let totalCycles = 8 // Environ 2 minutes avec le pattern 4-7-8
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Fond apaisant
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.2),
                            Color(.systemBackground)
                        ]),
                        center: .center,
                        startRadius: 50,
                        endRadius: geometry.size.width
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 40) {
                        // Titre et temps restant
                        VStack(spacing: 8) {
                            Text("Respiration Rapide")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("2 minutes de calme")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if isActive {
                                Text(timeString(from: timeRemaining))
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                    .monospacedDigit()
                            }
                        }
                        
                        Spacer()
                        
                        // Animation centrale
                        VStack(spacing: 24) {
                            ZStack {
                                // Cercles d'animation
                                ForEach(0..<3) { index in
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .blue.opacity(0.6),
                                                    .purple.opacity(0.4)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                        .frame(width: 200, height: 200)
                                        .scaleEffect(circleScale + CGFloat(index) * 0.1)
                                        .opacity(0.7 - Double(index) * 0.2)
                                }
                                
                                // Cercle central
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(colors: [
                                                .white.opacity(0.9),
                                                phaseColor.opacity(0.6)
                                            ]),
                                            center: .center,
                                            startRadius: 20,
                                            endRadius: 80
                                        )
                                    )
                                    .frame(width: 160, height: 160)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: phaseIcon)
                                                .font(.system(size: 24))
                                                .foregroundColor(phaseColor)
                                            
                                            Text(currentPhase)
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                        }
                                    )
                            }
                            
                            // Instructions
                            Text(instructionText)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                        
                        // Progression
                        if isActive {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Cycle \(cycleCount + 1) / \(totalCycles)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                }
                                
                                ProgressView(value: Double(cycleCount), total: Double(totalCycles))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                    .scaleEffect(x: 1, y: 2, anchor: .center)
                            }
                        }
                        
                        // Boutons de contrôle
                        HStack(spacing: 20) {
                            if !isActive {
                                Button("Commencer") {
                                    startQuickSession()
                                }
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 140, height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                            } else {
                                Button("Arrêter") {
                                    stopSession()
                                }
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                                .frame(width: 140, height: 50)
                                .background(
                                    Capsule()
                                        .fill(Color.red.opacity(0.1))
                                        .overlay(
                                            Capsule().stroke(Color.red, lineWidth: 2)
                                        )
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                Button("Fermer") {
                    stopSession()
                    dismiss()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
            }
        }
    }
    
    private var phaseColor: Color {
        switch currentPhase {
        case "Inspirez":
            return .green
        case "Retenez":
            return .orange
        case "Expirez":
            return .purple
        case "Terminé":
            return .blue
        default:
            return .blue
        }
    }
    
    private var phaseIcon: String {
        switch currentPhase {
        case "Inspirez":
            return "arrow.up.circle.fill"
        case "Retenez":
            return "pause.circle.fill"
        case "Expirez":
            return "arrow.down.circle.fill"
        case "Terminé":
            return "checkmark.circle.fill"
        default:
            return "play.circle.fill"
        }
    }
    
    private var instructionText: String {
        switch currentPhase {
        case "Inspirez":
            return "Respirez lentement par le nez"
        case "Retenez":
            return "Maintenez votre respiration"
        case "Expirez":
            return "Relâchez l'air doucement"
        case "Terminé":
            return "Session terminée avec succès !"
        default:
            return "Trouvez une position confortable"
        }
    }
    
    private func startQuickSession() {
        isActive = true
        cycleCount = 0
        timeRemaining = 120.0
        
        // Commencer le pattern de respiration
        startBreathingCycle()
        
        // Timer principal pour la session
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeSession()
            }
        }
        
        // Feedback haptique
        AudioManager.shared.playHapticFeedback()
    }
    
    private func startBreathingCycle() {
        // Phase 1: Inspiration (4 secondes)
        currentPhase = "Inspirez"
        withAnimation(.easeInOut(duration: 4.0)) {
            circleScale = 1.2
        }
        
        // Séquence des phases avec DispatchQueue
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            if self.isActive {
                self.holdPhase()
            }
        }
    }
    
    private func holdPhase() {
        currentPhase = "Retenez"
        // Maintenir l'échelle
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            if self.isActive {
                self.exhalePhase()
            }
        }
    }
    
    private func exhalePhase() {
        currentPhase = "Expirez"
        withAnimation(.easeInOut(duration: 8.0)) {
            circleScale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            if self.isActive {
                self.cycleCount += 1
                
                if self.cycleCount < self.totalCycles {
                    // Continuer avec le cycle suivant
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if self.isActive {
                            self.startBreathingCycle()
                        }
                    }
                } else {
                    self.completeSession()
                }
            }
        }
        
        // Feedback haptique léger à chaque expiration
        AudioManager.shared.playHapticFeedback(style: .light)
    }
    
    private func completeSession() {
        isActive = false
        currentPhase = "Terminé"
        timer?.invalidate()
        
        withAnimation(.easeInOut(duration: 1.0)) {
            circleScale = 1.0
        }
        
        // Enregistrer une session rapide
        _ = DataManager.shared.createBreathingSession(
            pattern: "Respiration Rapide",
            duration: 120,
            completionPercentage: 100.0,
            moodBefore: nil,
            moodAfter: nil
        )
        
        // Feedback de succès
        AudioManager.shared.playNotificationHaptic(type: .success)
        
        // Auto-fermeture après 3 secondes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            dismiss()
        }
    }
    
    private func stopSession() {
        isActive = false
        timer?.invalidate()
        currentPhase = "Prêt"
        
        withAnimation(.easeInOut(duration: 0.5)) {
            circleScale = 0.8
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    let breathingViewModel = BreathingViewModel()
    return QuickBreathingView()
        .environmentObject(breathingViewModel)
}