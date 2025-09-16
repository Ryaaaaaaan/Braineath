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
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated breathing background
                breathingBackground
                
                // Main content - single page without scrolling
                VStack(spacing: 0) {
                    // Header section - compact
                    Spacer(minLength: geometry.safeAreaInsets.top + 10)

                    VStack(spacing: 20) {
                        // Welcome section with greeting - more compact
                        welcomeSection
                            .cardEntry(delay: 0.1)

                        // Glowy quote section - compact
                        quoteSection
                            .cardEntry(delay: 0.2)

                        // Quick breathing button - smaller
                        quickBreathingButton
                            .appleStyleButton()
                            .cardEntry(delay: 0.3)

                        // Stats section - compact glowy design
                        progressSection
                            .cardEntry(delay: 0.4)

                        // Additional progress info at bottom
                        additionalProgressSection
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
            // Settings button in top right corner - smaller
            HStack {
                Spacer()
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.15))
                                .shadow(color: .white.opacity(0.3), radius: 6, x: 0, y: 0)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 5)
            
            // Centered greeting section - more compact
            VStack(spacing: 4) {
                Text(greetingMessage)
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundColor(.secondary)

                Text(profileManager.currentProfile?.name ?? "")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .shadow(color: .blue.opacity(0.2), radius: 4, x: 0, y: 2)

                Text("Comment vous sentez-vous aujourd'hui ?")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .opacity(0.8)
            }
            .multilineTextAlignment(.center)
        }
        .padding(.top, 10)
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
        VStack(spacing: 8) {
            Text("Respirez, vous êtes exactement là où vous devez être.")
                .font(.title3)
                .fontWeight(.medium)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .lineLimit(2)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.blue.opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .shadow(color: .blue.opacity(0.1), radius: 6, x: 0, y: 3)
        }
    }
    
    private var quickBreathingButton: some View {
        Button(action: { showingEmergencyView = true }) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundColor(.white)

                Text("Urgence / Crise de panique")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
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
            .shadow(color: .red.opacity(0.6), radius: 12, x: 0, y: 6)
            .shadow(color: .red.opacity(0.4), radius: 20, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var progressSection: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Text("Votre progression")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }

            // Single row to prevent scrolling - compact glowy stats
            HStack(spacing: 16) {
                StatGlass(
                    title: "Humeur",
                    value: moodViewModel.recentMoodEntries.isEmpty ? "--" : String(format: "%.1f", averageMood()),
                    subtitle: moodViewModel.recentMoodEntries.isEmpty ? "" : "/10",
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
    
    private var additionalProgressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Text("Cette semaine")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }

            HStack(spacing: 16) {
                AdditionalStatGlass(
                    title: "Exercice",
                    value: "\(breathingViewModel.totalMinutesThisWeek)",
                    subtitle: "minutes",
                    color: .cyan,
                    icon: "clock.fill"
                )

                AdditionalStatGlass(
                    title: "Journal",
                    value: "\(moodViewModel.recentMoodEntries.count)",
                    subtitle: "entrées",
                    color: .purple,
                    icon: "book.fill"
                )
            }
        }
    }

    // Lance les animations de fond pour créer une atmosphère apaisante
    // La respiration de fond aide à induire un état de calme chez l'utilisateur
    private func startAnimations() {
        // Animation de respiration très lente en arrière-plan (plus douce)
        withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
            breathingScale = 1.15
            breathingOpacity = 0.4
        }

        // Animation d'apparition progressive des éléments
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            contentOffset = 0
        }
    }
    
    private func averageMood() -> Double {
        let recentEntries = moodViewModel.recentMoodEntries.prefix(7)
        guard !recentEntries.isEmpty else { return 0 }
        let sum = recentEntries.reduce(0) { $0 + $1.emotionIntensity }
        return Double(sum) / Double(recentEntries.count)
    }
    
}



struct StatGlass: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconForTitle(title))
                .font(.title2)
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
        .frame(maxWidth: .infinity, minHeight: 85)
        .background(
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.5),
                            color.opacity(0.3),
                            color.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 70
                    )
                )
                .blur(radius: 15)
                .scaleEffect(1.2)
        )
        .shadow(color: color.opacity(0.6), radius: 20, x: 0, y: 10)
        .shadow(color: color.opacity(0.4), radius: 30, x: 0, y: 0)
    }

    private func iconForTitle(_ title: String) -> String {
        switch title {
        case "Humeur": return "heart.fill"
        case "Série": return "flame.fill"
        case "Sessions": return "lungs.fill"
        default: return "chart.bar.fill"
        }
    }
}

struct AdditionalStatGlass: View {
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
        .frame(maxWidth: .infinity, minHeight: 85)
        .background(
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.5),
                            color.opacity(0.3),
                            color.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 70
                    )
                )
                .blur(radius: 15)
                .scaleEffect(1.2)
        )
        .shadow(color: color.opacity(0.6), radius: 20, x: 0, y: 10)
        .shadow(color: color.opacity(0.4), radius: 30, x: 0, y: 0)
    }
}

#Preview {
    BeautifulDashboardView()
        .environmentObject(MoodViewModel())
        .environmentObject(BreathingViewModel())
}