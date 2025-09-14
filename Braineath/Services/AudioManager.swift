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
        // Génération de sons apaisants et doux
        generateSoothingAmbientSound(for: sound)
    }

    // Génère des sons d'ambiance apaisants pour les exercices de respiration
    // Chaque son a ses propres caractéristiques pour créer une atmosphère relaxante
    private func generateSoothingAmbientSound(for sound: BreathingSound) {
        let sampleRate: Float = 44100
        let duration: Float = 60.0 // Son en boucle de 60 secondes
        let frameCount = UInt32(sampleRate * duration)
        let amplitude: Float = 0.15 // Volume réduit pour éviter l'agression auditive

        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 2) else {
            return
        }

        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else {
            return
        }

        audioBuffer.frameLength = frameCount

        let leftChannel = audioBuffer.floatChannelData![0]
        let rightChannel = audioBuffer.floatChannelData![1]

        // Génération sample par sample pour créer des textures sonores naturelles
        for frame in 0..<Int(frameCount) {
            let sampleTime = Float(frame) / sampleRate
            var leftSample: Float = 0
            var rightSample: Float = 0

            switch sound {
            case .oceanWaves:
                // Simulation d'océan : superposition de vagues à différentes fréquences
                // Les fréquences basses créent l'impression de vagues lointaines
                let wave1 = sin(2.0 * .pi * 0.5 * sampleTime) * 0.3
                let wave2 = sin(2.0 * .pi * 0.7 * sampleTime) * 0.2
                let wave3 = sin(2.0 * .pi * 1.2 * sampleTime) * 0.1
                let noise = Float.random(in: -0.05...0.05) // Bruit subtil pour le réalisme
                leftSample = (wave1 + wave2 + wave3 + noise) * amplitude
                rightSample = (wave1 * 0.8 + wave2 * 1.2 + wave3 * 0.9 + noise) * amplitude

            case .forestRain:
                // Simulation de pluie : bruit aléatoire avec filtre passe-bas
                let noise = Float.random(in: -0.1...0.1)
                let filtered = noise * (1.0 / (1.0 + sampleTime * 0.01)) // Adoucit les hautes fréquences
                leftSample = filtered * amplitude * 0.8
                rightSample = filtered * amplitude * 0.7

            case .whitenoise:
                // Bruit blanc très doux et filtré
                let noise = Float.random(in: -0.1...0.1)
                let smoothed = noise * (0.3 + 0.7 * sin(sampleTime * 0.1)) // Modulation douce
                leftSample = smoothed * amplitude * 0.5
                rightSample = smoothed * amplitude * 0.6

            case .tibetanBowl:
                // Bol tibétain avec harmoniques naturelles
                let fundamental = sin(2.0 * .pi * 256.0 * sampleTime)
                let harmonic2 = sin(2.0 * .pi * 512.0 * sampleTime) * 0.3
                let harmonic3 = sin(2.0 * .pi * 768.0 * sampleTime) * 0.1
                let envelope = exp(-sampleTime * 0.1) // Déclin naturel
                leftSample = (fundamental + harmonic2 + harmonic3) * envelope * amplitude * 0.4
                rightSample = leftSample * 0.9

            case .gentleBells:
                // Cloches douces avec réverbération
                let bell1 = sin(2.0 * .pi * 523.25 * sampleTime) * exp(-sampleTime * 0.2)
                let bell2 = sin(2.0 * .pi * 659.25 * sampleTime) * exp(-sampleTime * 0.15) * 0.6
                let bell3 = sin(2.0 * .pi * 783.99 * sampleTime) * exp(-sampleTime * 0.25) * 0.4
                let bellMix = (bell1 + bell2 + bell3)
                let cycle = sin(sampleTime * 0.2) * 0.5 + 0.5 // Cycle lent pour variation
                leftSample = bellMix * amplitude * 0.3 * cycle
                rightSample = bellMix * amplitude * 0.25 * cycle

            default:
                return
            }

            // Application du volume global et limitation douce
            leftSample = tanh(leftSample * volume) * 0.8
            rightSample = tanh(rightSample * volume) * 0.8

            leftChannel[frame] = leftSample
            rightChannel[frame] = rightSample
        }

        // Lecture avec configuration optimisée
        playAudioBuffer(audioBuffer, format: audioFormat, loop: true)
    }

    private func playAudioBuffer(_ buffer: AVAudioPCMBuffer, format: AVAudioFormat, loop: Bool) {
        let audioEngine = AVAudioEngine()
        let playerNode = AVAudioPlayerNode()
        let reverbNode = AVAudioUnitReverb()

        // Configuration de la réverbération pour plus de douceur
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 20 // 20% de réverbération

        audioEngine.attach(playerNode)
        audioEngine.attach(reverbNode)
        audioEngine.connect(playerNode, to: reverbNode, format: format)
        audioEngine.connect(reverbNode, to: audioEngine.mainMixerNode, format: format)

        do {
            try audioEngine.start()
            let options: AVAudioPlayerNodeBufferOptions = loop ? .loops : []
            playerNode.scheduleBuffer(buffer, at: nil, options: options, completionHandler: nil)
            playerNode.play()
        } catch {
            print("Failed to play soothing audio: \(error)")
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
    
    // Sons pour les transitions de respiration - versions très douces et apaisantes
    func playInhaleChime() {
        playUltraSoftTone(frequency: 523.25, duration: 1.0, volume: 0.15) // Do5 - inspiration douce
    }

    func playExhaleChime() {
        playUltraSoftTone(frequency: 392.00, duration: 1.5, volume: 0.12) // Sol4 - expiration très douce
    }

    func playHoldChime() {
        playUltraSoftTone(frequency: 440.00, duration: 0.8, volume: 0.10) // La4 - pause ultra douce
    }
    
    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    // Génère des tons ultra-doux pour les transitions de respiration
    // Utilise des enveloppes exponentielles et de la réverbération pour un effet apaisant
    private func playUltraSoftTone(frequency: Float, duration: Float, volume: Float) {
        let sampleRate: Float = 44100
        let frameCount = UInt32(sampleRate * duration)

        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 2) else {
            return
        }

        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else {
            return
        }

        audioBuffer.frameLength = frameCount

        let leftChannel = audioBuffer.floatChannelData![0]
        let rightChannel = audioBuffer.floatChannelData![1]

        // Construction du signal avec harmoniques et modulation subtile
        for frame in 0..<Int(frameCount) {
            let sampleTime = Float(frame) / sampleRate
            let fadeTime: Float = 0.3 // Fade long pour éviter les clics audio

            // Envelope exponentielle pour un démarrage/arrêt naturel
            var envelope: Float = 1.0
            if sampleTime < fadeTime {
                envelope = pow(sampleTime / fadeTime, 2.0) // Montée douce
            } else if sampleTime > duration - fadeTime {
                envelope = pow((duration - sampleTime) / fadeTime, 2.0) // Descente douce
            }

            // Génération d'un son cristallin mais très doux
            let fundamental = sin(2.0 * .pi * frequency * sampleTime)
            let harmonic1 = sin(2.0 * .pi * frequency * 2.0 * sampleTime) * 0.2
            let harmonic2 = sin(2.0 * .pi * frequency * 3.0 * sampleTime) * 0.05
            let subHarmonic = sin(2.0 * .pi * frequency * 0.5 * sampleTime) * 0.1

            // Modulation très douce pour un effet cristallin
            let modulation = 1.0 + sin(sampleTime * 2.0) * 0.02

            let baseSample = (fundamental + harmonic1 + harmonic2 + subHarmonic) * modulation
            let finalSample = tanh(baseSample * volume * envelope * 0.3) // Limitation douce

            leftChannel[frame] = finalSample
            rightChannel[frame] = finalSample * 0.9 // Légère différence stéréo
        }

        // Lecture avec réverbération douce
        let audioEngine = AVAudioEngine()
        let playerNode = AVAudioPlayerNode()
        let reverbNode = AVAudioUnitReverb()

        reverbNode.loadFactoryPreset(.smallRoom)
        reverbNode.wetDryMix = 30 // 30% de réverbération pour plus de douceur

        audioEngine.attach(playerNode)
        audioEngine.attach(reverbNode)
        audioEngine.connect(playerNode, to: reverbNode, format: audioFormat)
        audioEngine.connect(reverbNode, to: audioEngine.mainMixerNode, format: audioFormat)

        do {
            try audioEngine.start()
            playerNode.scheduleBuffer(audioBuffer, at: nil, options: [], completionHandler: nil)
            playerNode.play()

            // Arrêt progressif
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration + 0.2)) {
                audioEngine.stop()
            }
        } catch {
            print("Failed to play ultra-soft tone: \(error)")
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