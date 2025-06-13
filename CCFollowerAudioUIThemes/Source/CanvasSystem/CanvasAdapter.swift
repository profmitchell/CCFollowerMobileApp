//
//  CanvasAdapter.swift
//  CntrlSuite - Professional Audio Controller
//  © 2025 CohenConcepts • Licensed under MIT License
//

import SwiftUI
import AudioUIComponents
import GestureCanvasKit

// MARK: - Sendable Wrappers for GestureCanvasKit Types

// A sendable wrapper for non-sendable ClosedRange
private struct SendableClosedRange<Bound: Comparable & Sendable> {
    let lowerBound: Bound
    let upperBound: Bound

    init(_ range: ClosedRange<Bound>) {
        self.lowerBound = range.lowerBound
        self.upperBound = range.upperBound
    }

    func toClosedRange() -> ClosedRange<Bound> {
        return lowerBound...upperBound
    }
}

// A sendable wrapper for GestureCanvasKit.EnhancedRangeMapping
private struct SendableEnhancedRangeMapping {
    let inputRange: SendableClosedRange<Double>
    let outputRange: SendableClosedRange<Double>
    let curve: MappingCurveType
    let invertOutput: Bool
    let quantizeSteps: Int?

    init(_ mapping: GestureCanvasKit.EnhancedRangeMapping) {
        self.inputRange = SendableClosedRange(mapping.inputRange)
        self.outputRange = SendableClosedRange(mapping.outputRange)
        self.curve = mapping.curve
        self.invertOutput = mapping.invertOutput
        self.quantizeSteps = mapping.quantizeSteps
    }

    func toEnhancedRangeMapping() -> GestureCanvasKit.EnhancedRangeMapping {
        return GestureCanvasKit.EnhancedRangeMapping(
            inputRange: inputRange.toClosedRange(),
            outputRange: outputRange.toClosedRange(),
            curve: curve,
            invertOutput: invertOutput,
            quantizeSteps: quantizeSteps
        )
    }
}

// A sendable wrapper for GestureCanvasKit.InteractionDestination
private struct SendableInteractionDestination {
    let id: UUID
    let channel: Int
    let parameter: Int
    let noteNumber: Int?
    let midiMessageType: MIDIMessageType
    let rangeMapping: SendableEnhancedRangeMapping
    let isEnabled: Bool
    let label: String

    init(_ destination: GestureCanvasKit.InteractionDestination) {
        self.id = destination.id
        self.channel = destination.channel
        self.parameter = destination.parameter
        self.noteNumber = destination.noteNumber
        self.midiMessageType = destination.midiMessageType
        self.rangeMapping = SendableEnhancedRangeMapping(destination.rangeMapping)
        self.isEnabled = destination.isEnabled
        self.label = destination.label
    }

    func toInteractionDestination() -> GestureCanvasKit.InteractionDestination {
        var dest = GestureCanvasKit.InteractionDestination(
            channel: channel,
            parameter: parameter,
            noteNumber: noteNumber,
            midiMessageType: midiMessageType,
            rangeMapping: rangeMapping.toEnhancedRangeMapping(),
            isEnabled: isEnabled,
            label: label
        )
        dest.id = self.id
        return dest
    }
}

// A sendable wrapper for GestureCanvasKit.InteractionMapping
private struct SendableInteractionMapping {
    let destinations: [SendableInteractionDestination]
    let isEnabled: Bool

    init(_ mapping: GestureCanvasKit.InteractionMapping) {
        self.destinations = mapping.destinations.map(SendableInteractionDestination.init)
        self.isEnabled = mapping.isEnabled
    }

    func toInteractionMapping() -> GestureCanvasKit.InteractionMapping {
        return GestureCanvasKit.InteractionMapping(
            destinations: destinations.map { $0.toInteractionDestination() },
            isEnabled: isEnabled
        )
    }
}

// A sendable struct to safely pass component data across actor boundaries
private struct SendableCustomization {
    let color: String
    let scale: Double
    let label: String
    
    init(_ customization: GestureCanvasKit.ComponentCustomization) {
        self.color = customization.color
        self.scale = customization.scale
        self.label = customization.label
    }
    
    func toComponentCustomization() -> GestureCanvasKit.ComponentCustomization {
        return GestureCanvasKit.ComponentCustomization(color: self.color, scale: self.scale, label: self.label)
    }
}

private struct SendableCanvasComponent {
    let id: UUID
    let typeRawValue: String
    let position: CGPoint
    let size: CGSize
    let interactionMapping: SendableInteractionMapping
    let customization: SendableCustomization
    
