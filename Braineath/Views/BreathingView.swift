//
//  BreathingView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct BreathingView: View {
    @EnvironmentObject var viewModel: BreathingViewModel
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Gradient de fond adaptatif
                    backgroundGradient
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            if viewModel.breathingState == .idle {
                                idleStateView
                            } else {
                                activeSessionView(geometry: geometry)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Respiration")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                BreathingSettingsView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $viewModel.showingMoodRating) {
                MoodRatingView()
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            viewModel.loadRecentSessions()
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 2.0), value: viewModel.currentPhase)
    }
    
    private var gradientColors: [Color] {
        switch viewModel.currentPhase {
        case .ready, .complete:
            return [.blue.opacity(0.3), .purple.opacity(0.3)]
        case .inhale:
            return [.green.opacity(0.4), .blue.opacity(0.4)]
        case .holdAfterInhale, .holdAfterExhale:
            return [.yellow.opacity(0.3), .orange.opacity(0.3)]
        case .exhale:
            return [.purple.opacity(0.4), .pink.opacity(0.4)]
        }
    }
    
    private var idleStateView: some View {
        VStack(spacing: 32) {
            // Statistiques rapides
            statsSection
            
            // Sélection du pattern
            patternSelectionSection
            
            // Sélection de la durée
            durationSelectionSection
            
            // Bouton de démarrage principal
            startButton
            
            // Sessions récentes
            recentSessionsSection
        }
    }
    
    private func activeSessionView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 32) {
            // Progression de la session
            sessionProgressSection
            
            // Animation de respiration centrale
            breathingAnimationView(geometry: geometry)
            
            // Instructions et phase actuelle
            instructionsSection
            
            // Contrôles de session
            sessionControlsSection
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Streak",
                value: "\(viewModel.streakDays)",
                subtitle: "jours",
                color: .orange,
                icon: "flame.fill"
            )
            
            StatCard(
                title: "Cette semaine",
                value: "\(viewModel.totalMinutesThisWeek)",
                subtitle: "minutes",
                color: .green,
                icon: "clock.fill"
            )
            
            StatCard(
                title: "Total sessions",
                value: "\(viewModel.recentSessions.count)",
                subtitle: "complétées",
                color: .blue,
                icon: "lungs.fill"
            )
        }
    }
    
    private var patternSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pattern de respiration")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(BreathingPattern.allCases, id: \.self) { pattern in
                        BreathingPatternCard(
                            pattern: pattern,
                            isSelected: viewModel.selectedPattern == pattern
                        ) {
                            viewModel.selectedPattern = pattern
                            AudioManager.shared.playHapticFeedback()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var durationSelectionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Durée de session")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.sessionDuration) min")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            HStack(spacing: 12) {
                ForEach([1, 3, 5, 10, 15, 20], id: \.self) { duration in
                    Button("\(duration)m") {
                        viewModel.sessionDuration = duration
                        AudioManager.shared.playHapticFeedback()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.sessionDuration == duration ? .white : .primary)
                    .frame(width: 50, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(viewModel.sessionDuration == duration ? Color.blue : Color(.tertiarySystemBackground))
                    )
                }
            }
        }
    }
    
    private var startButton: some View {
        Button(action: {
            viewModel.startBreathingSession()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.title2)
                
                Text("Commencer")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
    
    private var sessionProgressSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Cycle \(viewModel.currentCycle)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(viewModel.formatTime(viewModel.timeRemaining))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            ProgressView(value: viewModel.sessionProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 3, anchor: .center)
        }
    }
    
    private func breathingAnimationView(geometry: GeometryProxy) -> some View {
        let size = min(geometry.size.width * 0.7, 300)
        
        return ZStack {
            // Cercles d'animation
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: size, height: size)
                    .scaleEffect(viewModel.circleScale + CGFloat(index) * 0.1)
                    .opacity(viewModel.circleOpacity - Double(index) * 0.2)
                    .animation(
                        .easeInOut(duration: 1.0)
                        .delay(Double(index) * 0.1),
                        value: viewModel.circleScale
                    )
            }
            
            // Cercle central avec phase
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.8),
                            phaseColor.opacity(0.6)
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: size/2
                    )
                )
                .frame(width: size * 0.6, height: size * 0.6)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: phaseIcon)
                            .font(.system(size: 30))
                            .foregroundColor(phaseColor)
                        
                        Text(viewModel.phaseText)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                )
        }
    }
    
    private var phaseColor: Color {
        switch viewModel.currentPhase {
        case .inhale:
            return .green
        case .holdAfterInhale, .holdAfterExhale:
            return .orange
        case .exhale:
            return .purple
        case .ready:
            return .blue
        case .complete:
            return .green
        }
    }
    
    private var phaseIcon: String {
        switch viewModel.currentPhase {
        case .inhale:
            return "arrow.up.circle.fill"
        case .holdAfterInhale, .holdAfterExhale:
            return "pause.circle.fill"
        case .exhale:
            return "arrow.down.circle.fill"
        case .ready:
            return "play.circle.fill"
        case .complete:
            return "checkmark.circle.fill"
        }
    }
    
    private var instructionsSection: some View {
        VStack(spacing: 12) {
            Text(viewModel.phaseText)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(viewModel.instructionText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var sessionControlsSection: some View {
        HStack(spacing: 24) {
            if viewModel.breathingState == .running {
                Button("Pause") {
                    viewModel.pauseSession()
                }
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.orange)
                .frame(width: 120, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                )
            } else if viewModel.breathingState == .paused {
                Button("Reprendre") {
                    viewModel.resumeSession()
                }
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.green)
                .frame(width: 120, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.green.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.green, lineWidth: 2)
                        )
                )
            }
            
            Button("Arrêter") {
                viewModel.stopSession()
            }
            .font(.title3)
            .fontWeight(.medium)
            .foregroundColor(.red)
            .frame(width: 120, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.red, lineWidth: 2)
                    )
            )
        }
    }
    
    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sessions récentes")
                .font(.headline)
                .foregroundColor(.primary)
            
            if viewModel.recentSessions.isEmpty {
                Text("Aucune session pour le moment")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.recentSessions.prefix(3), id: \.id) { session in
                        BreathingSessionRow(session: session)
                    }
                }
            }
        }
    }
}

// Composants auxiliaires
struct BreathingPatternCard: View {
    let pattern: BreathingPattern
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Text(pattern.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(pattern.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            .frame(width: 160, height: 80)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.tertiarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BreathingSessionRow: View {
    let session: BreathingSession
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lungs.fill")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.breathingPattern ?? "Pattern inconnu")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let date = session.date {
                    Text(date, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.duration / 60):\(String(format: "%02d", session.duration % 60))")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("\(Int(session.completionPercentage))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let breathingViewModel = BreathingViewModel()
    return BreathingView()
        .environmentObject(breathingViewModel)
}