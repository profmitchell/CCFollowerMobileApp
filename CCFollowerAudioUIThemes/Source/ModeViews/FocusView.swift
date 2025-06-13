//
//  FocusView.swift
//  CntrlSuite
//

import SwiftUI
import AudioUICore
import AudioUITheme
import AudioUIComponents
import MappingKit
import MIDIKitIO

// MARK: - MIDI Value Wheel
struct MIDIValueWheel: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    @Environment(\.theme) private var theme
    @State private var isDragging = false
    @State private var dragStart: CGFloat = 0
    @State private var valueStart: Int = 0
    
    var body: some View {
        VStack(spacing: 8) {
            Text("MIDI Value")
                .font(.caption)
                .foregroundColor(theme.look.textSecondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.look.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isDragging ? theme.look.accent : theme.look.glassBorder, lineWidth: isDragging ? 2 : 1)
                    )
                    .frame(height: 60)
                
                Text("\(value)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(theme.look.textPrimary)
                    .scaleEffect(isDragging ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isDragging)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        if !isDragging {
                            isDragging = true
                            dragStart = drag.location.y
                            valueStart = value
                        }
                        
                        let deltaY = dragStart - drag.location.y
                        let sensitivity: Double = 0.5
                        let newValue = valueStart + Int(deltaY * sensitivity)
                        value = max(range.lowerBound, min(range.upperBound, newValue))
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            
            Text("\(range.lowerBound) - \(range.upperBound)")
                .font(.caption2)
                .foregroundColor(theme.look.textTertiary)
        }
    }
}

// MARK: - Enhanced Component Style Selector (Non-Interactive Previews)
struct ComponentStyleSelector: View {
    let componentType: AudioUIComponentType
    @Binding var selectedStyle: String
    @Environment(\.theme) private var theme
    