    init(_ component: CanvasComponentImpl) {
        self.id = component.id
        self.typeRawValue = component.type.rawValue
        self.position = component.position
        self.size = component.size
        self.interactionMapping = SendableInteractionMapping(component.interactionMapping)
        self.customization = SendableCustomization(component.customization)
    }
    
    func toCanvasComponentImpl() -> CanvasComponentImpl? {
        guard let type = CanvasComponentImpl.ComponentType(rawValue: typeRawValue) else {
            return nil
        }
        var impl = CanvasComponentImpl(
            type: type,
            position: self.position,
            size: self.size,
            interactionMapping: self.interactionMapping.toInteractionMapping(),
            customization: self.customization.toComponentCustomization()
        )
        impl.id = self.id
        return impl
    }
}

// MARK: - Canvas Component Adapter
/// Bridges between our CanvasComponent and GestureCanvasKit's CanvasComponentImpl
@MainActor
class CanvasComponentAdapter {
    
    // MARK: - Type Mapping
    static func mapComponentType(_ audioUIType: AudioUIComponentType) -> CanvasComponentImpl.ComponentType {
        switch audioUIType {
        case .knobMinimal1:
            return .knob
        case .sliderMinimal1:
            return .sliderVertical
        case .xyPadMinimal1:
            return .xyPad
        case .drumPadMinimal1:
            return .padGrid
        case .toggleButtonNeumorphic1:
            return .knob // Use knob for toggle behavior
        case .gyroMinimal:
            return .motionControl
        }
    }
    
    static func mapComponentTypeBack(_ gestureType: CanvasComponentImpl.ComponentType) -> AudioUIComponentType {
        switch gestureType {
        case .knob:
            return .knobMinimal1
        case .sliderVertical:
            return .sliderMinimal1
        case .sliderHorizontal:
            return .sliderMinimal1
        case .xyPad:
            return .xyPadMinimal1
        case .padGrid:
            return .drumPadMinimal1
        case .motionControl:
            return .gyroMinimal
        case .crossfader:
            return .sliderMinimal1
        case .modulationWheel, .pitchBend:
            return .sliderMinimal1
        }
    }
    
    // MARK: - Component Conversion
    static func toGestureCanvasComponent(_ canvasComponent: CanvasComponent) -> CanvasComponentImpl {
        let gestureType = mapComponentType(canvasComponent.type)
        
        // Convert MIDI mapping to interaction mapping
        let interactionDestination = InteractionDestination(
            channel: canvasComponent.midiMapping.midiChannel,
            parameter: canvasComponent.midiMapping.ccNumber,
            noteNumber: canvasComponent.midiMapping.noteNumber,
            midiMessageType: .controlChange,
            rangeMapping: EnhancedRangeMapping(
                inputRange: canvasComponent.midiMapping.rangeMapping.inputLow...canvasComponent.midiMapping.rangeMapping.inputHigh,
                outputRange: Double(canvasComponent.midiMapping.rangeMapping.outputLow)...Double(canvasComponent.midiMapping.rangeMapping.outputHigh)
            ),
            isEnabled: true,
            label: "STYLE:\(canvasComponent.style)|\(canvasComponent.customization.label)" // Store style with clear prefix
        )
        
        let interactionMapping = InteractionMapping(
            destinations: [interactionDestination],
            isEnabled: true
        )
        
        var gestureComponent = CanvasComponentImpl(
            type: gestureType,
            position: canvasComponent.position,
            size: canvasComponent.size,
            interactionMapping: interactionMapping,
            customization: canvasComponent.customization // Direct assignment
        )
        
        // Preserve the original ID for tracking
        gestureComponent.id = canvasComponent.id
        
        return gestureComponent
    }
    
    static func fromGestureCanvasComponent(_ gestureComponent: CanvasComponentImpl) -> CanvasComponent {
        let audioUIType = mapComponentTypeBack(gestureComponent.type)
        
        // Convert interaction mapping back to MIDI mapping
        let firstDestination = gestureComponent.interactionMapping.destinations.first ?? InteractionDestination()
        
        let rangeMapping = RangeMapping(
            inputLow: firstDestination.rangeMapping.inputRange.lowerBound,
            inputHigh: firstDestination.rangeMapping.inputRange.upperBound,
            outputLow: Int(firstDestination.rangeMapping.outputRange.lowerBound),
            outputHigh: Int(firstDestination.rangeMapping.outputRange.upperBound)
        )
        
        var midiMapping = MIDIMapping(
            ccNumber: firstDestination.parameter,
            midiChannel: firstDestination.channel,
            noteNumber: firstDestination.noteNumber
        )
        midiMapping.rangeMapping = rangeMapping
        
        // Extract style from the interaction destination label
        let style = extractStyleFromLabel(firstDestination.label) ?? "Minimal"
        
        var canvasComponent = CanvasComponent(type: audioUIType, position: gestureComponent.position, style: style)
        canvasComponent.id = gestureComponent.id
        canvasComponent.size = gestureComponent.size
        canvasComponent.midiMapping = midiMapping
        canvasComponent.customization = gestureComponent.customization // Direct assignment
        
        return canvasComponent
    }
    
