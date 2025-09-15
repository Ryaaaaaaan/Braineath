//
//  DashboardView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var moodViewModel = MoodViewModel()
    @StateObject private var breathingViewModel = BreathingViewModel()
    @State private var showingEmergencyView = false
    @State private var showingQuickBreathing = false
    @State private var currentQuote: String = ""
    
    private let motivationalQuotes = [
        "Chaque respiration, un nouveau départ.",
        "Vos émotions passent, votre force reste.",
        "La paix commence par un souffle.",
        "Vous êtes plus fort que vos pensées.",
        "Chaque pas compte sur votre chemin.",
        "Prenez soin de vous aujourd'hui.",
        "Votre mental mérite votre attention.",
        "Les tempêtes passent, vous demeurez.",
        "Respirez, vous êtes à votre place.",
        "Votre bien-être est un investissement."
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 12) {
                    // Espace pour header
                    Spacer(minLength: 15)
                    
                    // Header avec accès rapide urgence
                    headerSection
                
                    // Citation motivante du jour
                    quoteSection
                
                    // Résumé rapide humeur (condensé)
                    compactMoodSection
                
                    // Actions rapides (condensé)
                    compactQuickActionsSection
                
                    // Insights (condensé)
                    compactInsightsSection
                
                    Spacer(minLength: 10)
                }
                .padding(.horizontal)
                .refreshable {
                    refreshData()
                }
                
                // Header blurred  
                blurredHeader
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingEmergencyView) {
            EmergencyModeView()
        }
        .sheet(isPresented: $showingQuickBreathing) {
            QuickBreathingView()
                .environmentObject(breathingViewModel)
        }
        .onAppear {
            loadRandomQuote()
            moodViewModel.loadRecentMoods()
            breathingViewModel.loadRecentSessions()
        }
    }
    
    private var blurredHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                
                // Bouton SOS d'urgence - design clair et reconnaissable avec effet glowy
                Button(action: { showingEmergencyView = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("SOS")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
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
                            .shadow(color: .red.opacity(0.8), radius: 15, x: 0, y: 0)
                            .shadow(color: .red.opacity(0.6), radius: 25, x: 0, y: 0)
                            .overlay(
                                Capsule()
                                    .stroke(Color.red.opacity(0.7), lineWidth: 1)
                                    .blur(radius: 2)
                            )
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            
            // Gradient de fondu vers le bas uniquement
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(.systemBackground).opacity(0.7), location: 0),
                    .init(color: Color.clear, location: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 30)
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Bonjour")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text(greetingMessage)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
    
    private var quoteSection: some View {
        VStack(spacing: 8) {
            Text(currentQuote)
                .font(.title3)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal)
        }
    }
    
    private var moodSummarySection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                Text("Humeur récente")
                    .font(.headline)
                Spacer()
                
            }
            
            if moodViewModel.recentMoodEntries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("Commencez votre suivi émotionnel")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    NavigationLink {
                        MoodJournalView().environmentObject(moodViewModel)
                    } label: {
                        Text("Première entrée")
                            .font(.caption)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(moodViewModel.recentMoodEntries.prefix(5), id: \.id) { entry in
                            MoodEntryCard(entry: entry)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var breathingStatsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lungs.fill")
                    .foregroundColor(.green)
                Text("Respiration")
                    .font(.headline)
                Spacer()
                
                NavigationLink("Exercices", destination: BreathingView().environmentObject(breathingViewModel))
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            HStack(spacing: 20) {
                CompactStatCard(
                    title: "Cette semaine",
                    value: "\(breathingViewModel.totalMinutesThisWeek) min",
                    icon: "clock.fill",
                    color: .green
                )
                
                CompactStatCard(
                    title: "Série actuelle",
                    value: "\(breathingViewModel.streakDays) jours",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Actions rapides")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                QuickActionCard(
                    title: "Respiration 2min",
                    subtitle: "Calme rapide",
                    icon: "lungs.fill",
                    color: .green
                ) {
                    showingQuickBreathing = true
                }
                
                QuickActionCard(
                    title: "Noter mon humeur",
                    subtitle: "Comment ça va ?",
                    icon: "heart.fill",
                    color: .pink
                ) {
                    // Navigation vers mood journal
                }
                
                QuickActionCard(
                    title: "Gratitude",
                    subtitle: "Mercis d'aujourd'hui",
                    icon: "hands.sparkles.fill",
                    color: .purple
                ) {
                    // Navigation vers gratitude
                }
                
                QuickActionCard(
                    title: "Pensée rationnelle",
                    subtitle: "Restructurer",
                    icon: "brain.head.profile.fill",
                    color: .blue
                ) {
                    // Navigation vers thought record
                }
            }
        }
    }
    
    private var compactMoodSection: some View {
        HStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .foregroundColor(.pink)
                .font(.title3)
            
            if moodViewModel.recentMoodEntries.isEmpty {
                Text("Ajouter une humeur")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(moodViewModel.recentMoodEntries.prefix(3), id: \.id) { entry in
                            MoodEntryCard(entry: entry)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
    
    private var compactQuickActionsSection: some View {
        HStack(spacing: 8) {
            QuickActionCompact(icon: "lungs.fill", color: .green) {
                showingQuickBreathing = true
            }
            QuickActionCompact(icon: "heart.fill", color: .pink) {
                // Navigation vers mood journal
            }
            QuickActionCompact(icon: "hands.sparkles.fill", color: .purple) {
                // Navigation vers gratitude
            }
            QuickActionCompact(icon: "brain.head.profile.fill", color: .blue) {
                // Navigation vers thought record
            }
        }
    }
    
    private var compactInsightsSection: some View {
        Group {
            if !moodViewModel.getEmotionalInsights().isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text(moodViewModel.getEmotionalInsights().first ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var insightsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Insights")
                    .font(.headline)
                Spacer()
            }
            
            let insights = moodViewModel.getEmotionalInsights().prefix(2)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(insights.enumerated()), id: \.0) { index, insight in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        Text(insight)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Bon matin !"
        case 12..<17:
            return "Bon après-midi !"
        case 17..<22:
            return "Bonne soirée !"
        default:
            return "Bonne nuit !"
        }
    }
    
    private func loadRandomQuote() {
        currentQuote = motivationalQuotes.randomElement() ?? motivationalQuotes[0]
    }
    
    private func refreshData() {
        loadRandomQuote()
        moodViewModel.loadRecentMoods()
        moodViewModel.loadMoodTrends()
        breathingViewModel.loadRecentSessions()
        breathingViewModel.calculateStats()
    }
}

// Composants auxiliaires
struct MoodEntryCard: View {
    let entry: MoodEntry
    
    var body: some View {
        VStack(spacing: 6) {
            Text(entry.primaryEmotion ?? "?")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("\(entry.emotionIntensity)/10")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
    }
}


struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickActionCompact: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DashboardView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}