//
//  DataManager.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import Foundation
import CoreData
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Braineath")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    // MARK: - Mood Entry Operations
    func createMoodEntry(emotion: String, intensity: Int, notes: String?, triggers: [String]?, energyLevel: Int, stressLevel: Int) -> MoodEntry {
        let entry = MoodEntry(context: context)
        entry.id = UUID()
        entry.date = Date()
        entry.primaryEmotion = emotion
        entry.emotionIntensity = Int16(intensity)
        entry.notes = notes
        entry.triggers = triggers
        entry.energyLevel = Int16(energyLevel)
        entry.stressLevel = Int16(stressLevel)
        save()
        return entry
    }
    
    func fetchMoodEntries(limit: Int = 30) -> [MoodEntry] {
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntry.date, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch mood entries: \(error)")
            return []
        }
    }
    
    // MARK: - Breathing Session Operations
    func createBreathingSession(pattern: String, duration: Int, completionPercentage: Double, moodBefore: Int?, moodAfter: Int?) -> BreathingSession {
        let session = BreathingSession(context: context)
        session.id = UUID()
        session.date = Date()
        session.breathingPattern = pattern
        session.duration = Int32(duration)
        session.completionPercentage = completionPercentage
        if let before = moodBefore { session.moodBefore = Int16(before) }
        if let after = moodAfter { session.moodAfter = Int16(after) }
        save()
        return session
    }
    
    func fetchBreathingSessions(limit: Int = 50) -> [BreathingSession] {
        let request: NSFetchRequest<BreathingSession> = BreathingSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BreathingSession.date, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch breathing sessions: \(error)")
            return []
        }
    }
    
    // MARK: - Thought Record Operations
    func createThoughtRecord(situation: String, automaticThought: String, emotionBefore: String, intensityBefore: Int) -> ThoughtRecord {
        let record = ThoughtRecord(context: context)
        record.id = UUID()
        record.date = Date()
        record.situation = situation
        record.automaticThought = automaticThought
        record.emotionBefore = emotionBefore
        record.intensityBefore = Int16(intensityBefore)
        save()
        return record
    }
    
    // MARK: - Gratitude Operations
    func createGratitudeEntry(text: String, category: String?) -> GratitudeEntry {
        let entry = GratitudeEntry(context: context)
        entry.id = UUID()
        entry.date = Date()
        entry.gratitudeText = text
        entry.category = category
        entry.isPrivate = true
        save()
        return entry
    }
    
    func fetchGratitudeEntries(limit: Int = 100) -> [GratitudeEntry] {
        let request: NSFetchRequest<GratitudeEntry> = GratitudeEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GratitudeEntry.date, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch gratitude entries: \(error)")
            return []
        }
    }
    
    // MARK: - Daily Intention Operations
    func createDailyIntention(text: String, category: String?) -> DailyIntention {
        let intention = DailyIntention(context: context)
        intention.id = UUID()
        intention.date = Date()
        intention.intentionText = text
        intention.category = category
        intention.isCompleted = false
        save()
        return intention
    }
    
    // MARK: - Emergency Session Operations
    func createEmergencySession(triggerEmotion: String, intensityBefore: Int) -> EmergencySession {
        let session = EmergencySession(context: context)
        session.id = UUID()
        session.date = Date()
        session.triggerEmotion = triggerEmotion
        session.intensityBefore = Int16(intensityBefore)
        session.duration = 0
        save()
        return session
    }
    
    // MARK: - User Preferences Operations
    func getUserPreferences() -> UserPreferences {
        let request: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        
        do {
            let preferences = try context.fetch(request)
            if let existingPrefs = preferences.first {
                return existingPrefs
            } else {
                // Créer des préférences par défaut
                let newPrefs = UserPreferences(context: context)
                newPrefs.id = UUID()
                newPrefs.preferredTheme = "adaptive"
                newPrefs.notificationsEnabled = true
                newPrefs.soundEnabled = true
                newPrefs.hapticEnabled = true
                newPrefs.privacyLevel = "high"
                save()
                return newPrefs
            }
        } catch {
            print("Failed to fetch user preferences: \(error)")
            // Retourner des préférences par défaut en cas d'erreur
            let defaultPrefs = UserPreferences(context: context)
            defaultPrefs.id = UUID()
            defaultPrefs.preferredTheme = "adaptive"
            defaultPrefs.notificationsEnabled = true
            defaultPrefs.soundEnabled = true
            defaultPrefs.hapticEnabled = true
            defaultPrefs.privacyLevel = "high"
            return defaultPrefs
        }
    }
    
    // MARK: - Analytics (Privacy-Safe)
    func getMoodTrends(days: Int = 7) -> [(Date, Double)] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntry.date, ascending: true)]
        
        do {
            let entries = try context.fetch(request)
            var dailyMoods: [Date: [Double]] = [:]
            
            for entry in entries {
                let day = Calendar.current.startOfDay(for: entry.date!)
                if dailyMoods[day] == nil {
                    dailyMoods[day] = []
                }
                dailyMoods[day]?.append(Double(entry.emotionIntensity))
            }
            
            return dailyMoods.compactMap { date, moods in
                let average = moods.reduce(0, +) / Double(moods.count)
                return (date, average)
            }.sorted { $0.0 < $1.0 }
        } catch {
            print("Failed to fetch mood trends: \(error)")
            return []
        }
    }
}