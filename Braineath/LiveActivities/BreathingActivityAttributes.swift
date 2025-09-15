import ActivityKit
import Foundation

struct BreathingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentPhase: String
        var timeRemaining: Int
        var cycleCount: Int
        var totalCycles: Int
        var progress: Double
        var isActive: Bool
    }
    
    var sessionType: String
    var duration: Int
    var startTime: Date
}