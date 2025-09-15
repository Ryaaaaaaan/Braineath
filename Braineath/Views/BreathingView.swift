//
//  BreathingView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct BreathingView: View {
    @EnvironmentObject var viewModel: BreathingViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient de fond adaptatif avec blur
                backgroundGradient

                // Responsive layout that adapts to screen size
                VStack(spacing: 0) {
                    if viewModel.breathingState == .idle {
                        idleStateView(geometry: geometry)
                            .transition(.opacity.combined(with: .scale))
                    } else {
                        activeSessionView(geometry: geometry)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .animation(.easeInOut(duration: 0.4), value: viewModel.breathingState)
            }
        }
        .toolbar(viewModel.breathingState != .idle ? .hidden : .visible, for: .tabBar)
        .sheet(isPresented: $viewModel.showingMoodRating) {
            MoodRatingView()
                .environmentObject(viewModel)
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
        .overlay(
            // Blur overlay for consistency with other views
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.2)
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
    
    private func idleStateView(geometry: GeometryProxy) -> some View {
        let screenHeight = geometry.size.height
        let compactSpacing = screenHeight < 700 ? 12.0 : 20.0
        
        return VStack(spacing: compactSpacing) {
            // Statistiques rapides - plus compactes
            compactStatsSection
            
            // Sélection du pattern - plus compact
            patternSelectionSection
            
            // Sélection de la durée - inline
            inlineDurationSelection
            
            // Bouton de démarrage principal
            startButton
            
            Spacer(minLength: 8)
        }
    }
    
    private func activeSessionView(geometry: GeometryProxy) -> some View {
        let screenHeight = geometry.size.height
        let compactMode = screenHeight < 700
        let spacing = compactMode ? 16.0 : 32.0
        
        return VStack(spacing: 0) {
            // Add spacer at top to center content
            Spacer(minLength: compactMode ? 20 : 40)
            
            // Animation de respiration centrale avec countdown circulaire intégré
            breathingAnimationViewWithCircularProgress(geometry: geometry)
                .padding(.bottom, compactMode ? 16 : 24)
            
            // Instructions et phase actuelle - plus compacte si nécessaire
            instructionsSection(compact: compactMode)
                .padding(.bottom, compactMode ? 12 : 16)
            
            // Contrôles de session - adaptés
            sessionControlsSection(compact: compactMode)
            
            // Balance with bottom spacer
            Spacer(minLength: compactMode ? 20 : 40)
        }
    }
    
    private var compactStatsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Série",
                value: "\(viewModel.streakDays)",
                color: .orange,
                icon: "flame.fill"
            )
            
            StatCard(
                title: "Sessions",
                value: "\(viewModel.recentSessions.count)",
                color: .blue,
                icon: "lungs.fill"
            )
            
            StatCard(
                title: "Minutes",
                value: "\(viewModel.totalMinutesThisWeek)",
                color: .green,
                icon: "clock.fill"
            )
        }
        .padding(.horizontal, 4)
    }
    
    private var patternSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pattern de respiration")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Compact pattern buttons grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(BreathingPattern.allCases, id: \.self) { pattern in
                    CompactPatternButton(
                        pattern: pattern,
                        isSelected: viewModel.selectedPattern == pattern
                    ) {
                        viewModel.selectedPattern = pattern
                        AudioManager.shared.playHapticFeedback()
                    }
                }
            }
        }
    }
    
    private var inlineDurationSelection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Durée")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.sessionDuration) min")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            HStack(spacing: 6) {
                ForEach([1, 3, 5, 10, 15], id: \.self) { duration in
                    Button("\(duration)m") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.sessionDuration = duration
                        }
                        AudioManager.shared.playHapticFeedback()
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.sessionDuration == duration ? .white : .primary)
                    .frame(width: 40, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(viewModel.sessionDuration == duration ? Color.blue : Color(.tertiarySystemBackground))
                    )
                    .scaleEffect(viewModel.sessionDuration == duration ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.sessionDuration)
                }
            }
        }
        .padding(.horizontal, 8)
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

            // Barre de progression douce et moderne - responsive
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Fond de la barre
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)

                    // Progression avec gradient doux
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.sessionProgress, height: 6)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.sessionProgress)

                    // Effet de lueur
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.sessionProgress, height: 6)
                        .blur(radius: 3)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.sessionProgress)
                }
            }
            .frame(height: 6)
        }
        .padding(.top, 8)
    }
    
    private func breathingAnimationViewWithCircularProgress(geometry: GeometryProxy) -> some View {
        let screenHeight = geometry.size.height
        let screenWidth = geometry.size.width
        let compactMode = screenHeight < 700
        
        // Adaptive sizing based on available space
        let maxSize = compactMode ? min(screenWidth * 0.6, 200) : min(screenWidth * 0.7, 300)
        let availableHeight = screenHeight * (compactMode ? 0.4 : 0.5)
        let size = min(maxSize, availableHeight)
        
        return VStack(spacing: compactMode ? 16 : 24) {
            // Cycle info at the top
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
            .padding(.horizontal)
            
            // Main breathing animation with circular progress
            ZStack {
                // Circular progress ring (background)
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    .frame(width: size + 40, height: size + 40)
                
                // Circular progress ring (foreground)
                Circle()
                    .trim(from: 0, to: CGFloat(viewModel.sessionProgress))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: size + 40, height: size + 40)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.sessionProgress)
                
                // Breathing circles animation
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: compactMode ? 2 : 3
                        )
                        .frame(width: size, height: size)
                        .scaleEffect(viewModel.circleScale + CGFloat(index) * 0.1)
                        .opacity(viewModel.circleOpacity - Double(index) * 0.15)
                        .animation(
                            .spring(response: 1.2, dampingFraction: 0.7)
                            .delay(Double(index) * 0.1),
                            value: viewModel.circleScale
                        )
                }
                
                // Central breathing phase indicator
                VStack(spacing: 8) {
                    Text(viewModel.currentPhase.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(viewModel.formatTime(viewModel.timeRemaining))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .monospaced()
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentPhase)
            }
        }
    }
    
    private func breathingAnimationView(geometry: GeometryProxy) -> some View {
        let screenHeight = geometry.size.height
        let screenWidth = geometry.size.width
        let compactMode = screenHeight < 700
        
        // Adaptive sizing based on available space
        let maxSize = compactMode ? min(screenWidth * 0.6, 200) : min(screenWidth * 0.7, 300)
        let availableHeight = screenHeight * (compactMode ? 0.25 : 0.35)
        let size = min(maxSize, availableHeight)
        
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
                        lineWidth: compactMode ? 2 : 3
                    )
                    .frame(width: size, height: size)
                    .scaleEffect(viewModel.circleScale + CGFloat(index) * 0.1)
                    .opacity(viewModel.circleOpacity - Double(index) * 0.15)
                    .animation(
                        .spring(response: 1.2, dampingFraction: 0.7)
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
                        startRadius: compactMode ? 15 : 20,
                        endRadius: size/2
                    )
                )
                .frame(width: size * 0.6, height: size * 0.6)
                .overlay(
                    VStack(spacing: compactMode ? 4 : 8) {
                        Image(systemName: phaseIcon)
                            .font(.system(size: compactMode ? 24 : 30))
                            .foregroundColor(phaseColor)
                        
                        Text(viewModel.phaseText)
                            .font(compactMode ? .callout : .title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                )
        }
        .frame(maxHeight: availableHeight)
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
    
    private func instructionsSection(compact: Bool) -> some View {
        VStack(spacing: compact ? 8 : 12) {
            Text(viewModel.phaseText)
                .font(compact ? .title2 : .largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(viewModel.instructionText)
                .font(compact ? .caption : .subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(compact ? 2 : nil)
        }
    }
    
    private func sessionControlsSection(compact: Bool) -> some View {
        let buttonWidth: CGFloat = compact ? 100 : 120
        let buttonHeight: CGFloat = compact ? 40 : 50
        let spacing: CGFloat = compact ? 16 : 24
        
        return HStack(spacing: spacing) {
            if viewModel.breathingState == .running {
                Button("Pause") {
                    viewModel.pauseSession()
                }
                .font(compact ? .callout : .title3)
                .fontWeight(.medium)
                .foregroundColor(.orange)
                .frame(width: buttonWidth, height: buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: buttonHeight/2)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: buttonHeight/2)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                )
            } else if viewModel.breathingState == .paused {
                Button("Reprendre") {
                    viewModel.resumeSession()
                }
                .font(compact ? .caption : .title3)
                .fontWeight(.medium)
                .foregroundColor(.green)
                .frame(width: buttonWidth, height: buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: buttonHeight/2)
                        .fill(Color.green.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: buttonHeight/2)
                                .stroke(Color.green, lineWidth: 2)
                        )
                )
            }
            
            Button("Arrêter") {
                // Immediate haptic feedback
                AudioManager.shared.playHapticFeedback()
                
                // Immediate UI response
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.stopSession()
                }
            }
            .font(compact ? .callout : .title3)
            .fontWeight(.medium)
            .foregroundColor(.red)
            .frame(width: buttonWidth, height: buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: buttonHeight/2)
                    .fill(Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: buttonHeight/2)
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
struct CompactPatternButton: View {
    let pattern: BreathingPattern
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(pattern.emoji)
                    .font(.title3)
                
                Text(pattern.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 70)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.15) : Color(.tertiarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

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
            .frame(maxWidth: .infinity, minHeight: 70)
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


#Preview {
    let breathingViewModel = BreathingViewModel()
    return BreathingView()
        .environmentObject(breathingViewModel)
}