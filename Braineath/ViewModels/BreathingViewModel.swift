//
//  BreathingViewModel.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import Foundation
import SwiftUI
import Combine

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
    
    func startBreathingSession() {
        guard breathingState == .idle else { return }
        
        breathingState = .running
        startTime = Date()
        currentCycle = 0
        sessionProgress = 0.0
        
        // Calculer le nombre total de cycles
        let totalDuration = Double(sessionDuration * 60)
        let cycleDuration = selectedPattern.inhaleTime + selectedPattern.holdTime + selectedPattern.exhaleTime + selectedPattern.pauseTime
        totalCycles = Int(totalDuration / cycleDuration)
        
        timeRemaining = totalDuration
        
        if soundEnabled {
            audioManager.playBreathingSound(selectedSound)
        }
        
        startBreathingCycle()
        startSessionTimer()
        
        // Demander l'évaluation de l'humeur avant
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showingMoodRating = true
        }
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
        breathingState = .completed
        currentPhase = .complete
        
        phaseTimer?.invalidate()
        breathingTimer?.invalidate()
        audioManager.stopCurrentSound()
        
        withAnimation(.easeInOut(duration: 1.0)) {
            circleScale = 1.0
            circleOpacity = 0.8
        }
        
        // Sauvegarder la session
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
        
        // Recharger les statistiques
        loadRecentSessions()
        calculateStats()
        
        // Feedback haptique de succès
        if hapticEnabled {
            audioManager.playNotificationHaptic(type: .success)
        }
        
        updatePhaseText()
        
        // Reset après quelques secondes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
    
    private func calculateStreakDays() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        for _ in 0..<30 { // Regarder les 30 derniers jours maximum
            let daysSessions = recentSessions.filter { session in
                guard let sessionDate = session.date else { return false }
                return calendar.isDate(sessionDate, inSameDayAs: currentDate)
            }
            
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
}