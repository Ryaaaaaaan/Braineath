//
//  BraineathWidget.swift
//  BraineathWidget
//
//  Created by Ryan Zemri on 12/09/2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), moodLevel: 7, breathingStreak: 5)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), moodLevel: 7, breathingStreak: 5)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Générer une timeline avec des données simulées
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, moodLevel: Int.random(in: 5...9), breathingStreak: 5 + hourOffset)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let moodLevel: Int
    let breathingStreak: Int
}

struct BraineathWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Spacer()
                
                Text("Braineath")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                        .font(.caption)
                    
                    Text("\(entry.moodLevel)/10")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text("\(entry.breathingStreak)j")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            HStack {
                Image(systemName: "lungs.fill")
                    .foregroundColor(.green)
                    .font(.caption2)
                
                Text("Respirer")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

struct MediumWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    Text("Braineath")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .font(.subheadline)
                        
                        VStack(alignment: .leading) {
                            Text("Humeur")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(entry.moodLevel)/10")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.subheadline)
                        
                        VStack(alignment: .leading) {
                            Text("Série")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(entry.breathingStreak) jours")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                }
            }
            
            VStack(spacing: 12) {
                Button(intent: QuickBreathingIntent()) {
                    VStack(spacing: 4) {
                        Image(systemName: "lungs.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                        
                        Text("Respirer")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.green)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(intent: QuickMoodIntent()) {
                    VStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                        
                        Text("Humeur")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.pink)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

struct LargeWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("Braineath")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Votre bien-être mental")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Stats section
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                        .font(.title)
                    
                    Text("\(entry.moodLevel)/10")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Humeur")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.pink.opacity(0.1))
                )
                
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.title)
                    
                    Text("\(entry.breathingStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Jours")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                )
            }
            
            // Quick actions
            VStack(spacing: 12) {
                Text("Actions rapides")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Button(intent: QuickBreathingIntent()) {
                        HStack {
                            Image(systemName: "lungs.fill")
                                .foregroundColor(.green)
                            Text("Respiration")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(intent: QuickMoodIntent()) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                            Text("Humeur")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.pink.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.pink.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

struct BraineathWidget: Widget {
    let kind: String = "BraineathWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                BraineathWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                BraineathWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Braineath")
        .description("Suivez votre bien-être mental et accédez rapidement aux exercices.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    BraineathWidget()
} timeline: {
    SimpleEntry(date: .now, moodLevel: 7, breathingStreak: 5)
    SimpleEntry(date: .now, moodLevel: 8, breathingStreak: 6)
}

#Preview(as: .systemMedium) {
    BraineathWidget()
} timeline: {
    SimpleEntry(date: .now, moodLevel: 7, breathingStreak: 5)
}

#Preview(as: .systemLarge) {
    BraineathWidget()
} timeline: {
    SimpleEntry(date: .now, moodLevel: 7, breathingStreak: 5)
}