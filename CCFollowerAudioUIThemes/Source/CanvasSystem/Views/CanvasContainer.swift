//
//  CanvasContainer.swift
//  CntrlSuite - Professional Audio Controller
//  © 2025 CohenConcepts • Licensed under MIT License
//

import SwiftUI
import AudioUICore
import AudioUIComponents
import AudioUITheme
import GestureCanvasKit
import MIDIKitIO

// MARK: - Canvas Container with AudioUI Component Rendering
@available(iOS 18.0, macOS 13.0, *)
struct CanvasContainer: View {
    let canvasStorage: EnhancedCanvasStorage
    let storageAdapter: CanvasStorageAdapter
    let isEditMode: Bool
    let isCanvasLocked: Bool
    let showValueLabels: Bool
    @Binding var selectedComponent: CanvasComponent?
    
    let onComponentTap: ((CanvasComponent) -> Void)?
    let onComponentUpdate: ((CanvasComponent) -> Void)?
    
    // Computed properties for GestureCanvasKit integration
    private var components: [CanvasComponentImpl] {
        storageAdapter.gestureComponents
    }
    
    private var delegate: GestureCanvasDelegate? {
        storageAdapter
    }
    
    private var selectionIndicator: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.blue, lineWidth: 2)
            .background(Color.blue.opacity(0.1))
    }
    
    private var customComponentRenderer: ((CanvasComponentImpl) -> AnyView)? {
        { component in
            AnyView(renderAudioUIComponent(component))
        }
    }
    
    // Zoom and Pan state
    @State private var currentZoom: CGFloat = 1.0
    @State private var currentPanOffset: CGSize = .zero
    @State private var lastZoom: CGFloat = 1.0
    @State private var lastPanOffset: CGSize = .zero
    @State private var isAutoArranging = false
    @State private var selectedComponentImpl: CanvasComponentImpl?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gesture layer - captures zoom/pan gestures on empty canvas
                // Only active when canvas is NOT locked
                backgroundGestureLayer(geometry: geometry)
                
                // Content layer with zoom/pan transformations applied
                contentLayer
                
                // Background tap handler for edit mode
                editModeBackgroundTap
                
                // Lock indicator overlay
                lockIndicatorOverlay
            }
        }
        .background(Color.clear)
    }
    
    // MARK: - View Components
    
    private func backgroundGestureLayer(geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .gesture(
                isCanvasLocked ? nil : createZoomAndPanGesture(geometry: geometry)
            )
    }
    
    private var contentLayer: some View {
        ZStack {
            // Component views
            ForEach(components) { component in
                renderComponentView(component)
                    .position(component.position)
                    .scaleEffect(component.customization.scale)
            }
        }
        .scaleEffect(currentZoom)
        .offset(currentPanOffset)
        .allowsHitTesting(true)
    }
    
    private var editModeBackgroundTap: some View {
        Group {
            if isEditMode {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedComponentImpl = nil
                        delegate?.canvasDidSelectComponent(nil)
                    }
                    .allowsHitTesting(true)
                    .zIndex(-1)
            }
        }
    }
    
    private var lockIndicatorOverlay: some View {
        Group {
            if isCanvasLocked {
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("Locked")
                                .font(.caption2.weight(.medium))
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 120)
                    Spacer()
                }
                .zIndex(5)
                .allowsHitTesting(false)
            }
        }
    }
    
    // MARK: - Component Rendering
    
    private func renderComponentView(_ component: CanvasComponentImpl) -> some View {
        ZStack {
            // Selection indicator
            if selectedComponentImpl?.id == component.id && isEditMode {
                selectionIndicator
                    .frame(
                        width: component.size.width + 8,
                        height: component.size.height + 8
                    )
            }
            
            // Actual component - no button wrapper to avoid gesture conflicts
            renderAudioUIComponent(component)
                .frame(width: component.size.width, height: component.size.height)
                .contentShape(Rectangle()) // Ensure hit testing area
                .onTapGesture {
                    if isEditMode {
                        handleComponentTap(component)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: isEditMode ? 5 : 1000) // High threshold when not in edit mode
                        .onChanged { value in
                            if isEditMode {
                                let newPosition = CGPoint(
                                    x: component.position.x + value.translation.width,
                                    y: component.position.y + value.translation.height
                                )
                                delegate?.canvasDidMoveComponent(id: component.id, to: newPosition)
                            }
                        }
                )
        }
    }
    
    private func handleComponentTap(_ component: CanvasComponentImpl) {
        if isEditMode {
            let newSelection = selectedComponentImpl?.id == component.id ? nil : component
            selectedComponentImpl = newSelection
            delegate?.canvasDidSelectComponent(newSelection)
        }
    }
    
    // MARK: - Zoom and Pan Gestures (only active when not locked)
    
    private func createZoomAndPanGesture(geometry: GeometryProxy) -> some Gesture {
        let magnificationGesture = createMagnificationGesture()
        let panGesture = createPanGesture()
        let doubleTapGesture = createDoubleTapGesture(geometry: geometry)
        let tripleTapGesture = createTripleTapGesture(geometry: geometry)
        
        return magnificationGesture
            .simultaneously(with: panGesture)
            .simultaneously(with: doubleTapGesture)
            .simultaneously(with: tripleTapGesture)
    }
    
    private func createMagnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                // Prevent zoom when auto-arranging or locked
                guard !isAutoArranging && !isCanvasLocked else { return }
                
                let newZoom = lastZoom * value
                currentZoom = min(max(newZoom, 0.2), 5.0)
            }
            .onEnded { value in
                lastZoom = currentZoom
            }
    }
    
    private func createPanGesture() -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                // Prevent pan when auto-arranging or locked
                guard !isAutoArranging && !isCanvasLocked else { return }
                
                let newOffset = CGSize(
                    width: lastPanOffset.width + value.translation.width,
                    height: lastPanOffset.height + value.translation.height
                )
                
                let maxOffset: CGFloat = 2000
                currentPanOffset = CGSize(
                    width: min(max(newOffset.width, -maxOffset), maxOffset),
                    height: min(max(newOffset.height, -maxOffset), maxOffset)
                )
            }
            .onEnded { value in
                lastPanOffset = currentPanOffset
            }
    }
    
    private func createDoubleTapGesture(geometry: GeometryProxy) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                // Allow double-tap even when locked for zoom-to-fit functionality
                let centerPoint = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                handleDoubleTap(at: centerPoint, geometry: geometry)
            }
    }
    
    private func createTripleTapGesture(geometry: GeometryProxy) -> some Gesture {
        TapGesture(count: 3)
            .onEnded {
                // Disable triple-tap auto-arrange when locked
                guard !isCanvasLocked else { return }
                arrangeComponentsAutomatically(geometry: geometry)
            }
    }
    
    // MARK: - Double Tap Handling
    
    private func handleDoubleTap(at location: CGPoint, geometry: GeometryProxy) {
        if currentZoom > 1.1 || currentPanOffset != .zero {
            // Reset to fit view
            resetZoomAndPan()
        } else {
            // Zoom to fit all components
            zoomToFitComponents(geometry: geometry)
        }
        
        // Add haptic feedback if available
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
    }
    
    private func zoomToFitComponents(geometry: GeometryProxy) {
        guard !components.isEmpty else {
            resetZoomAndPan()
            return
        }
        
        // Calculate bounding box of all components
        let positions = components.map { $0.position }
        let sizes = components.map { $0.size }
        
        guard let minX = positions.map({ $0.x }).min(),
              let maxX = positions.map({ $0.x }).max(),
              let minY = positions.map({ $0.y }).min(),
              let maxY = positions.map({ $0.y }).max() else {
            resetZoomAndPan()
            return
        }
        
        // Add component sizes to bounds
        let maxWidth = sizes.map { $0.width }.max() ?? 0
        let maxHeight = sizes.map { $0.height }.max() ?? 0
        
        let contentWidth = (maxX - minX) + maxWidth
        let contentHeight = (maxY - minY) + maxHeight
        
        let padding: CGFloat = 50
        let availableWidth = geometry.size.width - padding * 2
        let availableHeight = geometry.size.height - padding * 2
        
        let scaleX = availableWidth / contentWidth
        let scaleY = availableHeight / contentHeight
        let targetZoom = min(scaleX, scaleY, 2.0) // Cap at 2x zoom
        
        // Calculate center offset
        let contentCenterX = (minX + maxX) / 2
        let contentCenterY = (minY + maxY) / 2
        let viewCenterX = geometry.size.width / 2
        let viewCenterY = geometry.size.height / 2
        
        let targetOffset = CGSize(
            width: (viewCenterX - contentCenterX) * targetZoom,
            height: (viewCenterY - contentCenterY) * targetZoom
        )
        
        withAnimation(.easeInOut(duration: 0.5)) {
            currentZoom = targetZoom
            currentPanOffset = targetOffset
            lastZoom = targetZoom
            lastPanOffset = targetOffset
        }
    }
    
    private func resetZoomAndPan() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentZoom = 1.0
            currentPanOffset = .zero
            lastZoom = 1.0
            lastPanOffset = .zero
        }
    }
    
    // MARK: - Auto Arrange
    
    private func arrangeComponentsAutomatically(geometry: GeometryProxy) {
        guard !components.isEmpty else { return }
        
        isAutoArranging = true
        
        // Simple grid arrangement
        let padding: CGFloat = 20
        let columns = Int(sqrt(Double(components.count))) + 1
        let componentWidth: CGFloat = 120
        let componentHeight: CGFloat = 120
        
        let totalWidth = CGFloat(columns) * (componentWidth + padding) - padding
        let startX = (geometry.size.width - totalWidth) / 2
        let startY: CGFloat = 100
        
        withAnimation(.easeInOut(duration: 0.8)) {
            for (index, component) in components.enumerated() {
                let row = index / columns
                let col = index % columns
                
                let x = startX + CGFloat(col) * (componentWidth + padding) + componentWidth / 2
                let y = startY + CGFloat(row) * (componentHeight + padding) + componentHeight / 2
                
                delegate?.canvasDidMoveComponent(id: component.id, to: CGPoint(x: x, y: y))
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isAutoArranging = false
        }
        
        // Add haptic feedback
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        #endif
    }
    
    // MARK: - AudioUI Component Rendering
    
    @ViewBuilder
    private func renderAudioUIComponent(_ component: CanvasComponentImpl) -> some View {
        let audioUIComponent = CanvasComponentAdapter.fromGestureCanvasComponent(component)
        
        switch audioUIComponent.type {
        case .knobMinimal1:
            // Render based on the component's style
            if audioUIComponent.style == "Neumorphic" {
                KnobNeumorphic1(value: Binding(
                    get: { canvasStorage.componentValues[component.id] ?? 0.5 },
                    set: { newValue in 
                        guard !isEditMode else { return }
                        canvasStorage.componentValues[component.id] = newValue
                        sendMIDIForComponent(component, value: newValue)
                    }
                ))
                .allowsHitTesting(!isEditMode)
            } else if audioUIComponent.style == "Dotted" {
                KnobDotted1(value: Binding(
                    get: { canvasStorage.componentValues[component.id] ?? 0.5 },
                    set: { newValue in 
                        guard !isEditMode else { return }
                        canvasStorage.componentValues[component.id] = newValue
                        sendMIDIForComponent(component, value: newValue)
                    }
                ))
                .allowsHitTesting(!isEditMode)
            } else {
                KnobMinimal1(value: Binding(
                    get: { canvasStorage.componentValues[component.id] ?? 0.5 },
                    set: { newValue in 
                        guard !isEditMode else { return }
                        canvasStorage.componentValues[component.id] = newValue
                        sendMIDIForComponent(component, value: newValue)
                    }
                ))
                .allowsHitTesting(!isEditMode)
            }
        case .sliderMinimal1:
            // Render based on the component's style
            if audioUIComponent.style == "Neumorphic" {
                SliderNeumorphic1(value: Binding(
                    get: { canvasStorage.componentValues[component.id] ?? 0.5 },
                    set: { newValue in 
                        guard !isEditMode else { return }
                        canvasStorage.componentValues[component.id] = newValue
                        sendMIDIForComponent(component, value: newValue)
                    }
                ))
                .allowsHitTesting(!isEditMode)
            } else if audioUIComponent.style == "Dotted" {
                SliderDotted1(value: Binding(
                    get: { canvasStorage.componentValues[component.id] ?? 0.5 },
                    set: { newValue in 
                        guard !isEditMode else { return }
                        canvasStorage.componentValues[component.id] = newValue
                        sendMIDIForComponent(component, value: newValue)
                    }
                ))
                .allowsHitTesting(!isEditMode)
            } else {
                SliderMinimal1(value: Binding(
                    get: { canvasStorage.componentValues[component.id] ?? 0.5 },
                    set: { newValue in 
                        guard !isEditMode else { return }
                        canvasStorage.componentValues[component.id] = newValue
                        sendMIDIForComponent(component, value: newValue)
                    }
                ))
                .allowsHitTesting(!isEditMode)
            }
        case .xyPadMinimal1:
            XYPadMinimal1(value: Binding(
                get: { 
                    let storedX = canvasStorage.componentValues[component.id] ?? 0.5
                    // Create a consistent Y storage key using a simple string-based approach
                    let yStorageKey = "\(component.id.uuidString)-Y"
                    let storedY = canvasStorage.xyPadYValues[yStorageKey] ?? 0.5
                    return CGPoint(x: storedX, y: storedY)
                },
                set: { newValue in
                    guard !isEditMode else { return }
                    canvasStorage.componentValues[component.id] = newValue.x
                    // Store Y value using a string-based key
                    let yStorageKey = "\(component.id.uuidString)-Y"
                    canvasStorage.xyPadYValues[yStorageKey] = newValue.y
                    // Send MIDI for both X and Y values
                    sendMIDIForComponent(component, value: newValue.x)
                    // For XY pads, send Y as a separate CC
                    sendMIDIForComponentY(component, value: newValue.y)
                }
            ))
            .allowsHitTesting(!isEditMode)
        case .drumPadMinimal1:
            DrumPadMinimal1()
                .allowsHitTesting(!isEditMode)
                .onTapGesture {
                    guard !isEditMode else { return }
                    // Trigger action for drum pad
                    canvasStorage.componentValues[component.id] = 1.0
                    sendMIDIForComponent(component, value: 1.0)
                    // Reset after brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        canvasStorage.componentValues[component.id] = 0.0
                    }
                }
        case .toggleButtonNeumorphic1:
            ToggleButtonNeumorphic1(
                isOn: Binding(
                    get: { canvasStorage.componentValues[component.id] ?? 0.0 > 0.5 },
                    set: { newValue in
                        guard !isEditMode else { return }
                        canvasStorage.componentValues[component.id] = newValue ? 1.0 : 0.0
                        sendMIDIForComponent(component, value: newValue ? 1.0 : 0.0)
                    }
                ),
                onIcon: "power",
                offIcon: "power"
            )
            .allowsHitTesting(!isEditMode)
        case .gyroMinimal:
            GyroMinimal(rotation: .constant(GyroRotation.zero))
                .allowsHitTesting(!isEditMode)
        }
    }
    
    // MARK: - MIDI Output Helper
    private func sendMIDIForComponent(_ component: CanvasComponentImpl, value: Double) {
        // Convert the GestureCanvasKit component back to our CanvasComponent to get MIDI mapping
        let audioUIComponent = CanvasComponentAdapter.fromGestureCanvasComponent(component)
        let midiMapping = audioUIComponent.midiMapping
        
        // Convert normalized value (0.0-1.0) to MIDI value (0-127)
        let midiValue = Int(value * 127.0)
        
        // Send MIDI data using MIDIKit
        do {
            let midiEvent = MIDIEvent.cc(
                UInt7(midiMapping.ccNumber & 0x7F), // Convert to UInt7 and ensure it's within valid range
                value: .midi1(UInt7(midiValue & 0x7F)), // Ensure MIDI value is within valid range
                channel: UInt4(midiMapping.midiChannel - 1) // MIDIKit uses 0-based channels
            )
            
            // Access MIDI manager through proper dependency injection pattern
            // Look for a MIDI helper in the environment or use a shared instance
            if let midiHelper = findMIDIHelper() {
                midiHelper.sendComponentMIDI(midiEvent)
            } else {
                print("MIDI CC: Channel \(midiMapping.midiChannel), CC \(midiMapping.ccNumber), Value \(midiValue)")
            }
        } catch {
            print("Failed to send MIDI: \(error)")
        }
    }
    
    private func sendMIDIForComponentY(_ component: CanvasComponentImpl, value: Double) {
        // For XY pads, send Y value on CC+1
        let audioUIComponent = CanvasComponentAdapter.fromGestureCanvasComponent(component)
        let midiMapping = audioUIComponent.midiMapping
        
        // Convert normalized value (0.0-1.0) to MIDI value (0-127)
        let midiValue = Int(value * 127.0)
        
        // Send MIDI data using MIDIKit for Y axis (CC + 1)
        do {
            let midiEvent = MIDIEvent.cc(
                UInt7((midiMapping.ccNumber + 1) & 0x7F), // Y axis uses CC+1
                value: .midi1(UInt7(midiValue & 0x7F)),
                channel: UInt4(midiMapping.midiChannel - 1)
            )
            
            if let midiHelper = findMIDIHelper() {
                midiHelper.sendComponentMIDI(midiEvent)
            } else {
                print("MIDI CC Y: Channel \(midiMapping.midiChannel), CC \(midiMapping.ccNumber + 1), Value \(midiValue)")
            }
        } catch {
            print("Failed to send MIDI Y: \(error)")
        }
    }
    
    private func findMIDIHelper() -> MIDIHelper? {
        // This would typically be injected through environment or dependency injection
        // For now, we'll return nil to use print statements
        return nil
    }
}

