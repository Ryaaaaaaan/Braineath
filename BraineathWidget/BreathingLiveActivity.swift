import ActivityKit
import WidgetKit
import SwiftUI

struct BreathingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BreathingActivityAttributes.self) { context in
            BreathingLiveActivityView(context: context)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.currentPhase)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(context.state.cycleCount)/\(context.state.totalCycles)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatTime(context.state.timeRemaining))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Text("restant")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    BreathingCircle(
                        phase: context.state.currentPhase,
                        isActive: context.state.isActive
                    )
                    .frame(width: 60, height: 60)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 1, y: 2)
                }
            } compactLeading: {
                Image(systemName: "lungs.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            } compactTrailing: {
                Text(formatTime(context.state.timeRemaining))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            } minimal: {
                Image(systemName: "lungs.fill")
                    .foregroundColor(.blue)
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

struct BreathingLiveActivityView: View {
    let context: ActivityViewContext<BreathingActivityAttributes>
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "brain.head.profile.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    Text("Braineath")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Text(context.attributes.sessionType)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.currentPhase)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Cycle \(context.state.cycleCount) sur \(context.state.totalCycles)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                BreathingCircle(
                    phase: context.state.currentPhase,
                    isActive: context.state.isActive
                )
                .frame(width: 80, height: 80)
                
                VStack(spacing: 4) {
                    Text(formatTime(context.state.timeRemaining))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("restant")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

struct BreathingCircle: View {
    let phase: String
    let isActive: Bool
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .scaleEffect(scale)
                .animation(
                    isActive ? .easeInOut(duration: getAnimationDuration()).repeatForever(autoreverses: true) : .default,
                    value: scale
                )
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.8),
                            phaseColor.opacity(0.6)
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 30
                    )
                )
                .scaleEffect(0.6)
            
            Image(systemName: phaseIcon)
                .font(.title3)
                .foregroundColor(phaseColor)
        }
        .onAppear {
            if isActive {
                scale = getTargetScale()
            }
        }
        .onChange(of: phase) { _, _ in
            if isActive {
                scale = getTargetScale()
            }
        }
    }
    
    private var phaseColor: Color {
        switch phase {
        case "Inspiration": return .green
        case "Rétention": return .orange
        case "Expiration": return .purple
        case "Pause": return .orange
        default: return .blue
        }
    }
    
    private var phaseIcon: String {
        switch phase {
        case "Inspiration": return "arrow.up.circle.fill"
        case "Rétention", "Pause": return "pause.circle.fill"
        case "Expiration": return "arrow.down.circle.fill"
        default: return "play.circle.fill"
        }
    }
    
    private func getTargetScale() -> CGFloat {
        switch phase {
        case "Inspiration": return 1.3
        case "Rétention": return 1.3
        case "Expiration": return 0.7
        case "Pause": return 0.7
        default: return 1.0
        }
    }
    
    private func getAnimationDuration() -> Double {
        switch phase {
        case "Inspiration": return 4.0
        case "Rétention": return 2.0
        case "Expiration": return 6.0
        case "Pause": return 2.0
        default: return 1.0
        }
    }
}