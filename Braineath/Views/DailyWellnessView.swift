//
//  DailyWellnessView.swift
//  Braineath
//
//  Created by Ryan Zemri on 15/09/2025.
//

import SwiftUI

struct DailyWellnessView: View {
    @StateObject private var wellnessViewModel = WellnessViewModel()
    @State private var showingDetail = false
    
    var body: some View {
        GeometryReader { geometry in
            let compactMode = geometry.size.height < 700
            let contentHeight = calculateContentHeight(compact: compactMode)
            let needsScroll = contentHeight > (geometry.size.height - 100) // Safe area buffer
            
            ZStack {
                // Background with blur effect
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.mint.opacity(0.1),
                        Color.teal.opacity(0.05),
                        Color.cyan.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                )
                .ignoresSafeArea()
                
                // Conditional scrolling
                if needsScroll {
                    ScrollView(.vertical, showsIndicators: false) {
                        contentView(compact: compactMode)
                    }
                } else {
                    VStack {
                        contentView(compact: compactMode)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Bien-être quotidien")
        .navigationBarTitleDisplayMode(.automatic)
        .sheet(isPresented: $showingDetail) {
            WellnessDetailView()
                .environmentObject(wellnessViewModel)
        }
    }
    
    private func contentView(compact: Bool) -> some View {
        VStack(spacing: compact ? 16 : 24) {
            // Today's Wellness Score
            todaysWellnessCard(compact: compact)
            
            // Quick Check-in Sections
            quickCheckInSection(compact: compact)
            
            // Smart Suggestions (only if not empty and compact)
            smartSuggestionsSection(compact: compact)
        }
        .padding(.horizontal)
        .padding(.top, compact ? 8 : 16)
    }
    
    private func calculateContentHeight(compact: Bool) -> CGFloat {
        // Rough calculation of content height
        let cardHeight: CGFloat = compact ? 120 : 140
        let checkInHeight: CGFloat = compact ? 200 : 250
        let suggestionsHeight: CGFloat = compact ? 80 : 120
        let spacing: CGFloat = compact ? 16 : 24
        let padding: CGFloat = 50
        
        return cardHeight + checkInHeight + suggestionsHeight + (spacing * 3) + padding
    }
    
    private func shortenMessage(_ message: String) -> String {
        if message.count > 40 {
            return String(message.prefix(37)) + "..."
        }
        return message
    }
    
    private func todaysWellnessCard(compact: Bool) -> some View {
        VStack(spacing: compact ? 12 : 16) {
            HStack {
                VStack(alignment: .leading, spacing: compact ? 4 : 8) {
                    Text("Score de bien-être")
                        .font(compact ? .subheadline : .headline)
                        .foregroundColor(.primary)
                    
                    Text("Aujourd'hui")
                        .font(compact ? .caption : .subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: compact ? 2 : 4) {
                    Text("\(wellnessViewModel.todaysEntry?.wellnessScore ?? 0)")
                        .font(.system(size: compact ? 28 : 36, weight: .bold, design: .rounded))
                        .foregroundColor(wellnessViewModel.todaysEntry?.wellnessLevel.color ?? .gray)
                    
                    Text("/100")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Wellness Level Indicator
            if let todaysEntry = wellnessViewModel.todaysEntry {
                HStack(spacing: compact ? 8 : 12) {
                    Image(systemName: todaysEntry.wellnessLevel.icon)
                        .foregroundColor(todaysEntry.wellnessLevel.color)
                        .font(compact ? .callout : .title2)
                    
                    VStack(alignment: .leading, spacing: compact ? 2 : 4) {
                        Text(todaysEntry.wellnessLevel.rawValue)
                            .font(compact ? .caption : .subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(compact ? shortenMessage(todaysEntry.wellnessLevel.message) : todaysEntry.wellnessLevel.message)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(compact ? 12 : 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: compact ? 5 : 10, x: 0, y: compact ? 2 : 5)
        )
    }
    
    private func quickCheckInSection(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: compact ? 12 : 16) {
            Text("Check-in rapide")
                .font(compact ? .subheadline : .headline)
                .foregroundColor(.primary)
            
            VStack(spacing: compact ? 8 : 12) {
                WellnessSlider(
                    title: "Humeur",
                    icon: "heart.fill",
                    color: .pink,
                    compact: compact,
                    value: Binding(
                        get: { wellnessViewModel.todaysEntry?.overallMood ?? 5 },
                        set: { wellnessViewModel.updateMood($0) }
                    )
                )
                
                WellnessSlider(
                    title: "Énergie",
                    icon: "bolt.fill",
                    color: .orange,
                    compact: compact,
                    value: Binding(
                        get: { wellnessViewModel.todaysEntry?.energyLevel ?? 5 },
                        set: { wellnessViewModel.updateEnergyLevel($0) }
                    )
                )
                
                WellnessSlider(
                    title: "Calme",
                    icon: "leaf.fill",
                    color: .green,
                    compact: compact,
                    value: Binding(
                        get: { wellnessViewModel.todaysEntry?.stressLevel ?? 5 },
                        set: { wellnessViewModel.updateStressLevel($0) }
                    )
                )
                
                WellnessSlider(
                    title: "Sommeil",
                    icon: "bed.double.fill",
                    color: .purple,
                    compact: compact,
                    value: Binding(
                        get: { wellnessViewModel.todaysEntry?.sleepQuality ?? 5 },
                        set: { wellnessViewModel.updateSleepQuality($0) }
                    )
                )
            }
        }
        .padding(compact ? 12 : 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private func smartSuggestionsSection(compact: Bool) -> some View {
        let suggestions = wellnessViewModel.getSmartSuggestions()
        
        return Group {
            if !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: compact ? 8 : 12) {
                    Text("Suggestions personnalisées")
                        .font(compact ? .subheadline : .headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: compact ? 6 : 8) {
                        ForEach(suggestions.prefix(compact ? 2 : 3), id: \.self) { suggestion in
                            HStack(spacing: compact ? 8 : 12) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                    .font(compact ? .callout : .title3)
                                
                                Text(suggestion)
                                    .font(compact ? .caption : .subheadline)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(compact ? 2 : nil)
                                
                                Spacer()
                            }
                            .padding(.vertical, compact ? 4 : 8)
                        }
                    }
                }
                .padding(compact ? 12 : 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
            }
        }
    }
    
    private func weeklySummaryButton(compact: Bool) -> some View {
        Button(action: { showingDetail = true }) {
            HStack(spacing: compact ? 8 : 12) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(compact ? .callout : .title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: compact ? 2 : 4) {
                    Text("Résumé hebdomadaire")
                        .font(compact ? .caption : .subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Voir vos tendances et analyses")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(compact ? .caption : .callout)
            }
            .padding(compact ? 12 : 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WellnessSlider: View {
    let title: String
    let icon: String
    let color: Color
    let compact: Bool
    @Binding var value: Int
    
    var body: some View {
        VStack(spacing: compact ? 6 : 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(compact ? .callout : .title3)
                
                Text(title)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(value)/10")
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            HStack(spacing: compact ? 2 : 4) {
                ForEach(1...10, id: \.self) { level in
                    Circle()
                        .fill(level <= value ? color : Color(.systemGray5))
                        .frame(width: compact ? 20 : 24, height: compact ? 20 : 24)
                        .scaleEffect(level <= value ? (compact ? 1.05 : 1.1) : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: value)
                        .onTapGesture {
                            value = level
                            AudioManager.shared.playHapticFeedback(style: .light)
                        }
                }
            }
        }
    }
}

struct WellnessDetailView: View {
    @EnvironmentObject var wellnessViewModel: WellnessViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.mint.opacity(0.1),
                        Color.teal.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Weekly Average
                    weeklyAverageCard
                    
                    // Insights
                    insightsSection
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Résumé hebdomadaire")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
    
    private var weeklyAverageCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Moyenne de la semaine")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(String(format: "%.1f", wellnessViewModel.getAverageWellnessScore()))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
            }
            
            // Trend indicator
            let trend = wellnessViewModel.getMoodTrend()
            HStack(spacing: 8) {
                Image(systemName: trend > 0 ? "arrow.up.right" : trend < 0 ? "arrow.down.right" : "arrow.right")
                    .foregroundColor(trend > 0 ? .green : trend < 0 ? .red : .orange)
                
                Text(trend > 0 ? "Tendance positive" : trend < 0 ? "Tendance négative" : "Stable")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights personnalisés")
                .font(.headline)
                .foregroundColor(.primary)
            
            if wellnessViewModel.insights.isEmpty {
                Text("Continuez à enregistrer vos données pour recevoir des insights personnalisés.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(wellnessViewModel.insights.prefix(3), id: \.title) { insight in
                        InsightCard(insight: insight)
                    }
                }
            }
        }
    }
}

struct InsightCard: View {
    let insight: WellnessInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: insight.category.icon)
                    .foregroundColor(insight.category.color)
                    .font(.title2)
                
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(insight.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("💡 \(insight.actionable)")
                .font(.caption)
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(insight.category.color.opacity(0.1))
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    DailyWellnessView()
}