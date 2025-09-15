import AppIntents
import WidgetKit

struct QuickBreathingIntent: AppIntent {
    static var title: LocalizedStringResource = "Session de respiration rapide"
    static var description = IntentDescription("Lancez une session de respiration de 3 minutes")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct QuickMoodIntent: AppIntent {
    static var title: LocalizedStringResource = "Noter mon humeur"
    static var description = IntentDescription("Enregistrez votre humeur actuelle rapidement")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct RefreshWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Actualiser le widget"
    static var description = IntentDescription("Met à jour les données du widget")
    
    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadTimelines(ofKind: "BraineathWidget")
        return .result()
    }
}