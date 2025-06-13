//
//  CanvasDataModels.swift
//  CntrlSuite - Professional Audio Controller
//  © 2025 CohenConcepts • Licensed under MIT License
//

import SwiftUI
import AudioUIComponents
import AudioUICore
import AudioUI
import AudioUITheme
import GestureCanvasKit


// MARK: - Canvas Component Data Model
struct CanvasComponent: Identifiable, Codable, Equatable {
    var id = UUID()
    let type: AudioUIComponentType
    var position: CGPoint
    var size: CGSize
    var midiMapping: MIDIMapping
    var customization: GestureCanvasKit.ComponentCustomization
    var style: String // "Minimal", "Neumorphic", or "Dotted"
    
    // Custom coding keys to handle non-Codable properties
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case positionX
        case positionY
        case sizeWidth
        case sizeHeight
        case midiMapping
        case customization
        case style
    }
    
    init(type: AudioUIComponentType, position: CGPoint = CGPoint(x: 200, y: 200), style: String = "Minimal") {
        self.type = type
        self.position = position
        self.size = type.defaultSize
        self.midiMapping = MIDIMapping(ccNumber: 1, midiChannel: 1)
        self.customization = GestureCanvasKit.ComponentCustomization(label: type.displayName)
        self.style = style
    }
    
    // Custom Decodable implementation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(AudioUIComponentType.self, forKey: .type)
        let positionX = try container.decode(CGFloat.self, forKey: .positionX)
        let positionY = try container.decode(CGFloat.self, forKey: .positionY)
        position = CGPoint(x: positionX, y: positionY)
        let sizeWidth = try container.decode(CGFloat.self, forKey: .sizeWidth)
        let sizeHeight = try container.decode(CGFloat.self, forKey: .sizeHeight)
        size = CGSize(width: sizeWidth, height: sizeHeight)
        midiMapping = try container.decode(MIDIMapping.self, forKey: .midiMapping)
        customization = try container.decode(GestureCanvasKit.ComponentCustomization.self, forKey: .customization)
        style = try container.decodeIfPresent(String.self, forKey: .style) ?? "Minimal" // Default for backward compatibility
    }
    
    // Custom Encodable implementation
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
        try container.encode(size.width, forKey: .sizeWidth)
        try container.encode(size.height, forKey: .sizeHeight)
        try container.encode(midiMapping, forKey: .midiMapping)
        try container.encode(customization, forKey: .customization)
        try container.encode(style, forKey: .style)
    }
    
    static func == (lhs: CanvasComponent, rhs: CanvasComponent) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - MIDI Mapping
struct MIDIMapping: Codable {
    var ccNumber: Int
    var midiChannel: Int
    var noteNumber: Int?
    var rangeMapping: RangeMapping
    
    init(ccNumber: Int = 1, midiChannel: Int = 1, noteNumber: Int? = nil) {
        self.ccNumber = ccNumber
        self.midiChannel = midiChannel
        self.noteNumber = noteNumber
        self.rangeMapping = RangeMapping()
    }
}

// MARK: - Range Mapping
struct RangeMapping: Codable {
    var inputLow: Double = 0.0
    var inputHigh: Double = 1.0
    var outputLow: Int = 0
    var outputHigh: Int = 127
    
    func mapValue(_ input: Double) -> Int {
        let normalizedInput = min(max(input, inputLow), inputHigh)
        let inputRange = inputHigh - inputLow
        if inputRange == 0 { return outputLow } // Avoid division by zero
        let outputRange = Double(outputHigh - outputLow)
        let normalizedValue = (normalizedInput - inputLow) / inputRange
        let mappedValue = normalizedValue * outputRange + Double(outputLow)
        return Int(mappedValue.rounded())
    }
}

// MARK: - Component Customization is now handled by GestureCanvasKit.ComponentCustomization

// MARK: - Canvas Storage Management
class EnhancedCanvasStorage: ObservableObject {
    @Published var components: [CanvasComponent] = []
    @Published var componentValues: [UUID: Double] = [:]
    @Published var xyPadYValues: [String: Double] = [:] // Storage for XY pad Y values
    
    func addComponent(_ component: CanvasComponent) {
        withAnimation(.spring()) {
            components.append(component)
            componentValues[component.id] = 0.5
        }
    }
    
    func updateComponent(_ component: CanvasComponent) {
        if let index = components.firstIndex(where: { $0.id == component.id }) {
            withAnimation(.easeInOut(duration: 0.2)) {
                components[index] = component
            }
        }
    }
    
    func removeComponent(id: UUID) {
        withAnimation(.easeOut(duration: 0.3)) {
            components.removeAll { $0.id == id }
            componentValues.removeValue(forKey: id)
            // Clean up XY pad Y values
            let yKey = "\(id.uuidString)-Y"
            xyPadYValues.removeValue(forKey: yKey)
        }
    }
    
    func moveComponent(id: UUID, to position: CGPoint) {
        if let index = components.firstIndex(where: { $0.id == id }) {
            components[index].position = position
        }
    }
    
    func updateComponentValue(id: UUID, value: Double) {
        componentValues[id] = value
    }
    
    func clearCanvas() {
        withAnimation(.easeOut(duration: 0.5)) {
            components.removeAll()
            componentValues.removeAll()
            xyPadYValues.removeAll()
        }
    }
}

// MARK: - Preset Types
enum PresetType {
    case dj, producer, performance
} 