    private let availableStyles: [String] = ["Minimal", "Neumorphic", "Dotted"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Component Style")
                .font(.headline)
                .foregroundColor(theme.look.textPrimary)
            
            HStack(spacing: 12) {
                ForEach(availableStyles, id: \.self) { style in
                    Button(action: {
                        selectedStyle = style
                    }) {
                        VStack(spacing: 8) {
                            // NON-INTERACTIVE style preview
                            nonInteractiveStylePreview(for: componentType, style: style)
                                .frame(width: 50, height: 50)
                                .clipped()
                                .allowsHitTesting(false) // Disable all interactions
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(theme.look.surfaceElevated)
                                )
                            
                            Text(style)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedStyle == style ? .white : theme.look.textPrimary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 90) // Better hit area
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedStyle == style ? theme.look.accent : theme.look.surfaceElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedStyle == style ? theme.look.accent : theme.look.glassBorder, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - NON-INTERACTIVE Style Preview (Visual Only)
    @ViewBuilder
    private func nonInteractiveStylePreview(for componentType: AudioUIComponentType, style: String) -> some View {
        Group {
            switch componentType {
            case .knobMinimal1:
                if style == "Neumorphic" {
                    KnobNeumorphic1(value: .constant(0.5))
                        .scaleEffect(0.5)
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    KnobDotted1(value: .constant(0.5))
                        .scaleEffect(0.5)
                        .allowsHitTesting(false)
                } else {
                    KnobMinimal1(value: .constant(0.5))
                        .scaleEffect(0.5)
                        .allowsHitTesting(false)
                }
            case .sliderMinimal1:
                if style == "Neumorphic" {
                    SliderNeumorphic1(value: .constant(0.5))
                        .scaleEffect(0.3)
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    SliderDotted1(value: .constant(0.5))
                        .scaleEffect(0.3)
                        .allowsHitTesting(false)
                } else {
                    SliderMinimal1(value: .constant(0.5))
                        .scaleEffect(0.3)
                        .allowsHitTesting(false)
                }
            case .xyPadMinimal1:
                if style == "Neumorphic" {
                    XYPadNeumorphic1(value: .constant(CGPoint(x: 0.5, y: 0.5)))
                        .scaleEffect(0.4)
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    XYPadDotted1(value: .constant(CGPoint(x: 0.5, y: 0.5)))
                        .scaleEffect(0.4)
                        .allowsHitTesting(false)
                } else {
                    XYPadMinimal1(value: .constant(CGPoint(x: 0.5, y: 0.5)))
                        .scaleEffect(0.4)
                        .allowsHitTesting(false)
                }
            case .drumPadMinimal1:
                if style == "Neumorphic" {
                    DrumPadNeumorphic1()
                        .scaleEffect(0.3)
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    DrumPadDotted1()
                        .scaleEffect(0.3)
                        .allowsHitTesting(false)
                } else {
                    DrumPadMinimal1()
                        .scaleEffect(0.3)
                        .allowsHitTesting(false)
                }
            case .toggleButtonNeumorphic1:
                if style == "Dotted" {
                    ButtonDotted1(isOn: .constant(false), icon: "power", label: "PWR")
                        .scaleEffect(0.4)
                        .allowsHitTesting(false)
                } else if style == "Minimal" {
                    ButtonMinimal1(isOn: .constant(false), icon: "power", label: "PWR")
                        .scaleEffect(0.4)
                        .allowsHitTesting(false)
                } else {
                    ToggleButtonNeumorphic1(isOn: .constant(false), onIcon: "power", offIcon: "power")
                        .scaleEffect(0.4)
                        .allowsHitTesting(false)
                }
            case .gyroMinimal:
                if style == "Neumorphic" {
                    GyroNeumorphic1(rotation: .constant(GyroRotation.zero))
                        .scaleEffect(0.25)
                        .clipped()
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    GyroDotted1(rotation: .constant(GyroRotation.zero))
                        .scaleEffect(0.25)
                        .clipped()
                        .allowsHitTesting(false)
                } else {
                    GyroMinimal(rotation: .constant(GyroRotation.zero))
                        .scaleEffect(0.25)
                        .clipped()
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

// MARK: - Focus View States
enum FocusViewState {
    case configuration
    case zenMode
}

// MARK: - Focus View
struct FocusView: View {
    @Environment(\.theme) private var theme
    @Environment(MIDIHelper.self) private var midiHelper
    @State private var currentState: FocusViewState = .configuration
    @State private var selectedComponentType: AudioUIComponentType? = nil
    @State private var selectedStyle: String = "Minimal"

    @State private var midiChannel: Int = 1
    @State private var midiCC: Int = 1
    @State private var componentValue: Double = 0.5
    @State private var showingMIDIConfig = false
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            switch currentState {
            case .configuration:
                configurationView
            case .zenMode:
                zenModeView
            }
            
            // No floating navigation - handled by parent
        }
        .navigationBarHidden(true)
    }
    
    private var navigationTitle: String {
        switch currentState {
        case .configuration:
            return "Focus Mode"
        case .zenMode:
            return "Zen Mode"
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                theme.look.backgroundPrimary,
                theme.look.backgroundSecondary.opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea(.all) // Expand infinitely without clipping
    }
    
    // MARK: - Configuration View
    private var configurationView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top spacer for unified header
                Spacer()
                    .frame(height: 80)
                
                // Header
                headerSection
                
                // Component Selection Cards - Show immediately
                componentSelectionCards
                
                // Component Preview and Configuration (only show when component is selected)
                if selectedComponentType != nil {
                    componentPreviewSection
                    
                    // MIDI Configuration
                    midiConfigurationSection
                    
                    // Continue Button
                    Button("Enter Zen Mode") {
                        withAnimation(.spring()) {
                            currentState = .zenMode
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(theme: theme))
                    .disabled(selectedComponentType == nil)
                }
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20) // Reduced padding for better fit
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Zen Mode View
    private var zenModeView: some View {
        ZStack {
            // Zen background - minimal and calm
            backgroundGradient
                .overlay(
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                )
            
            VStack(spacing: 0) {
                Spacer()
                
                // Main component interaction area
                if let componentType = selectedComponentType {
                    VStack(spacing: 40) {
                        // Component name (smaller, less intrusive)
                        Text(componentDisplayName(componentType))
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(theme.look.textPrimary)
                            .opacity(0.8)
                        
                        // Large component for interaction - WITH STYLE SUPPORT
                        interactiveComponentPreview(for: componentType, style: selectedStyle)
                            .scaleEffect(1.5) // Reduced from 2.0 for better screen fit
                            .frame(width: 200, height: 200) // Added width constraint
                            .padding(.horizontal, 40) // Add horizontal padding
                            .onChange(of: componentValue) { oldValue, newValue in
                                sendMIDIValue(newValue)
                            }
                        
                        // Minimal MIDI value display
                        Text("\(Int(componentValue * 127))")
                            .font(.system(size: 32, weight: .light, design: .monospaced))
                            .foregroundColor(theme.look.accent)
                            .opacity(0.9)
                    }
                }
                
                Spacer()
            }
            
            // Floating controls (show/hide with gesture or timer)
            zenModeControls
        }
        .navigationBarHidden(true)
        .statusBarHidden(true)
        .ignoresSafeArea()
    }
    
    @State private var showZenControls = true
    @State private var zenControlsTimer: Timer?
    
    private var zenModeControls: some View {
        VStack {
            // Top controls - just MIDI info since navigation is handled by unified header
            HStack {
                // Config button (to switch back from zen to config)
                Button(action: {
                    withAnimation(.spring()) {
                        currentState = .configuration
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 12, weight: .medium))
                        Text("Config")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(theme.look.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(theme.look.glassBorder.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // MIDI info display
                HStack(spacing: 12) {
                    Text("Ch \(midiChannel)")
                        .font(.caption)
                        .foregroundColor(theme.look.textSecondary)
                    
                    Text("CC \(midiCC)")
                        .font(.caption)
                        .foregroundColor(theme.look.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(theme.look.glassBorder.opacity(0.3), lineWidth: 1)
                            )
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            // Bottom controls
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showZenControls.toggle()
                    }
                    resetZenControlsTimer()
                }) {
                    Image(systemName: showZenControls ? "eye.slash" : "eye")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.look.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(theme.look.glassBorder.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .opacity(showZenControls ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.3), value: showZenControls)
        .onAppear {
            resetZenControlsTimer()
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                showZenControls = true
            }
            resetZenControlsTimer()
        }
    }
    
    private func resetZenControlsTimer() {
        zenControlsTimer?.invalidate()
        zenControlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showZenControls = false
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Single Component Focus")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.look.textPrimary)
            
            Text("Configure one component with dedicated MIDI mapping")
                .font(.subheadline)
                .foregroundColor(theme.look.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Enhanced Component Selection Cards (Non-Interactive Previews)
    private var componentSelectionCards: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Component")
                .font(.headline)
                .foregroundColor(theme.look.textPrimary)
            
            // Component type grid - 2 columns for better fit, NON-INTERACTIVE previews
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(AudioUIComponentType.allCases, id: \.id) { componentType in
                    Button(action: {
                        selectedComponentType = componentType
                        selectedStyle = "Minimal" // Reset style when changing component
                    }) {
                        VStack(spacing: 12) {
                            // NON-INTERACTIVE Component preview
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.look.surfaceElevated)
                                    .frame(width: 60, height: 60)
                                
                                nonInteractiveComponentMiniPreview(for: componentType)
                                    .frame(width: 50, height: 50)
                                    .clipped()
                                    .allowsHitTesting(false) // Disable all interactions
                            }
                            
                            Text(componentDisplayName(componentType))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedComponentType == componentType ? theme.look.textPrimary : theme.look.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(minHeight: 100) // Better hit area
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedComponentType == componentType ? theme.look.accent.opacity(0.2) : theme.look.surfaceElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedComponentType == componentType ? theme.look.accent : theme.look.glassBorder, lineWidth: selectedComponentType == componentType ? 2 : 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Style selector (show when component is selected)
            if selectedComponentType != nil {
                ComponentStyleSelector(
                    componentType: selectedComponentType!,
                    selectedStyle: $selectedStyle
                )
            }
        }
    }
    
    // Better component type names
    private func componentDisplayName(_ type: AudioUIComponentType) -> String {
        switch type {
        case .knobMinimal1: return "Knob"
        case .sliderMinimal1: return "Slider"
        case .xyPadMinimal1: return "XY Pad"
        case .drumPadMinimal1: return "Drum Pad"
        case .toggleButtonNeumorphic1: return "Button"
        case .gyroMinimal: return "Gyro"
        }
    }
    
    // MARK: - NON-INTERACTIVE Component Mini Preview (Visual Only)
    @ViewBuilder
    private func nonInteractiveComponentMiniPreview(for componentType: AudioUIComponentType) -> some View {
        Group {
            switch componentType {
            case .knobMinimal1:
                KnobMinimal1(value: .constant(0.5))
                    .scaleEffect(0.5)
                    .allowsHitTesting(false)
            case .sliderMinimal1:
                SliderMinimal1(value: .constant(0.5))
                    .scaleEffect(0.3)
                    .allowsHitTesting(false)
            case .xyPadMinimal1:
                XYPadMinimal1(value: .constant(CGPoint(x: 0.5, y: 0.5)))
                    .scaleEffect(0.4)
                    .allowsHitTesting(false)
            case .drumPadMinimal1:
                DrumPadMinimal1()
                    .scaleEffect(0.3)
                    .allowsHitTesting(false)
            case .toggleButtonNeumorphic1:
                ToggleButtonNeumorphic1(isOn: .constant(false), onIcon: "power", offIcon: "power")
                    .scaleEffect(0.4)
                    .allowsHitTesting(false)
            case .gyroMinimal:
                GyroMinimal(rotation: .constant(GyroRotation.zero))
                    .scaleEffect(0.25)
                    .clipped()
                    .allowsHitTesting(false)
            }
        }
    }
    
    // MARK: - Component Preview Section
    private var componentPreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(theme.look.textPrimary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.look.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.look.glassBorder, lineWidth: 1)
                    )
                    .frame(height: 120) // Reduced from 140
                
                if let componentType = selectedComponentType {
                    // NON-INTERACTIVE preview that updates with style selection
                    nonInteractiveComponentPreview(for: componentType, style: selectedStyle)
                        .scaleEffect(0.7) // Reduced from 0.8 for better fit
                        .allowsHitTesting(false) // Disable all interactions
                }
            }
        }
    }
    
    // MARK: - MIDI Configuration Section
    private var midiConfigurationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("MIDI Configuration")
                .font(.headline)
                .foregroundColor(theme.look.textPrimary)
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    MIDIValueWheel(value: $midiChannel, range: 1...16)
                        .overlay(
                            Text("Channel")
                                .font(.caption)
                                .foregroundColor(theme.look.textSecondary)
                                .offset(y: -40)
                        )
                    
                    MIDIValueWheel(value: $midiCC, range: 0...127)
                        .overlay(
                            Text("CC Number")
                                .font(.caption)
                                .foregroundColor(theme.look.textSecondary)
                                .offset(y: -40)
                        )
                }
                
                // Test button
                Button(action: {
                    testMIDIOutput()
                }) {
                    Text("Test MIDI Output")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [theme.look.accent, theme.look.accent.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.look.surfaceDeep)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(theme.look.glassBorder.opacity(0.5), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - NON-INTERACTIVE Component Preview (Visual Only)
    @ViewBuilder
    private func nonInteractiveComponentPreview(for componentType: AudioUIComponentType, style: String) -> some View {
        Group {
            switch componentType {
            case .knobMinimal1:
                if style == "Neumorphic" {
                    KnobNeumorphic1(value: .constant(0.5))
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    KnobDotted1(value: .constant(0.5))
                        .allowsHitTesting(false)
                } else {
                    KnobMinimal1(value: .constant(0.5))
                        .allowsHitTesting(false)
                }
            case .sliderMinimal1:
                if style == "Neumorphic" {
                    SliderNeumorphic1(value: .constant(0.5))
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    SliderDotted1(value: .constant(0.5))
                        .allowsHitTesting(false)
                } else {
                    SliderMinimal1(value: .constant(0.5))
                        .allowsHitTesting(false)
                }
            case .xyPadMinimal1:
                if style == "Neumorphic" {
                    XYPadNeumorphic1(value: .constant(CGPoint(x: 0.5, y: 0.5)))
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    XYPadDotted1(value: .constant(CGPoint(x: 0.5, y: 0.5)))
                        .allowsHitTesting(false)
                } else {
                    XYPadMinimal1(value: .constant(CGPoint(x: 0.5, y: 0.5)))
                        .allowsHitTesting(false)
                }
            case .drumPadMinimal1:
                if style == "Neumorphic" {
                    DrumPadNeumorphic1()
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    DrumPadDotted1()
                        .allowsHitTesting(false)
                } else {
                    DrumPadMinimal1()
                        .allowsHitTesting(false)
                }
            case .toggleButtonNeumorphic1:
                if style == "Dotted" {
                    ButtonDotted1(isOn: .constant(false), icon: "power", label: "PWR")
                        .allowsHitTesting(false)
                } else if style == "Minimal" {
                    ButtonMinimal1(isOn: .constant(false), icon: "power", label: "PWR")
                        .allowsHitTesting(false)
                } else {
                    ToggleButtonNeumorphic1(isOn: .constant(false), onIcon: "power", offIcon: "power")
                        .allowsHitTesting(false)
                }
            case .gyroMinimal:
                if style == "Neumorphic" {
                    GyroNeumorphic1(rotation: .constant(GyroRotation.zero))
                        .clipped()
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    GyroDotted1(rotation: .constant(GyroRotation.zero))
                        .clipped()
                        .allowsHitTesting(false)
                } else {
                    GyroMinimal(rotation: .constant(GyroRotation.zero))
                        .clipped()
                        .allowsHitTesting(false)
                }
            }
        }
        .frame(width: 80, height: 80) // Reduced from 100x100 for better fit
    }
    
    // MARK: - INTERACTIVE Component Preview (For Zen Mode) - WITH STYLE SUPPORT
    @ViewBuilder
    private func interactiveComponentPreview(for componentType: AudioUIComponentType, style: String) -> some View {
        Group {
            switch componentType {
            case .knobMinimal1:
                if style == "Neumorphic" {
                    KnobNeumorphic1(value: $componentValue)
                } else if style == "Dotted" {
                    KnobDotted1(value: $componentValue)
                } else {
                    KnobMinimal1(value: $componentValue)
                }
            case .sliderMinimal1:
                if style == "Neumorphic" {
                    SliderNeumorphic1(value: $componentValue)
                } else if style == "Dotted" {
                    SliderDotted1(value: $componentValue)
                } else {
                    SliderMinimal1(value: $componentValue)
                }
            case .xyPadMinimal1:
                if style == "Neumorphic" {
                    XYPadNeumorphic1(value: .constant(CGPoint(x: 0.5, y: 0.5)))
                } else if style == "Dotted" {
                    XYPadDotted1(value: .constant(CGPoint(x: 0.5, y: 0.5)))
                } else {
                    XYPadMinimal1(value: .constant(CGPoint(x: 0.5, y: 0.5)))
                }
            case .drumPadMinimal1:
                if style == "Neumorphic" {
                    DrumPadNeumorphic1()
                } else if style == "Dotted" {
                    DrumPadDotted1()
                } else {
                    DrumPadMinimal1()
                }
            case .toggleButtonNeumorphic1:
                if style == "Dotted" {
                    ButtonDotted1(isOn: .constant(componentValue > 0.5), icon: "power", label: "PWR")
                } else if style == "Minimal" {
                    ButtonMinimal1(isOn: .constant(componentValue > 0.5), icon: "power", label: "PWR")
                } else {
                    ToggleButtonNeumorphic1(isOn: .constant(componentValue > 0.5), onIcon: "power", offIcon: "power")
                }
            case .gyroMinimal:
                if style == "Neumorphic" {
                    GyroNeumorphic1(rotation: .constant(GyroRotation.zero))
                } else if style == "Dotted" {
                    GyroDotted1(rotation: .constant(GyroRotation.zero))
                } else {
                    GyroMinimal(rotation: .constant(GyroRotation.zero))
                }
            }
        }
    }
    
    // MARK: - MIDI Test Function
    private func testMIDIOutput() {
        let midiValue = Int(componentValue * 127)
        print("Testing MIDI: Channel \(midiChannel), CC \(midiCC), Value \(midiValue)")
        
        // Send test MIDI CC message
        let midiData: [UInt8] = [
            UInt8(0xB0 + (midiChannel - 1)), // Control Change + channel
            UInt8(midiCC),                   // CC number
            UInt8(midiValue)                 // CC value
        ]
        
        midiHelper.sendRawMIDI(midiData)
    }
    
    private func sendMIDIValue(_ newValue: Double) {
        let midiValue = Int(newValue * 127)
        let midiData: [UInt8] = [
            UInt8(0xB0 + (midiChannel - 1)), // Control Change + channel
            UInt8(midiCC),                   // CC number
            UInt8(midiValue)                 // CC value
        ]
        midiHelper.sendRawMIDI(midiData)
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    let theme: Theme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [theme.look.accent, theme.look.accent.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    let theme: Theme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(theme.look.textPrimary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.look.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.look.glassBorder, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

 