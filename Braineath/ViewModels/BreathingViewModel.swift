//
//  BreathingViewModel.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import Foundation
import SwiftUI
import Combine
import ActivityKit

class BreathingViewModel: ObservableObject {
    @Published var selectedPattern: BreathingPattern = .basic478
    @Published var sessionDuration: Int = 5 // minutes
    @Published var currentPhase: BreathingPhase = .ready
    @Published var breathingState: BreathingState = .idle
    @Published var currentCycle: Int = 0
    @Published var totalCycles: Int = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var sessionProgress: Double = 0.0
    @Published var moodBefore: Int?
    @Published var moodAfter: Int?
    @Published var showingMoodRating = false
    
    // Animation et UI
    @Published var circleScale: CGFloat = 0.8
    @Published var circleOpacity: Double = 0.6
    @Published var phaseText: String = "Prêt à commencer"
    @Published var instructionText: String = "Trouvez une position confortable"
    
    // Audio et haptiques
    @Published var selectedSound: AudioManager.BreathingSound = .silence
    @Published var soundEnabled: Bool = true
    @Published var hapticEnabled: Bool = true
    
    private var breathingTimer: Timer?
    private var phaseTimer: Timer?
    private var startTime: Date?
    private let audioManager = AudioManager.shared
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var breathingActivity: Activity<BreathingActivityAttributes>?
    
    // Statistiques de session
    @Published var recentSessions: [BreathingSession] = []
    @Published var totalMinutesThisWeek: Int = 0
    @Published var streakDays: Int = 0
    @Published var totalSessions: Int = 0
    @Published var totalMinutes: Int = 0
    
    enum BreathingPhase: String, CaseIterable {
        case ready = "Prêt"
        case inhale = "Inspiration"
        case holdAfterInhale = "Rétention"
        case exhale = "Expiration"
        case holdAfterExhale = "Pause"
        case complete = "Terminé"
    }
    
    enum BreathingState {
        case idle, running, paused, completed
    }
    
    init() {
        loadRecentSessions()
        calculateStats()
        updatePhaseText()
    }
    
    // Point d'entrée pour démarrer une session - affiche d'abord la popup d'humeur
    func startBreathingSession() {
        guard breathingState == .idle else { return }

        // Important : on demande l'humeur AVANT de commencer pour avoir une base de comparaison
        showingMoodRating = true
    }

    // Démarre réellement la session après l'évaluation d'humeur
    func actuallyStartBreathingSession() {
        breathingState = .running
        startTime = Date()
        startLiveActivity()
        currentCycle = 0
        sessionProgress = 0.0

        // Calcul du nombre de cycles basé sur la durée sélectionnée et le pattern choisi
        let totalDuration = Double(sessionDuration * 60)
        let cycleDuration = selectedPattern.inhaleTime + selectedPattern.holdTime + selectedPattern.exhaleTime + selectedPattern.pauseTime
        totalCycles = Int(totalDuration / cycleDuration)

        timeRemaining = totalDuration

        // Démarrage du son d'ambiance si activé
        if soundEnabled {
            audioManager.playBreathingSound(selectedSound)
        }

        startBreathingCycle()
        startSessionTimer()
    }
    
    private func startBreathingCycle() {
        currentCycle += 1
        startInhalePhase()
    }
    
    private func startInhalePhase() {
        currentPhase = .inhale
        updatePhaseText()
        
        withAnimation(.easeInOut(duration: selectedPattern.inhaleTime)) {
            circleScale = 1.2
            circleOpacity = 0.9
        }
        
        if hapticEnabled {
            audioManager.playHapticFeedback(style: .light)
        }
        
        if soundEnabled {
            audioManager.playInhaleChime()
        }
        
        phaseTimer = Timer.scheduledTimer(withTimeInterval: selectedPattern.inhaleTime, repeats: false) { _ in
            self.startHoldAfterInhalePhase()
        }
    }
    
