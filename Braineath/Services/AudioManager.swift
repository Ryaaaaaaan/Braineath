//
//  AudioManager.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import Foundation
import AVFoundation
import Combine
import UIKit

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var breathingTimer: Timer?
    
    @Published var isPlaying = false
    @Published var currentSound: BreathingSound = .silence
    @Published var volume: Float = 0.7
    
    enum BreathingSound: String, CaseIterable {
        case silence = "Silence"
        case oceanWaves = "Vagues océan"
        case forestRain = "Pluie forêt"
        case whitenoise = "Bruit blanc"
        case tibetanBowl = "Bol tibétain"
        case gentleBells = "Cloches douces"
        
        var filename: String? {
            switch self {
            case .silence: return nil
            case .oceanWaves: return "ocean_waves"
            case .forestRain: return "forest_rain"
            case .whitenoise: return "white_noise"
            case .tibetanBowl: return "tibetan_bowl"
            case .gentleBells: return "gentle_bells"
            }
        }
        
        var description: String {
            switch self {
            case .silence: return "Respiration en silence"
            case .oceanWaves: return "Sons apaisants des vagues de l'océan"
            case .forestRain: return "Pluie douce dans une forêt"
            case .whitenoise: return "Bruit blanc pour la concentration"
            case .tibetanBowl: return "Sons méditatifs de bols tibétains"
            case .gentleBells: return "Carillons doux et harmonieux"
            }
        }
    }
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playBreathingSound(_ sound: BreathingSound) {
        stopCurrentSound()
        
        guard sound != .silence, let filename = sound.filename else {
            currentSound = sound
            return
        }
        
        // Pour cette demo, on utilise des sons générés programmatiquement
        // Dans une vraie app, vous auriez des fichiers audio dans le bundle
        generateAndPlayTone(for: sound)
        
        currentSound = sound
        isPlaying = true
    }
    
    private func generateAndPlayTone(for sound: BreathingSound) {
        // Génération programmatique de sons simples pour la démo
        // Dans une vraie app, vous utiliseriez des fichiers audio de qualité
        
        let frequency: Float
        let amplitude: Float = 0.3
        let sampleRate: Float = 44100
        let duration: Float = 60 // Son en boucle de 60 secondes
        
        switch sound {
        case .oceanWaves:
            frequency = 220.0
        case .forestRain:
            frequency = 440.0
        case .whitenoise:
            frequency = 1000.0
        case .tibetanBowl:
            frequency = 256.0
        case .gentleBells:
            frequency = 523.25
        default:
            return
        }
        
        let frameCount = UInt32(sampleRate * duration)
        
        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1) else {
            return
        }
        
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else {
            return
        }
        
        audioBuffer.frameLength = frameCount
        
        let channels = UnsafeBufferPointer(start: audioBuffer.floatChannelData, count: Int(audioBuffer.format.channelCount))
        
        for frame in 0..<Int(frameCount) {
            let sampleTime = Float(frame) / sampleRate
            var sample: Float = 0
            
            switch sound {
            case .whitenoise:
                sample = Float.random(in: -amplitude...amplitude)
            case .oceanWaves:
                sample = amplitude * sin(2.0 * .pi * frequency * sampleTime) * 0.5 +
                        amplitude * sin(2.0 * .pi * frequency * 0.7 * sampleTime) * 0.3
            default:
                sample = amplitude * sin(2.0 * .pi * frequency * sampleTime)
            }
            
            channels[0][frame] = sample * volume
        }
        
        // Créer et configurer le player
        let audioEngine = AVAudioEngine()
        let playerNode = AVAudioPlayerNode()
        
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFormat)
        
        do {
            try audioEngine.start()
            playerNode.scheduleBuffer(audioBuffer, at: nil, options: .loops, completionHandler: nil)
            playerNode.play()
        } catch {
            print("Failed to play generated audio: \(error)")
        }
    }
    
    func stopCurrentSound() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        audioPlayer?.volume = volume
    }
    
    // Sons pour les transitions de respiration - versions dreamy et douces
    func playInhaleChime() {
        playDreamyTone(frequency: 523.25, duration: 0.8, volume: 0.3) // Do5 - son d'inspiration
    }
    
    func playExhaleChime() {
        playDreamyTone(frequency: 392.00, duration: 1.2, volume: 0.25) // Sol4 - son d'expiration plus bas
    }
    
    func playHoldChime() {
        playDreamyTone(frequency: 440.00, duration: 0.5, volume: 0.2) // La4 - son de pause doux
    }
    
    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    private func playDreamyTone(frequency: Float, duration: Float, volume: Float) {
        let sampleRate: Float = 44100
        let frameCount = UInt32(sampleRate * duration)
        
        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1) else {
            return
        }
        
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else {
            return
        }
        
        audioBuffer.frameLength = frameCount
        
        let channels = UnsafeBufferPointer(start: audioBuffer.floatChannelData, count: Int(audioBuffer.format.channelCount))
        
        for frame in 0..<Int(frameCount) {
            let sampleTime = Float(frame) / sampleRate
            let fadeTime: Float = 0.1 // Fade in/out de 0.1 seconde
            
            // Envelope pour un son doux avec fade in/out
            var envelope: Float = 1.0
            if sampleTime < fadeTime {
                envelope = sampleTime / fadeTime
            } else if sampleTime > duration - fadeTime {
                envelope = (duration - sampleTime) / fadeTime
            }
            
            // Génération d'un ton complexe plus doux et dreamy
            let fundamental = sin(2.0 * .pi * frequency * sampleTime)
            let harmonic1 = sin(2.0 * .pi * frequency * 2.0 * sampleTime) * 0.3
            let harmonic2 = sin(2.0 * .pi * frequency * 3.0 * sampleTime) * 0.1
            let harmonic3 = sin(2.0 * .pi * frequency * 0.5 * sampleTime) * 0.2 // Sous-harmonique
            
            let sample = (fundamental + harmonic1 + harmonic2 + harmonic3) * volume * envelope * 0.5
            
            channels[0][frame] = sample
        }
        
        // Jouer le son
        let audioEngine = AVAudioEngine()
        let playerNode = AVAudioPlayerNode()
        
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFormat)
        
        do {
            try audioEngine.start()
            playerNode.scheduleBuffer(audioBuffer, at: nil, options: [], completionHandler: nil)
            playerNode.play()
            
            // Arrêter le moteur après la durée du son
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration + 0.1)) {
                audioEngine.stop()
            }
        } catch {
            print("Failed to play dreamy tone: \(error)")
        }
    }
    
    // Génération de vibrations haptiques
    func playHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    func playNotificationHaptic(type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }
}

// Extension pour les sons d'ambiance locaux (simulés)
extension AudioManager {
    
    // Dans une vraie app, ces sons seraient des fichiers audio dans Assets.xcassets
    static let ambientSounds: [String: String] = [
        "ocean_waves": "Sons d'océan générés",
        "forest_rain": "Pluie de forêt générée",
        "white_noise": "Bruit blanc généré",
        "tibetan_bowl": "Bol tibétain généré",
        "gentle_bells": "Cloches douces générées"
    ]
    
    func preloadSounds() {
        // Dans une vraie app, vous préchargeriez ici tous vos sons
        print("Préchargement des sons d'ambiance...")
    }
}