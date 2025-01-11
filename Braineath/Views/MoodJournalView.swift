//
//  MoodJournalView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct MoodJournalView: View {
    @EnvironmentObject var viewModel: MoodViewModel
    @State private var showingNewEntry = false
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "7j"
        case month = "30j"
        case all = "Tout"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Sélecteur de période
                    timeRangeSelector
                    
                    // Graphique des tendances
                    moodTrendsChart
                    
                    // Résumé de la semaine
                    weekSummary
                    
                    // Émotions suggérées
                    if !viewModel.suggestedEmotions.isEmpty {
                        suggestedEmotionsSection
                    }
                    
                    // Liste des entrées récentes
                    recentEntriesSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Journal d'humeur")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewEntry = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                NewMoodEntryView()
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            viewModel.loadRecentMoods()
            viewModel.loadMoodTrends()
        }
    }
    
    private var timeRangeSelector: some View {
        HStack {
            Text("Période")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Picker("Période", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 180)
        }
    }
    
    private var moodTrendsChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("Tendances d'humeur")
                    .font(.headline)
                Spacer()
            }
            
            if viewModel.moodTrends.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("Pas assez de données")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Ajoutez quelques entrées pour voir vos tendances")
                        .font(.caption)
                        .foregroundColor(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                // Graphique simple avec SwiftUI (sans Charts car pas disponible partout)
                SimpleMoodChart(trends: viewModel.moodTrends)
                    .frame(height: 150)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    private var weekSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.green)
                Text("Résumé de la semaine")
                    .font(.headline)
                Spacer()
            }
            
            let recentWeek = Array(viewModel.recentMoodEntries.prefix(7))
            
            if recentWeek.isEmpty {
                Text("Aucune donnée cette semaine")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    SummaryCard(
                        title: "Humeur moyenne",
                        value: String(format: "%.1f/10", averageIntensity(from: recentWeek)),
                        icon: "heart.fill",
                        color: colorForAverage(averageIntensity(from: recentWeek))
                    )
                    
                    SummaryCard(
                        title: "Énergie moyenne",
                        value: String(format: "%.1f/10", averageEnergy(from: recentWeek)),
                        icon: "bolt.fill",
                        color: .orange
                    )
                    
                    SummaryCard(
                        title: "Stress moyen",
                        value: String(format: "%.1f/10", averageStress(from: recentWeek)),
                        icon: "exclamationmark.triangle.fill",
                        color: colorForStress(averageStress(from: recentWeek))
                    )
                }
            }
        }
    }
    
    private var suggestedEmotionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("Émotions suggérées")
                    .font(.headline)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.suggestedEmotions, id: \.id) { emotion in
                        EmotionSuggestionCard(emotion: emotion) {
                            viewModel.selectedEmotion = emotion
                            showingNewEntry = true
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .foregroundColor(.blue)
                Text("Entrées récentes")
                    .font(.headline)
                Spacer()
            }
            
            if viewModel.recentMoodEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("Aucune entrée pour le moment")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Ajouter votre première entrée") {
                        showingNewEntry = true
                    }
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.recentMoodEntries, id: \.id) { entry in
                        MoodEntryRow(entry: entry, viewModel: viewModel)
                    }
                }
            }
        }
    }
    
    // Fonctions utilitaires
    private func averageIntensity(from entries: [MoodEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        let sum = entries.reduce(0) { $0 + Double($1.emotionIntensity) }
        return sum / Double(entries.count)
    }
    
    private func averageEnergy(from entries: [MoodEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        let sum = entries.reduce(0) { $0 + Double($1.energyLevel) }
        return sum / Double(entries.count)
    }
    
    private func averageStress(from entries: [MoodEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        let sum = entries.reduce(0) { $0 + Double($1.stressLevel) }
        return sum / Double(entries.count)
    }
    
    private func colorForAverage(_ average: Double) -> Color {
        switch average {
        case 8...:
            return .green
        case 6..<8:
            return .yellow
        case 4..<6:
            return .orange
        default:
            return .red
        }
    }
    
    private func colorForStress(_ stress: Double) -> Color {
        switch stress {
        case 7...:
            return .red
        case 4..<7:
            return .orange
        default:
            return .green
        }
    }
}

// Composants auxiliaires
struct SimpleMoodChart: View {
    let trends: [(Date, Double)]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width - 40
            let height = geometry.size.height - 40
            
            ZStack {
                // Grille de fond
                Path { path in
                    for i in 1..<5 {
                        let y = height * CGFloat(i) / 5
                        path.move(to: CGPoint(x: 20, y: 20 + y))
                        path.addLine(to: CGPoint(x: width + 20, y: 20 + y))
                    }
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                
                // Ligne de tendance
                if trends.count > 1 {
                    Path { path in
                        for (index, (_, mood)) in trends.enumerated() {
                            let x = 20 + (width * CGFloat(index) / CGFloat(trends.count - 1))
                            let y = 20 + height - (height * CGFloat(mood) / 10)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                }
                
                // Points de données
                ForEach(trends.indices, id: \.self) { index in
                    let (_, mood) = trends[index]
                    let x = 20 + (width * CGFloat(index) / CGFloat(max(trends.count - 1, 1)))
                    let y = 20 + height - (height * CGFloat(mood) / 10)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                        .position(x: x, y: y)
                }
            }
        }
        .padding()
    }
}

struct SummaryCard: View {
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
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EmotionSuggestionCard: View {
    let emotion: Emotion
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: emotion.icon)
                    .font(.title2)
                    .foregroundColor(Color(UIColor(hex: emotion.color) ?? .systemBlue))
                
                Text(emotion.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MoodEntryRow: View {
    let entry: MoodEntry
    let viewModel: MoodViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Icône d'émotion
            if let emotion = Emotion.allEmotions.first(where: { $0.name == entry.primaryEmotion }) {
                Image(systemName: emotion.icon)
                    .font(.title2)
                    .foregroundColor(viewModel.colorForEmotion(emotion.name))
                    .frame(width: 30)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.primaryEmotion ?? "Inconnu")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(entry.emotionIntensity)/10")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(viewModel.colorForEmotion(entry.primaryEmotion ?? "").opacity(0.2))
                        )
                        .foregroundColor(viewModel.colorForEmotion(entry.primaryEmotion ?? ""))
                }
                
                if let date = entry.date {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.tertiary)
                        .lineLimit(2)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let moodViewModel = MoodViewModel()
    return MoodJournalView()
        .environmentObject(moodViewModel)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}