    private func startHoldAfterInhalePhase() {
        guard selectedPattern.holdTime > 0 else {
            startExhalePhase()
            return
        }
        
        currentPhase = .holdAfterInhale
        updatePhaseText()
        
        // Maintenir l'état visuel
        if soundEnabled {
            audioManager.playHoldChime()
        }
        
        phaseTimer = Timer.scheduledTimer(withTimeInterval: selectedPattern.holdTime, repeats: false) { _ in
            self.startExhalePhase()
        }
    }
    
    private func startExhalePhase() {
        currentPhase = .exhale
        updatePhaseText()
        
        withAnimation(.easeInOut(duration: selectedPattern.exhaleTime)) {
            circleScale = 0.8
            circleOpacity = 0.4
        }
        
        if hapticEnabled {
            audioManager.playHapticFeedback(style: .medium)
        }
        
        if soundEnabled {
            audioManager.playExhaleChime()
        }
        
        phaseTimer = Timer.scheduledTimer(withTimeInterval: selectedPattern.exhaleTime, repeats: false) { _ in
            self.startHoldAfterExhalePhase()
        }
    }
    
    private func startHoldAfterExhalePhase() {
        guard selectedPattern.pauseTime > 0 else {
            completeCycle()
            return
        }
        
        currentPhase = .holdAfterExhale
        updatePhaseText()
        
        phaseTimer = Timer.scheduledTimer(withTimeInterval: selectedPattern.pauseTime, repeats: false) { _ in
            self.completeCycle()
        }
    }
    
    private func completeCycle() {
        if currentCycle < totalCycles && breathingState == .running {
            startBreathingCycle()
        } else {
            completeSession()
        }
    }
    
