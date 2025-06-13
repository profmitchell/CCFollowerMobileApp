//
//  CanvasPresets.swift
//  CntrlSuite - Professional Audio Controller
//  © 2025 CohenConcepts • Licensed under MIT License
//

import SwiftUI
import AudioUIComponents
import MIDIKit

// MARK: - User Canvas Preset
struct UserCanvasPreset: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let components: [CanvasComponent]
    let createdAt: Date
    
    init(name: String, description: String, components: [CanvasComponent]) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.components = components
        self.createdAt = Date()
    }
}

// MARK: - Preset Storage Manager
@MainActor
class PresetStorageManager: ObservableObject {
    @Published var userPresets: [UserCanvasPreset] = []
    private let userDefaultsKey = "UserCanvasPresets"
    
    init() {
        loadUserPresets()
    }
    
    func savePreset(name: String, description: String, canvasStorage: EnhancedCanvasStorage) {
        let preset = UserCanvasPreset(
            name: name,
            description: description,
            components: canvasStorage.components
        )
        
        userPresets.append(preset)
        saveUserPresetsToStorage()
    }
    
    func deletePreset(_ preset: UserCanvasPreset) {
        userPresets.removeAll { $0.id == preset.id }
        saveUserPresetsToStorage()
    }
    
    func loadPreset(_ preset: UserCanvasPreset, canvasStorage: EnhancedCanvasStorage) {
        canvasStorage.clearCanvas()
        
        for component in preset.components {
            canvasStorage.addComponent(component)
        }
    }
    
    private func saveUserPresetsToStorage() {
        if let encoded = try? JSONEncoder().encode(userPresets) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadUserPresets() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([UserCanvasPreset].self, from: data) {
            userPresets = decoded
        }
    }
}

// MARK: - Canvas Preset Manager
@MainActor
class CanvasPresetManager {
    
    static func loadPreset(_ type: PresetType, canvasStorage: EnhancedCanvasStorage) {
        canvasStorage.clearCanvas()
        
        switch type {
        case .dj:
            loadDJPreset(canvasStorage: canvasStorage)
        case .producer:
            loadProducerPreset(canvasStorage: canvasStorage)
        case .performance:
            loadPerformancePreset(canvasStorage: canvasStorage)
        }
    }
    
    // MARK: - Enhanced Preset Configurations
    private static func loadDJPreset(canvasStorage: EnhancedCanvasStorage) {
        let components = [
            createConfiguredComponent(.sliderMinimal1, position: CGPoint(x: 100, y: 200), 
                                    midiChannel: 1, midiCC: 1, label: "Bass EQ"),
            createConfiguredComponent(.sliderMinimal1, position: CGPoint(x: 200, y: 200), 
                                    midiChannel: 1, midiCC: 2, label: "Mid EQ"),
            createConfiguredComponent(.sliderMinimal1, position: CGPoint(x: 300, y: 200), 
                                    midiChannel: 1, midiCC: 3, label: "High EQ"),
            createConfiguredComponent(.knobMinimal1, position: CGPoint(x: 450, y: 150), 
                                    midiChannel: 1, midiCC: 7, label: "Volume"),
            createConfiguredComponent(.knobMinimal1, position: CGPoint(x: 550, y: 150), 
                                    midiChannel: 1, midiCC: 10, label: "Filter"),
            createConfiguredComponent(.xyPadMinimal1, position: CGPoint(x: 650, y: 300), 
                                    midiChannel: 1, midiCC: 16, label: "FX Pad")
        ]
        
        for component in components {
            canvasStorage.addComponent(component)
        }
    }
    
