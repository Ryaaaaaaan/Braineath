//
//  SharedComponents.swift
//  Braineath
//
//  Created by Ryan Zemri on 12/09/2025.
//

import SwiftUI

// Composant StatCard partagé - version avec subtitle optionnel
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let color: Color
    let icon: String
    
    init(title: String, value: String, subtitle: String? = nil, color: Color, icon: String) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.color = color
        self.icon = icon
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
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

// Version compacte pour Dashboard
struct CompactStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}