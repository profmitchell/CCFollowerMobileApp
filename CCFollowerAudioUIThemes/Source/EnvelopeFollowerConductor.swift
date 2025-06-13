import AudioKit
import AVFoundation
import AVFAudio
import SwiftUI
import MIDIKitIO

@Observable @MainActor
class EnvelopeFollowerConductor {
    let engine = AudioEngine()
    private var inputNode: Node?
    private var amplitudeTap: AmplitudeTap?
    private var midiHelper: MIDIHelper?
    
    // Envelope follower parameters
    var isActive = false
    var currentAmplitude: Float = 0.0
    var threshold: Float = 0.1
    var gain: Float = 1.0
    var smoothing: Float = 0.8
    
    // MIDI parameters
    var midiChannel: Int = 0
    var ccNumber: Int = 1
    var ccValue: Int = 0
    
    // Permission and status
    var microphonePermissionGranted = false
    var isEngineRunning = false
    
    private var smoothedAmplitude: Float = 0.0
    
    init() {
        setupAudio()
    }
    
    deinit {
        // Note: Cleanup will happen when the main actor deallocates
        // AudioKit resources will be cleaned up automatically
    }
    
    func setupMIDI(midiHelper: MIDIHelper) {
        self.midiHelper = midiHelper
    }
    
    private func setupAudio() {
        // Request microphone permission
        Task {
            let granted = await requestMicrophonePermission()
            self.microphonePermissionGranted = granted
            if granted {
                self.initializeAudioEngine()
            }
        }
    }
    
    private func requestMicrophonePermission() async -> Bool {
        if #available(iOS 17.0, *) {
            return await withCheckedContinuation { continuation in
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        } else {
            return await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    private func initializeAudioEngine() {
        guard microphonePermissionGranted else { return }
        
        do {
            // Set up audio session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            
            // Use the engine's input node
            inputNode = engine.input
            
            guard let inputNode = inputNode else {
                print("Failed to get input node")
                return
            }
            
            // Create amplitude tap
            amplitudeTap = AmplitudeTap(
                inputNode,
                bufferSize: 256,
                callbackQueue: .main
            ) { [weak self] amplitude in
                self?.processAmplitude(amplitude)
            }
            
            // Set the engine output to the input (for monitoring if needed)
            engine.output = inputNode
            
        } catch {
            print("Error setting up audio: \(error)")
        }
    }
    
    private func processAmplitude(_ amplitude: Float) {
        // Apply smoothing to the amplitude
        smoothedAmplitude = smoothedAmplitude * smoothing + amplitude * (1.0 - smoothing)
        
        // Update current amplitude for UI
        currentAmplitude = smoothedAmplitude
        
        // Apply threshold and gain
        let processedAmplitude = max(0.0, (smoothedAmplitude - threshold) * gain)
        
        // Convert to MIDI CC value (0-127)
        let midiValue = Int(min(127, max(0, processedAmplitude * 127)))
        ccValue = midiValue
        
        // Send MIDI CC if active
        if isActive && midiHelper != nil {
            sendMIDICC(value: midiValue)
        }
    }
    
    private func sendMIDICC(value: Int) {
        guard let midiHelper = midiHelper else { return }
        
        let ccEvent = MIDIEvent.cc(
            UInt7(ccNumber),
            value: .midi1(UInt7(value)),
            channel: UInt4(midiChannel)
        )
        
        midiHelper.sendComponentMIDI(ccEvent)
    }
    
    func start() {
        guard microphonePermissionGranted, let amplitudeTap = amplitudeTap else { return }
        
        do {
            try engine.start()
            amplitudeTap.start()
            isEngineRunning = true
            isActive = true
        } catch {
            print("Error starting engine: \(error)")
        }
    }
    
    func stop() {
        amplitudeTap?.stop()
        engine.stop()
        isEngineRunning = false
        isActive = false
    }
    
    func toggleActive() {
        if isEngineRunning {
            isActive.toggle()
        } else {
            start()
        }
    }
} 
