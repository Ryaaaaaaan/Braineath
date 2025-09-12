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
    
    @State private var showingQuickBreathing = false
    @State private var showingEmergencyView = false
    @State private var currentQuoteIndex = 0
    
    // Animation states
    @State private var breathingScale: CGFloat = 1.0
    @State private var breathingOpacity: Double = 0.3
    @State private var quoteOpacity: Double = 1.0
    @State private var contentOffset: CGFloat = 0
    
    private var currentQuote: String {
        let quotes = profileManager.getPersonalizedQuotes()
        guard !quotes.isEmpty else { return "Respirez, vous êtes exactement là où vous devez être." }
        
        // Change quote based on current minute
        let minute = Calendar.current.component(.minute, from: Date())
        let index = minute % quotes.count
        return quotes[index]
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated breathing background
                breathingBackground
                
                // Main content
                VStack(spacing: 0) {
                    // Header section
                    Spacer(minLength: geometry.safeAreaInsets.top + 20)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 30) {
                            // Welcome section with greeting
                            welcomeSection
                            
                            // Glowy quote section
                            quoteSection
                            
                            // Quick breathing button
                            quickBreathingButton
                            
                            // Compact stats if available
                            if !moodViewModel.recentMoodEntries.isEmpty {
                                compactStatsSection
                            }
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .offset(y: contentOffset)
                    }
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
    }
    
    private var breathingBackground: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.05),
                    Color.pink.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated breathing circles
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(breathingOpacity * 0.3),
                                Color.blue.opacity(breathingOpacity * 0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 200
                        )
                    )
                    .frame(width: 300 + CGFloat(index * 100), height: 300 + CGFloat(index * 100))
                    .scaleEffect(breathingScale + CGFloat(index) * 0.1)
                    .opacity(breathingOpacity - Double(index) * 0.1)
                    .position(x: UIScreen.main.bounds.width * (0.3 + Double(index) * 0.2), 
                             y: UIScreen.main.bounds.height * (0.4 + Double(index) * 0.1))
                    .blur(radius: 5 + CGFloat(index * 2))
            }
        }
    }
    
    
    private var welcomeSection: some View {
        VStack(spacing: 12) {
            // Greeting with user name
            VStack(spacing: 6) {
                VStack(spacing: 4) {
                    Text(greetingMessage)
                        .font(.system(size: 24, weight: .light, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text(profileManager.currentProfile?.name ?? "")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
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
                HStack(spacing: 30) {
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
                }
                
                HStack(spacing: 30) {
                    StatGlass(
                        title: "Sessions",
                        value: "\(breathingViewModel.totalSessions)",
                        subtitle: "total",
                        color: .green
                    )
                    
                    StatGlass(
                        title: "Minutes",
                        value: "\(breathingViewModel.totalMinutes)",
                        subtitle: "total",
                        color: .blue
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
    
    private func startAnimations() {
        // Breathing animation
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            breathingScale = 1.3
            breathingOpacity = 0.6
        }
        
        // Quote opacity stays constant
        quoteOpacity = 1.0
    }
    
    private func averageMood() -> Double {
        let recentEntries = moodViewModel.recentMoodEntries.prefix(7)
        guard !recentEntries.isEmpty else { return 0 }
        let sum = recentEntries.reduce(0) { $0 + $1.emotionIntensity }
        return Double(sum) / Double(recentEntries.count)
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
        .frame(width: 130, height: 90)
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