    // Helper function to extract style from label with STYLE: prefix
    private static func extractStyleFromLabel(_ label: String) -> String? {
        if label.hasPrefix("STYLE:") {
            let components = label.components(separatedBy: "|")
            if let styleComponent = components.first {
                let style = String(styleComponent.dropFirst(6)) // Remove "STYLE:" prefix
                return style.isEmpty ? nil : style
            }
        }
        // Fallback to old method for backward compatibility
        if label.contains("Neumorphic") { return "Neumorphic" }
        if label.contains("Dotted") { return "Dotted" }
        if label.contains("Minimal") { return "Minimal" }
        return nil
    }
}

// MARK: - Canvas Storage Adapter
@MainActor
class CanvasStorageAdapter: ObservableObject, GestureCanvasDelegate {
    @Published var gestureComponents: [CanvasComponentImpl] = []
    @Published var selectedGestureComponent: CanvasComponentImpl?
    
    // Reference to original storage for synchronization
    private let originalStorage: EnhancedCanvasStorage
    
    init(originalStorage: EnhancedCanvasStorage) {
        self.originalStorage = originalStorage
        syncFromOriginal()
    }
    
    // MARK: - Synchronization
    func syncFromOriginal() {
        gestureComponents = originalStorage.components.map { 
            CanvasComponentAdapter.toGestureCanvasComponent($0)
        }
    }
    
    func syncToOriginal() {
        let convertedComponents = gestureComponents.map {
            CanvasComponentAdapter.fromGestureCanvasComponent($0)
        }
        
        // Update original storage
        originalStorage.components = convertedComponents
        
        // Sync component values
        for gestureComponent in gestureComponents {
            if originalStorage.componentValues[gestureComponent.id] != nil {
                // Value is already synced through delegate calls
                continue
            }
        }
    }
    
    // MARK: - GestureCanvasDelegate Implementation
    nonisolated func canvasDidUpdateComponent(_ component: CanvasComponentImpl) {
        let sendableComponent = SendableCanvasComponent(component)
        // Update the gesture component
        Task { @MainActor in
            guard let receivedComponent = sendableComponent.toCanvasComponentImpl() else { return }
            if let index = gestureComponents.firstIndex(where: { $0.id == receivedComponent.id }) {
                gestureComponents[index] = receivedComponent
            }
            
            // Sync back to original storage
            let originalComponent = CanvasComponentAdapter.fromGestureCanvasComponent(receivedComponent)
            originalStorage.updateComponent(originalComponent)
        }
    }
    
    nonisolated func canvasDidMoveComponent(id: UUID, to position: CGPoint) {
        // Update gesture component position
        Task { @MainActor in
            if let index = gestureComponents.firstIndex(where: { $0.id == id }) {
                gestureComponents[index].position = position
            }
            
            // Sync to original storage
            originalStorage.moveComponent(id: id, to: position)
        }
    }
    
    nonisolated func canvasDidSelectComponent(_ component: CanvasComponentImpl?) {
        let sendableComponent = component.map(SendableCanvasComponent.init)
        Task { @MainActor in
            selectedGestureComponent = sendableComponent?.toCanvasComponentImpl()
        }
    }
    
    nonisolated func canvasDidRequestComponentConfiguration(for component: CanvasComponentImpl) {
        let sendableComponent = SendableCanvasComponent(component)
        Task { @MainActor in
            selectedGestureComponent = sendableComponent.toCanvasComponentImpl()
        }
    }
    
    // MARK: - Component Management
    func addComponent(_ component: CanvasComponent) {
        let gestureComponent = CanvasComponentAdapter.toGestureCanvasComponent(component)
        gestureComponents.append(gestureComponent)
        originalStorage.addComponent(component)
    }
    
    func removeComponent(id: UUID) {
        gestureComponents.removeAll { $0.id == id }
        originalStorage.removeComponent(id: id)
    }
    
    func clearCanvas() {
        gestureComponents.removeAll()
        originalStorage.clearCanvas()
    }
} 
