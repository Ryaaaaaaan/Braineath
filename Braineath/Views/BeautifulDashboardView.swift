//
//  BeautifulDashboardView.swift
//  Braineath
//
//  Created by Ryan Zemri on 12/09/2025.
//

import SwiftUI

struct BeautifulDashboardView: View {
    @EnvironmentObject var moodViewModel: MoodViewModel
    @EnvironmentObject var breathingViewModel: BreathingViewModel
    @StateObject private var profileManager = UserProfileManager.shared
    @StateObject private var wellnessViewModel = WellnessViewModel()
    
    @State private var showingQuickBreathing = false
    @State private var showingEmergencyView = false
    @State private var showingSettings = false
    @State private var currentQuoteIndex = 0
    
    // Animation states
    @State private var breathingScale: CGFloat = 1.0
    @State private var breathingOpacity: Double = 0.3
    @State private var quoteOpacity: Double = 1.0
    @State private var contentOffset: CGFloat = 0
    
    // Sélectionne une citation basée sur le jour du mois pour une rotation lente
    // Assure que l'utilisateur voit la même citation pendant toute la journée
    private var currentQuote: String {
        let quotes = profileManager.getPersonalizedQuotes()
        guard !quotes.isEmpty else { return "Respirez, vous êtes exactement là où vous devez être." }

        // Rotation basée sur le jour du mois - change une fois par jour maximum
        let day = Calendar.current.component(.day, from: Date())
        let index = day % quotes.count
        return quotes[index]
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated breathing background
                breathingBackground
                
                // Main content - remove ScrollView to prevent horizontal scrolling
                VStack(spacing: 0) {
                    // Header section
                    Spacer(minLength: geometry.safeAreaInsets.top + 20)
                    
                    VStack(spacing: 24) {
                        // Welcome section with greeting
                        welcomeSection
                            .cardEntry(delay: 0.1)

                        // Glowy quote section
                        quoteSection
                            .cardEntry(delay: 0.2)

                        // Quick breathing button
                        quickBreathingButton
                            .appleStyleButton()
                            .cardEntry(delay: 0.3)

                        // Compact stats if available
                        if !moodViewModel.recentMoodEntries.isEmpty {
                            compactStatsSection
                                .cardEntry(delay: 0.4)
                        }
                        
                        // Weekly wellness summary
                        weeklyWellnessSummary
                            .cardEntry(delay: 0.5)

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .offset(y: contentOffset)
                }
                .onAppear {
                    setupInitialState()
                    startAnimations()
                }
            }
            .ignoresSafeArea(.container, edges: .top)
        }
        .sheet(isPresented: $showingQuickBreathing) {
            QuickBreathingView()
        }
        .sheet(isPresented: $showingEmergencyView) {
            EmergencyModeView()
        }
        .sheet(isPresented: $showingSettings) {
            AppSettingsView()
                .environmentObject(breathingViewModel)
                .environmentObject(moodViewModel)
        }
    }
    
    private var breathingBackground: some View {
        ZStack {
            // Base gradient with blur effect
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.15),
                    Color.purple.opacity(0.08),
                    Color.pink.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                // Blur overlay
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
            )
            .ignoresSafeArea()
            
            // Fixed animated breathing circles - no position to prevent layout issues
            ForEach(0..<2, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(breathingOpacity * 0.2),
                                Color.blue.opacity(breathingOpacity * 0.05),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 30,
                            endRadius: 150
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(breathingScale + CGFloat(index) * 0.1)
                    .opacity(breathingOpacity - Double(index) * 0.1)
                    .blur(radius: 8 + CGFloat(index * 3))
                    .offset(x: CGFloat(index * 100 - 50), y: CGFloat(index * 50 - 25))
            }
        }
    }
    
    
    private var welcomeSection: some View {
        VStack(spacing: 16) {
            // Settings button in top right corner
            HStack {
                Spacer()
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.15))
                                .shadow(color: .white.opacity(0.3), radius: 8, x: 0, y: 0)
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 10)
            
            // Centered greeting section - moved higher
            VStack(spacing: 6) {
                Text(greetingMessage)
                    .font(.system(size: 20, weight: .light, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text(profileManager.currentProfile?.name ?? "")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Comment vous sentez-vous aujourd'hui ?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .opacity(0.8)
            }
            .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Bonjour"
        case 12..<17:
            return "Bon après-midi"
        case 17..<22:
            return "Bonsoir"
        default:
            return "Bonne nuit"
        }
    }
    
    private var quoteSection: some View {
        VStack(spacing: 20) {
            Text(currentQuote)
                .font(.title2)
                .fontWeight(.medium)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .opacity(quoteOpacity)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.blue.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blur(radius: 10)
                        .opacity(0.7)
                )
                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
    
    private var quickBreathingButton: some View {
        Button(action: { showingEmergencyView = true }) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("Urgence / Crise de panique")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.red, .red.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: .red.opacity(0.6), radius: 15, x: 0, y: 8)
            .shadow(color: .red.opacity(0.4), radius: 25, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var compactStatsSection: some View {
        VStack(spacing: 20) {
            Text("Votre progression")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 20) {
                // Single row to prevent horizontal overflow
                HStack(spacing: 16) {
                    StatGlass(
                        title: "Humeur",
                        value: String(format: "%.1f", averageMood()),
                        subtitle: "/10",
                        color: .pink
                    )
                    
                    StatGlass(
                        title: "Série",
                        value: "\(breathingViewModel.streakDays)",
                        subtitle: "jours",
                        color: .orange
                    )
                    
                    StatGlass(
                        title: "Sessions",
                        value: "\(breathingViewModel.totalSessions)",
                        subtitle: "total",
                        color: .green
                    )
                }
            }
        }
    }
    
    
    private func setupInitialState() {
        breathingViewModel.loadRecentSessions()
        breathingViewModel.calculateStats()
        moodViewModel.loadRecentMoods()
        
        // Set initial quote
        let quotes = profileManager.getPersonalizedQuotes()
        if !quotes.isEmpty {
            currentQuoteIndex = Int.random(in: 0..<quotes.count)
        }
    }
    
    // Lance les animations de fond pour créer une atmosphère apaisante
    // La respiration de fond aide à induire un état de calme chez l'utilisateur
    private func startAnimations() {
        // Animation de respiration lente en arrière-plan
        withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
            breathingScale = 1.2
            breathingOpacity = 0.5
        }

        // Animation d'apparition progressive des éléments
        withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
            contentOffset = 0
        }

        // Transition douce pour l'affichage de la citation
        withAnimation(.easeInOut(duration: 0.8)) {
            quoteOpacity = 1.0
        }
    }
    
    private func averageMood() -> Double {
        let recentEntries = moodViewModel.recentMoodEntries.prefix(7)
        guard !recentEntries.isEmpty else { return 0 }
        let sum = recentEntries.reduce(0) { $0 + $1.emotionIntensity }
        return Double(sum) / Double(recentEntries.count)
    }
    
    private var weeklyWellnessSummary: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Résumé hebdomadaire")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Score moyen: \(String(format: "%.1f", wellnessViewModel.getAverageWellnessScore()))/100")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                let trend = wellnessViewModel.getMoodTrend()
                Image(systemName: trend > 0 ? "arrow.up.right" : trend < 0 ? "arrow.down.right" : "arrow.right")
                    .foregroundColor(trend > 0 ? .green : trend < 0 ? .red : .orange)
                    .font(.title3)
            }
            
            // Quick wellness indicators
            HStack(spacing: 12) {
                WellnessIndicator(
                    icon: "brain.head.profile",
                    value: "\(wellnessViewModel.mindfulnessMinutesThisWeek)",
                    label: "min méditation",
                    color: .purple
                )
                
                WellnessIndicator(
                    icon: "lungs.fill",
                    value: "\(breathingViewModel.totalSessions)",
                    label: "sessions",
                    color: .blue
                )
                
                WellnessIndicator(
                    icon: "heart.fill",
                    value: String(format: "%.1f", averageMood()),
                    label: "humeur",
                    color: .pink
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct WellnessIndicator: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.callout)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

struct QuickActionGlass: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 100, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                color.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blur(radius: 10)
                    .opacity(0.8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                color.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: color.opacity(0.2), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatGlass: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: title == "Humeur" ? "heart.fill" : "flame.fill")
                .font(.title)
                .foregroundColor(color)
            
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .offset(y: -2)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .background(
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.4),
                            color.opacity(0.2),
                            color.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .blur(radius: 15)
                .scaleEffect(1.2)
        )
        .shadow(color: color.opacity(0.4), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    BeautifulDashboardView()
        .environmentObject(MoodViewModel())
        .environmentObject(BreathingViewModel())
}