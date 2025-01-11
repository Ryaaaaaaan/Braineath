//
//  ThoughtRecordView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct ThoughtRecordView: View {
    @StateObject private var viewModel = ThoughtRecordViewModel()
    @State private var showingNewRecord = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Introduction à la TCC
                    introSection
                    
                    // Progression de l'utilisateur
                    progressSection
                    
                    // Distorsions cognitives communes
                    commonDistortionsSection
                    
                    // Enregistrements récents
                    recentRecordsSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Restructuration cognitive")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewRecord = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingNewRecord) {
                NewThoughtRecordView()
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            viewModel.loadRecentRecords()
        }
    }
    
    private var introSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile.fill")
                    .font(.title)
                    .foregroundColor(.purple)
                
                VStack(alignment: .leading) {
                    Text("Thérapie Cognitive Comportementale")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Outil de restructuration des pensées")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text("Identifiez et transformez les pensées négatives automatiques en pensées plus équilibrées et réalistes.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .padding()
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Votre progression")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 20) {
                ProgressCard(
                    title: "Enregistrements",
                    value: "\(viewModel.thoughtRecords.count)",
                    color: .blue,
                    icon: "brain.head.profile.fill"
                )
                
                ProgressCard(
                    title: "Cette semaine",
                    value: "\(viewModel.recordsThisWeek)",
                    color: .green,
                    icon: "calendar.badge.clock"
                )
                
                ProgressCard(
                    title: "Distorsions identifiées",
                    value: "\(viewModel.identifiedDistortions)",
                    color: .orange,
                    icon: "lightbulb.fill"
                )
            }
        }
    }
    
    private var commonDistortionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Distorsions cognitives courantes")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Array(CognitiveDistortion.allCases.prefix(6)), id: \.self) { distortion in
                    DistortionCard(distortion: distortion)
                }
            }
            
            NavigationLink("Voir toutes les distorsions") {
                DistortionsGuideView()
            }
            .font(.caption)
            .foregroundColor(.blue)
            .padding(.top, 8)
        }
    }
    
    private var recentRecordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.rectangle.fill")
                    .foregroundColor(.blue)
                Text("Enregistrements récents")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            if viewModel.thoughtRecords.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("Commencez votre premier enregistrement")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("La restructuration cognitive est un outil puissant pour transformer les pensées négatives.")
                        .font(.caption)
                        .foregroundColor(.tertiary)
                        .multilineTextAlignment(.center)
                    
                    Button("Créer un enregistrement") {
                        showingNewRecord = true
                    }
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.thoughtRecords, id: \.id) { record in
                        ThoughtRecordRow(record: record)
                    }
                }
            }
        }
    }
}

// Composants auxiliaires
struct ProgressCard: View {
    let title: String
    let value: String
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

struct DistortionCard: View {
    let distortion: CognitiveDistortion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(distortion.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(shortDescription)
                .font(.caption2)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.quaternarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var shortDescription: String {
        let descriptions: [CognitiveDistortion: String] = [
            .allOrNothing: "Voir en noir ou blanc",
            .overgeneralization: "Généraliser un événement",
            .mentalFilter: "Focus sur le négatif",
            .discountingPositive: "Ignorer le positif",
            .jumpingToConclusions: "Conclusions hâtives",
            .magnification: "Exagérer les problèmes",
            .emotionalReasoning: "Émotions = réalité",
            .shouldStatements: "Tyrannies du 'il faut'",
            .labeling: "Étiquetage négatif",
            .personalization: "Tout est ma faute"
        ]
        return descriptions[distortion] ?? distortion.description
    }
}

struct ThoughtRecordRow: View {
    let record: ThoughtRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Situation et pensée automatique
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "exclamationmark.bubble.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    
                    Text("Situation:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let date = record.date {
                        Text(date, style: .relative)
                            .font(.caption2)
                            .foregroundColor(.tertiary)
                    }
                }
                
                Text(record.situation ?? "Situation non spécifiée")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "thought.bubble.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text("Pensée automatique:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                Text(record.automaticThought ?? "")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .italic()
            }
            
            // Émotions avant/après si disponible
            HStack(spacing: 16) {
                EmotionIndicator(
                    label: "Avant:",
                    emotion: record.emotionBefore ?? "",
                    intensity: Int(record.intensityBefore),
                    color: .red
                )
                
                if let emotionAfter = record.emotionAfter,
                   !emotionAfter.isEmpty {
                    EmotionIndicator(
                        label: "Après:",
                        emotion: emotionAfter,
                        intensity: Int(record.intensityAfter),
                        color: .green
                    )
                }
            }
            
            // Pensée équilibrée si disponible
            if let balancedThought = record.balancedThought,
               !balancedThought.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text("Pensée équilibrée:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(balancedThought)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.leading, 16)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EmotionIndicator: View {
    let label: String
    let emotion: String
    let intensity: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Text(emotion)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("(\(intensity)/10)")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.2))
                    .foregroundColor(color)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    ThoughtRecordView()
}