    private func startSessionTimer() {
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                self.updateProgress()
            } else {
                self.completeSession()
            }
        }
    }
    
    private func updateProgress() {
        let totalDuration = Double(sessionDuration * 60)
        sessionProgress = 1.0 - (timeRemaining / totalDuration)
        updateLiveActivity()
    }
    
    func pauseSession() {
        breathingState = .paused
        phaseTimer?.invalidate()
        breathingTimer?.invalidate()
        audioManager.stopCurrentSound()
    }
    
    func resumeSession() {
        breathingState = .running
        if soundEnabled {
            audioManager.playBreathingSound(selectedSound)
        }
        startBreathingCycle()
        startSessionTimer()
    }
    
    func stopSession() {
        completeSession()
    }
    
    private func completeSession() {
        // Immediate UI changes - no delay
        breathingState = .completed
        currentPhase = .complete
        
        // Stop timers and audio immediately
        phaseTimer?.invalidate()
        breathingTimer?.invalidate()
        audioManager.stopCurrentSound()
        
        // Shorter, snappier animation
        withAnimation(.easeInOut(duration: 0.4)) {
            circleScale = 1.0
            circleOpacity = 0.8
        }
        
        // Background operations - don't block UI
        Task {
            // Save session in background
            if let startTime = startTime {
                let actualDuration = Int(Date().timeIntervalSince(startTime))
                let completionPercentage = sessionProgress * 100
                
                _ = dataManager.createBreathingSession(
                    pattern: selectedPattern.rawValue,
                    duration: actualDuration,
                    completionPercentage: completionPercentage,
                    moodBefore: moodBefore,
                    moodAfter: moodAfter
                )
            }
            
            // Update stats in background
            await MainActor.run {
                loadRecentSessions()
                calculateStats()
            }
        }
        
        // End Live Activity after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.endLiveActivity()
        }
        
        // Immediate haptic feedback
        if hapticEnabled {
            audioManager.playNotificationHaptic(type: .success)
        }
        
        updatePhaseText()
        
        // Reset after shorter delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.resetSession()
        }
    }
    
    private func resetSession() {
        breathingState = .idle
        currentPhase = .ready
        currentCycle = 0
        totalCycles = 0
        timeRemaining = 0
        sessionProgress = 0.0
        moodBefore = nil
        moodAfter = nil
        startTime = nil
        updatePhaseText()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            circleScale = 0.8
            circleOpacity = 0.6
        }
    }
    
    private func updatePhaseText() {
        switch currentPhase {
        case .ready:
            phaseText = "Prêt à commencer"
            instructionText = "Trouvez une position confortable et détendez-vous"
        case .inhale:
            phaseText = "Inspirez"
            instructionText = "Respirez lentement par le nez"
        case .holdAfterInhale:
            phaseText = "Retenez"
            instructionText = "Maintenez votre respiration"
        case .exhale:
            phaseText = "Expirez"
            instructionText = "Relâchez l'air doucement"
        case .holdAfterExhale:
            phaseText = "Pause"
            instructionText = "Détendez-vous complètement"
        case .complete:
            phaseText = "Félicitations"
            instructionText = "Session terminée avec succès !"
        }
    }
    
    func loadRecentSessions() {
        recentSessions = dataManager.fetchBreathingSessions(limit: 14)
    }
    
    func calculateStats() {
        // Calculer les minutes totales cette semaine
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let thisWeekSessions = recentSessions.filter { session in
            guard let date = session.date else { return false }
            return date >= weekAgo
        }
        
        totalMinutesThisWeek = thisWeekSessions.reduce(0) { total, session in
            return total + Int(session.duration) / 60
        }
        
        // Calculer le nombre total de sessions
        totalSessions = recentSessions.count
        
        // Calculer le total de minutes (toutes sessions)
        totalMinutes = recentSessions.reduce(0) { total, session in
            return total + Int(session.duration) / 60
        }
        
        // Calculer la série de jours consécutifs
        streakDays = calculateStreakDays()
    }
    
    // Calcule le nombre de jours consécutifs avec au moins une session
    // Utile pour gamifier l'expérience et encourager la régularité
    private func calculateStreakDays() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        // On regarde jusqu'à 30 jours en arrière pour calculer la série
        for _ in 0..<30 {
            let daysSessions = recentSessions.filter { session in
                guard let sessionDate = session.date else { return false }
                return calendar.isDate(sessionDate, inSameDayAs: currentDate)
            }

            // Dès qu'on trouve un jour sans session, on arrête le décompte
            if daysSessions.isEmpty {
                break
            } else {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            }
        }

        return streak
    }
    
    // Fonction utilitaire pour formater le temps
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Live Activities
    
    private func startLiveActivity() {
        // Check if running in simulator or Live Activities are disabled
        #if targetEnvironment(simulator)
        print("Live Activities not supported in Simulator")
        return
        #endif
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { 
            print("Live Activities not enabled")
            return 
        }
        
        let attributes = BreathingActivityAttributes(
            sessionType: selectedPattern.rawValue,
            duration: sessionDuration,
            startTime: Date()
        )
        
        let contentState = BreathingActivityAttributes.ContentState(
            currentPhase: currentPhase.rawValue,
            timeRemaining: Int(timeRemaining),
            cycleCount: currentCycle,
            totalCycles: totalCycles,
            progress: sessionProgress,
            isActive: true
        )
        
        do {
            breathingActivity = try Activity<BreathingActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil)
            )
            print("Live Activity started successfully")
        } catch {
            print("Error starting Live Activity: \(error) - gracefully continuing without Live Activity")
        } catch {
            print("Error starting Live Activity: \(error) - gracefully continuing without Live Activity")
        }
    }
    
    private func updateLiveActivity() {
        guard let activity = breathingActivity else { return }
        
        let contentState = BreathingActivityAttributes.ContentState(
            currentPhase: currentPhase.rawValue,
            timeRemaining: Int(timeRemaining),
            cycleCount: currentCycle,
            totalCycles: totalCycles,
            progress: sessionProgress,
            isActive: breathingState == .running
        )
        
        Task {
            await activity.update(.init(state: contentState, staleDate: nil))
        }
    }
    
    private func endLiveActivity() {
        guard let activity = breathingActivity else { return }
        
        let contentState = BreathingActivityAttributes.ContentState(
            currentPhase: "Terminé",
            timeRemaining: 0,
            cycleCount: totalCycles,
            totalCycles: totalCycles,
            progress: 1.0,
            isActive: false
        )
        
        Task {
            await activity.end(.init(state: contentState, staleDate: nil), dismissalPolicy: .immediate)
        }
        
        breathingActivity = nil
    }
}