    private static func loadProducerPreset(canvasStorage: EnhancedCanvasStorage) {
        let components = [
            createConfiguredComponent(.knobMinimal1, position: CGPoint(x: 150, y: 150), 
                                    midiChannel: 1, midiCC: 14, label: "Attack"),
            createConfiguredComponent(.knobMinimal1, position: CGPoint(x: 250, y: 150), 
                                    midiChannel: 1, midiCC: 15, label: "Decay"),
            createConfiguredComponent(.knobMinimal1, position: CGPoint(x: 350, y: 150), 
                                    midiChannel: 1, midiCC: 16, label: "Sustain"),
            createConfiguredComponent(.knobMinimal1, position: CGPoint(x: 450, y: 150), 
                                    midiChannel: 1, midiCC: 17, label: "Release"),
            createConfiguredComponent(.sliderMinimal1, position: CGPoint(x: 150, y: 350), 
                                    midiChannel: 1, midiCC: 20, label: "Ch 1"),
            createConfiguredComponent(.sliderMinimal1, position: CGPoint(x: 250, y: 350), 
                                    midiChannel: 1, midiCC: 21, label: "Ch 2"),
            createConfiguredComponent(.sliderMinimal1, position: CGPoint(x: 350, y: 350), 
                                    midiChannel: 1, midiCC: 22, label: "Ch 3"),
            createConfiguredComponent(.sliderMinimal1, position: CGPoint(x: 450, y: 350), 
                                    midiChannel: 1, midiCC: 23, label: "Ch 4")
        ]
        
        for component in components {
            canvasStorage.addComponent(component)
        }
    }
    
    private static func loadPerformancePreset(canvasStorage: EnhancedCanvasStorage) {
        let components = [
            createConfiguredComponent(.xyPadMinimal1, position: CGPoint(x: 200, y: 200), 
                                    midiChannel: 1, midiCC: 30, label: "Expression"),
            createConfiguredComponent(.drumPadMinimal1, position: CGPoint(x: 100, y: 400), 
                                    midiChannel: 10, midiCC: 36, label: "Kick"),
            createConfiguredComponent(.drumPadMinimal1, position: CGPoint(x: 200, y: 400), 
                                    midiChannel: 10, midiCC: 38, label: "Snare"),
            createConfiguredComponent(.drumPadMinimal1, position: CGPoint(x: 300, y: 400), 
                                    midiChannel: 10, midiCC: 42, label: "Hi-Hat"),
            createConfiguredComponent(.drumPadMinimal1, position: CGPoint(x: 400, y: 400), 
                                    midiChannel: 10, midiCC: 49, label: "Crash"),
            createConfiguredComponent(.toggleButtonNeumorphic1, position: CGPoint(x: 500, y: 200), 
                                    midiChannel: 1, midiCC: 64, label: "Sustain")
        ]
        
        for component in components {
            canvasStorage.addComponent(component)
        }
    }
    
    // MARK: - Component Configuration Helper
    private static func createConfiguredComponent(
        _ type: AudioUIComponentType,
        position: CGPoint,
        midiChannel: Int,
        midiCC: Int,
        label: String,
        scale: Double = 1.0
    ) -> CanvasComponent {
        var component = CanvasComponent(type: type)
        component.position = position
        component.midiMapping.midiChannel = midiChannel
        component.midiMapping.ccNumber = midiCC
        component.customization.label = label
        component.customization.scale = scale
        return component
    }
    
    // MARK: - MIDI Handling
    static func sendMIDIValue(component: CanvasComponent, value: Double) {
        let midiValue = component.midiMapping.rangeMapping.mapValue(value)
        
        // Send MIDI CC message using component.midiMapping
        let midiEvent = MIDIEvent.cc(
            UInt7(component.midiMapping.ccNumber & 0x7F),
            value: .midi1(UInt7(Int(Double(midiValue) * 127.0) & 0x7F)),
            channel: UInt4(component.midiMapping.midiChannel - 1)
        )
        
        // Try to find a global MIDI helper or manager
        if let midiHelper = findGlobalMIDIHelper() {
            midiHelper.sendComponentMIDI(midiEvent)
        } else {
            print("Sending MIDI: CC\(component.midiMapping.ccNumber) = \(midiValue) on channel \(component.midiMapping.midiChannel)")
        }
    }
    
    private static func findGlobalMIDIHelper() -> MIDIHelper? {
        // This would typically be accessed through a global service locator or dependency injection
        // For now, we'll return nil to use print statements
        return nil
    }
} 