//
//  DistortionsGuideView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct DistortionsGuideView: View {
    @State private var selectedDistortion: CognitiveDistortion?
    @State private var searchText = ""
    
    var filteredDistortions: [CognitiveDistortion] {
        if searchText.isEmpty {
            return CognitiveDistortion.allCases
        } else {
            return CognitiveDistortion.allCases.filter { distortion in
                distortion.rawValue.localizedCaseInsensitiveContains(searchText) ||
                distortion.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Barre de recherche
                searchBar
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Introduction
                        introductionSection
                        
                        // Liste des distorsions
                        ForEach(filteredDistortions, id: \.self) { distortion in
                            DistortionDetailCard(
                                distortion: distortion,
                                isExpanded: selectedDistortion == distortion
                            ) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    if selectedDistortion == distortion {
                                        selectedDistortion = nil
                                    } else {
                                        selectedDistortion = distortion
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Guide des distorsions")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Rechercher une distortion...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button("Effacer") {
                    searchText = ""
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
    }
    
    private var introductionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("À propos des distorsions cognitives")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Text("Les distorsions cognitives sont des patterns de pensée inexacts ou négatifs qui peuvent influencer nos émotions et comportements. Apprendre à les reconnaître est la première étape pour développer une pensée plus équilibrée.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.quaternarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text("\(CognitiveDistortion.allCases.count) distorsions courantes")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

struct DistortionDetailCard: View {
    let distortion: CognitiveDistortion
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header toujours visible
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(distortion.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text(distortion.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                // Contenu détaillé (visible quand étendu)
                if isExpanded {
                    VStack(alignment: .leading, spacing: 16) {
                        Divider()
                        
                        // Exemples
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exemples de pensées:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            
                            ForEach(getExamples(for: distortion), id: \.self) { example in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.orange)
                                    Text(example)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .italic()
                                }
                            }
                        }
                        
                        // Questions pour contrer
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Questions pour contrer cette distorsion:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                            
                            ForEach(getCounterQuestions(for: distortion), id: \.self) { question in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("?")
                                        .foregroundColor(.green)
                                        .fontWeight(.bold)
                                    Text(question)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // Reformulation suggérée
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Alternative plus équilibrée:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Text(getAlternative(for: distortion))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 16)
                                .italic()
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isExpanded ? Color(.secondarySystemBackground) : Color(.tertiarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isExpanded ? Color.purple.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
    
    private func getExamples(for distortion: CognitiveDistortion) -> [String] {
        switch distortion {
        case .allOrNothing:
            return [
                "Je rate toujours tout",
                "Si ce n'est pas parfait, c'est nul",
                "Je suis soit un succès, soit un échec"
            ]
        case .overgeneralization:
            return [
                "Personne ne m'aime jamais",
                "Je n'y arrive jamais",
                "Les gens sont toujours égoïstes"
            ]
        case .mentalFilter:
            return [
                "Seules les critiques comptent",
                "Tout va mal dans ma vie",
                "Je ne vois que mes erreurs"
            ]
        case .discountingPositive:
            return [
                "C'était juste de la chance",
                "N'importe qui aurait pu le faire",
                "Ce compliment n'est pas sincère"
            ]
        case .jumpingToConclusions:
            return [
                "Il pense sûrement que je suis stupide",
                "Je sais déjà que ça va mal se passer",
                "Elle ne répond pas, elle doit être fâchée"
            ]
        case .magnification:
            return [
                "C'est la pire chose qui pouvait arriver",
                "Ma vie est ruinée",
                "Cette erreur est catastrophique"
            ]
        case .emotionalReasoning:
            return [
                "Je me sens coupable, donc j'ai tort",
                "J'ai peur, donc c'est dangereux",
                "Je me sens nul, donc je ne vaux rien"
            ]
        case .shouldStatements:
            return [
                "Je devrais toujours être parfait",
                "Les gens devraient me comprendre",
                "Je ne dois jamais décevoir"
            ]
        case .labeling:
            return [
                "Je suis un raté",
                "Elle est méchante",
                "Je suis incapable"
            ]
        case .personalization:
            return [
                "C'est de ma faute si elle est triste",
                "Je suis responsable de son échec",
                "Ils parlent sûrement de moi"
            ]
        }
    }
    
    private func getCounterQuestions(for distortion: CognitiveDistortion) -> [String] {
        switch distortion {
        case .allOrNothing:
            return [
                "Y a-t-il des nuances dans cette situation ?",
                "Est-ce vraiment tout ou rien ?",
                "Que dirait un ami objectif ?"
            ]
        case .overgeneralization:
            return [
                "Est-ce vraiment toujours le cas ?",
                "Puis-je trouver des contre-exemples ?",
                "Un incident représente-t-il un pattern ?"
            ]
        case .mentalFilter:
            return [
                "Qu'est-ce que j'ignore de positif ?",
                "Y a-t-il d'autres aspects à considérer ?",
                "Que verrait quelqu'un d'autre ?"
            ]
        case .discountingPositive:
            return [
                "Pourquoi minimiser mes réussites ?",
                "Ce compliment était-il mérité ?",
                "Comment valoriser mes efforts ?"
            ]
        case .jumpingToConclusions:
            return [
                "Ai-je toutes les informations ?",
                "Quelles autres explications sont possibles ?",
                "Comment vérifier mes suppositions ?"
            ]
        case .magnification:
            return [
                "Quelle sera l'importance dans 5 ans ?",
                "Est-ce vraiment si grave ?",
                "Comment réagiraient mes proches ?"
            ]
        case .emotionalReasoning:
            return [
                "Mes émotions reflètent-elles les faits ?",
                "Que diraient les preuves objectives ?",
                "Comment séparer ressenti et réalité ?"
            ]
        case .shouldStatements:
            return [
                "Cette règle est-elle réaliste ?",
                "Que se passe-t-il si je remplace 'dois' par 'aimerais' ?",
                "D'où vient cette exigence ?"
            ]
        case .labeling:
            return [
                "Suis-je vraiment défini par cette action ?",
                "Comment décrire sans juger ?",
                "Quelles qualités ai-je aussi ?"
            ]
        case .personalization:
            return [
                "Quels autres facteurs ont joué ?",
                "Ai-je vraiment ce pouvoir ?",
                "Qu'est-ce qui ne dépend pas de moi ?"
            ]
        }
    }
    
    private func getAlternative(for distortion: CognitiveDistortion) -> String {
        switch distortion {
        case .allOrNothing:
            return "Je peux avoir des succès partiels et apprendre de mes erreurs. La perfection n'est pas nécessaire."
        case .overgeneralization:
            return "Cette situation particulière ne définit pas un pattern général. Chaque cas est unique."
        case .mentalFilter:
            return "Je peux choisir de voir l'ensemble de la situation, y compris les aspects positifs et neutres."
        case .discountingPositive:
            return "Mes réussites et les compliments sont valides et méritent d'être reconnus."
        case .jumpingToConclusions:
            return "Je peux chercher plus d'informations avant de tirer des conclusions hâtives."
        case .magnification:
            return "Cette situation est difficile mais gérable. Je peux trouver des solutions et du soutien."
        case .emotionalReasoning:
            return "Mes émotions sont valides mais ne déterminent pas la réalité objective."
        case .shouldStatements:
            return "Je peux avoir des préférences et des objectifs sans exigences rigides envers moi ou les autres."
        case .labeling:
            return "Je suis une personne complexe avec des forces et des faiblesses. Une action ne me définit pas."
        case .personalization:
            return "Beaucoup de facteurs influencent les situations. Je ne suis responsable que de mes actions."
        }
    }
}

#Preview {
    DistortionsGuideView()
}