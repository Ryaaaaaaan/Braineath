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
        "Chaque respiration est une nouvelle chance de recommencer.",
        "Vos émotions sont des visiteurs, pas des résidents permanents.",
        "La paix intérieure commence par une respiration consciente.",
        "Vous êtes plus fort que vos pensées les plus difficiles.",
        "Chaque petit pas compte dans votre parcours de bien-être.",
        "Aujourd'hui est une opportunité de prendre soin de vous.",
        "Votre mental mérite la même attention que votre corps.",
        "Les tempêtes passent, votre force demeure.",
        "Respirez profondément, vous êtes exactement là où vous devez être.",
        "Votre bien-être mental est un investissement, pas une dépense."
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header avec accès rapide urgence
                    headerSection
                    
                    // Citation motivante du jour
                    quoteSection
                    
                    // Résumé rapide humeur
                    moodSummarySection
                    
                    // Statistiques respiration
                    breathingStatsSection
                    
                    // Actions rapides
                    quickActionsSection
                    
                    // Insights et tendances
                    insightsSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Braineath")
            .navigationBarTitleDisplayMode(.large)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .refreshable {
                refreshData()
            }
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
            
            // Bouton SOS/Urgence
            Button(action: { showingEmergencyView = true }) {
                VStack(spacing: 4) {
                    Image(systemName: "cross.case.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("SOS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.red, .pink]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
                .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    private var quoteSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "quote.bubble")
                    .foregroundColor(.blue)
                Text("Citation du jour")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Text(currentQuote)
                .font(.body)
                .italic()
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                )
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
                
                NavigationLink("Voir tout", destination: MoodJournalView().environmentObject(moodViewModel))
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            if moodViewModel.recentMoodEntries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("Commencez votre suivi émotionnel")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    NavigationLink("Ajouter une entrée", destination: MoodJournalView().environmentObject(moodViewModel)) {
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
                StatCard(
                    title: "Cette semaine",
                    value: "\(breathingViewModel.totalMinutesThisWeek) min",
                    icon: "clock.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Série actuelle",
                    value: "\(breathingViewModel.streakDays) jours",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Actions rapides")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
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
                    subtitle: "3 mercis d'aujourd'hui",
                    icon: "hands.sparkles.fill",
                    color: .purple
                ) {
                    // Navigation vers gratitude
                }
                
                QuickActionCard(
                    title: "Pensée rationnelle",
                    subtitle: "Restructurer une pensée",
                    icon: "brain.head.profile.fill",
                    color: .blue
                ) {
                    // Navigation vers thought record
                }
            }
        }
    }
    
    private var insightsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Insights")
                    .font(.headline)
                Spacer()
            }
            
            let insights = moodViewModel.getEmotionalInsights()
            
            ForEach(insights.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text(insights[index])
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
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
        VStack(spacing: 8) {
            Text(entry.primaryEmotion ?? "Inconnu")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("\(entry.emotionIntensity)/10")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if let date = entry.date {
                Text(date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.tertiary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DashboardView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}