//
//  SOSWidget.swift
//  BraineathWidget
//
//  Created by Ryan Zemri on 12/09/2025.
//

import WidgetKit
import SwiftUI

struct SOSProvider: TimelineProvider {
    func placeholder(in context: Context) -> SOSEntry {
        SOSEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SOSEntry) -> ()) {
        let entry = SOSEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SOSEntry>) -> ()) {
        let entries: [SOSEntry] = [SOSEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SOSEntry: TimelineEntry {
    let date: Date
}

struct SOSWidgetEntryView: View {
    var entry: SOSProvider.Entry

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.red.opacity(0.8), .red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("SOS")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Urgence")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.red.opacity(0.8), .red]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: .red.opacity(0.5), radius: 8, x: 0, y: 4)
        )
    }
}

struct SOSWidget: Widget {
    let kind: String = "SOSWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SOSProvider()) { entry in
            if #available(iOS 17.0, *) {
                SOSWidgetEntryView(entry: entry)
                    .containerBackground(.clear, for: .widget)
            } else {
                SOSWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("SOS Braineath")
        .description("Accès rapide aux ressources d'urgence en cas de crise.")
        .supportedFamilies([.systemSmall])
    }
}