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
        ZStack {
            // Background with blur effect for consistency
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.1),
                    Color.blue.opacity(0.05),
                    Color.indigo.opacity(0.05)
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
            
            VStack(spacing: 24) {
                // Introduction à la TCC
                introSection

                // Progression de l'utilisateur
                progressSection

                // Enregistrements récents
                recentRecordsSection

                Spacer(minLength: 20)
            }
            .padding()
        }
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
        .onAppear {
            viewModel.loadRecentRecords()
        }
    }
    
    private var introSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile.fill")
                    .font(.title2)
                    .foregroundColor(.purple)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Restructuration cognitive")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Transformez vos pensées automatiques")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Progression")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }

            HStack(spacing: 16) {
                CompactProgressCard(
                    title: "Enregistrements",
                    value: "\(viewModel.thoughtRecords.count)",
                    color: .blue
                )

                CompactProgressCard(
                    title: "Cette semaine",
                    value: "\(viewModel.recordsThisWeek)",
                    color: .green
                )

                CompactProgressCard(
                    title: "Distorsions",
                    value: "\(viewModel.identifiedDistortions)",
                    color: .orange
                )
            }
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
                        .foregroundColor(.secondary)
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
struct CompactProgressCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

struct SimpleDistortionCard: View {
    let distortion: CognitiveDistortion

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(distortion.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(2)

            Text(shortDescription)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
        .padding(8)
        .background(Color(.quaternarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var shortDescription: String {
        let descriptions: [CognitiveDistortion: String] = [
            .allOrNothing: "Tout ou rien",
            .overgeneralization: "Généralisation",
            .mentalFilter: "Filtre mental",
            .discountingPositive: "Ignorer le positif",
            .jumpingToConclusions: "Conclusions hâtives",
            .magnification: "Exagération",
            .emotionalReasoning: "Émotions = réalité",
            .shouldStatements: "Il faut que...",
            .labeling: "Étiquetage",
            .personalization: "Personnalisation"
        ]
        return descriptions[distortion] ?? ""
    }
}


struct ThoughtRecordRow: View {
    let record: ThoughtRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // En-tête avec date
            HStack {
                Text(record.situation ?? "Situation")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer()

                if let date = record.date {
                    Text(date, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Pensée automatique
            Text(record.automaticThought ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
                .lineLimit(2)

            // Émotions en ligne
            HStack(spacing: 12) {
                if let emotionBefore = record.emotionBefore, !emotionBefore.isEmpty {
                    HStack(spacing: 4) {
                        Text(emotionBefore)
                            .font(.caption2)
                            .foregroundColor(.red)
                        Text("\(Int(record.intensityBefore))/10")
                            .font(.caption2)
                            .foregroundColor(.red)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }

                if let emotionAfter = record.emotionAfter, !emotionAfter.isEmpty {
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Text(emotionAfter)
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text("\(Int(record.intensityAfter))/10")
                            .font(.caption2)
                            .foregroundColor(.green)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.green.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }

                Spacer()
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}


#Preview {
    ThoughtRecordView()
}