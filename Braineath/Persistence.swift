//
//  Persistence.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Créer des données de test pour l'aperçu
        
        // Entrées d'humeur de test
        for i in 0..<7 {
            let moodEntry = MoodEntry(context: viewContext)
            moodEntry.id = UUID()
            moodEntry.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            moodEntry.primaryEmotion = ["Joyeux", "Serein", "Stressé", "Anxieux", "Confiant", "Pensif", "Énergique"].randomElement()!
            moodEntry.emotionIntensity = Int16.random(in: 3...9)
            moodEntry.energyLevel = Int16.random(in: 2...8)
            moodEntry.stressLevel = Int16.random(in: 1...7)
            moodEntry.notes = i % 3 == 0 ? "Belle journée avec quelques défis" : nil
        }
        
        // Sessions de respiration de test
        for i in 0..<5 {
            let session = BreathingSession(context: viewContext)
            session.id = UUID()
            session.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            session.breathingPattern = ["4-7-8", "Respiration Carrée", "Cohérence Cardiaque"].randomElement()!
            session.duration = Int32.random(in: 180...600) // 3-10 minutes
            session.completionPercentage = Double.random(in: 80...100)
            session.moodBefore = Int16.random(in: 4...8)
            session.moodAfter = Int16.random(in: 6...10)
        }
        
        // Entrées de gratitude de test
        let gratitudeTexts = [
            "Ma famille et leurs sourires chaleureux",
            "Une belle promenade dans la nature",
            "Un café délicieux ce matin",
            "L'aide d'un collègue bienveillant",
            "Un moment de calme avant de dormir"
        ]
        
        for (i, text) in gratitudeTexts.enumerated() {
            let gratitude = GratitudeEntry(context: viewContext)
            gratitude.id = UUID()
            gratitude.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            gratitude.gratitudeText = text
            gratitude.category = ["Famille", "Nature", "Petits plaisirs", "Travail", "Moments"].randomElement()
            gratitude.isPrivate = true
        }
        
        // Intentions quotidiennes de test
        let intentions = [
            "Être présent(e) dans mes conversations",
            "Prendre trois grandes respirations avant de réagir",
            "Pratiquer la gratitude au réveil",
            "Faire une pause déjeuner sans écran",
            "Terminer la journée par une réflexion positive"
        ]
        
        for (i, intention) in intentions.enumerated() {
            let dailyIntention = DailyIntention(context: viewContext)
            dailyIntention.id = UUID()
            dailyIntention.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            dailyIntention.intentionText = intention
            dailyIntention.category = ["Bien-être", "Relations", "Productivité", "Gratitude"].randomElement()
            dailyIntention.isCompleted = i % 2 == 0
        }
        
        // Enregistrement de pensée TCC de test
        let thoughtRecord = ThoughtRecord(context: viewContext)
        thoughtRecord.id = UUID()
        thoughtRecord.date = Date()
        thoughtRecord.situation = "Présentation importante au travail"
        thoughtRecord.automaticThought = "Je vais sûrement échouer et tout le monde va penser que je suis incompétent"
        thoughtRecord.emotionBefore = "Anxiété"
        thoughtRecord.intensityBefore = 8
        thoughtRecord.cognitiveDistortions = ["Conclusions hâtives", "Généralisation excessive"]
        thoughtRecord.balancedThought = "J'ai bien préparé cette présentation. Même si ce n'est pas parfait, je peux apporter de la valeur à mon équipe."
        thoughtRecord.emotionAfter = "Nervosité positive"
        thoughtRecord.intensityAfter = 4
        
        // Préférences utilisateur par défaut
        let userPrefs = UserPreferences(context: viewContext)
        userPrefs.id = UUID()
        userPrefs.preferredTheme = "adaptive"
        userPrefs.notificationsEnabled = true
        userPrefs.soundEnabled = true
        userPrefs.hapticEnabled = true
        userPrefs.privacyLevel = "high"
        
        // Quelques achievements de test
        let achievements = [
            ("Première respiration", "Première session de respiration complétée", "breathing", true, 1, 1),
            ("Premier pas", "Première entrée d'humeur ajoutée", "mood", true, 1, 1),
            ("Série de 3", "3 jours consécutifs d'utilisation", "streak", false, 2, 3),
            ("Maître zen", "50 sessions de respiration complétées", "breathing", false, 15, 50)
        ]
        
        for (title, description, type, isUnlocked, progress, required) in achievements {
            let achievement = Achievement(context: viewContext)
            achievement.id = UUID()
            achievement.title = title
            achievement.achievementDescription = description
            achievement.achievementType = type
            achievement.isUnlocked = isUnlocked
            achievement.progress = Int32(progress)
            achievement.requiredProgress = Int32(required)
            if isUnlocked {
                achievement.dateEarned = Date()
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Braineath")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Configuration de la description du store pour optimiser les performances
        container.persistentStoreDescriptions.forEach { storeDescription in
            storeDescription.shouldInferMappingModelAutomatically = true
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 En production, vous devriez implémenter une gestion d'erreur appropriée.
                 Les erreurs typiques incluent :
                 * Le répertoire parent n'existe pas, ne peut pas être créé, ou n'autorise pas l'écriture.
                 * Le store persistant n'est pas accessible à cause des permissions ou de la protection des données quand l'appareil est verrouillé.
                 * L'appareil n'a plus d'espace.
                 * Le store n'a pas pu être migré vers la version actuelle du modèle.
                 Vérifiez le message d'erreur pour déterminer le problème réel.
                 */
                print("Core Data error: \(error), \(error.userInfo)")
                
                // En cas d'erreur de migration, on pourrait tenter de supprimer et recréer le store
                // Attention : cela supprimera toutes les données utilisateur !
                if error.code == NSPersistentStoreIncompatibleVersionHashError || error.code == NSMigrationMissingSourceModelError {
                    print("Attempting to delete and recreate the persistent store...")
                    if let storeURL = storeDescription.url {
                        try? FileManager.default.removeItem(at: storeURL)
                        // Relancer le chargement du store
                        container.loadPersistentStores { _, newError in
                            if let newError = newError {
                                fatalError("Failed to recreate persistent store: \(newError)")
                            }
                        }
                    }
                } else {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        })
        
        // Configuration du contexte principal
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Configuration pour les notifications de changement à distance si on utilise CloudKit plus tard
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            print("Failed to pin viewContext to the current generation: \(error)")
        }
    }
    
    // Méthode utilitaire pour sauvegarder le contexte
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
