//
//  ComponentPaletteView.swift
//  CntrlSuite - Professional Audio Controller
//  © 2025 CohenConcepts • Licensed under MIT License
//

import SwiftUI
import AudioUIComponents
import AudioUICore
import AudioUITheme
import GestureCanvasKit

// MARK: - Enhanced Component Palette
struct EnhancedComponentPalette: View {
    let onComponentAdd: (CanvasComponent) -> Void
    @Environment(\.theme) private var theme
    @State private var selectedComponentType: AudioUIComponentType? = nil
    @State private var selectedStyle: String = "Minimal"
    @State private var midiChannel: Int = 1
    @State private var ccNumber: Int = 1
    @State private var componentScale: Double = 1.0
    
    private let componentTypes: [AudioUIComponentType] = [
        .knobMinimal1,
        .sliderMinimal1,
        .xyPadMinimal1,
        .drumPadMinimal1,
        .toggleButtonNeumorphic1,
        .gyroMinimal
    ]
    
    private let availableStyles: [String] = ["Minimal", "Neumorphic", "Dotted"]
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with immediate add button
            headerSection
            
            ScrollView {
                VStack(spacing: 24) {
                    // Component Type Selection with smaller cards
                    componentTypeSection
                    
                    // Style Selection (always visible for easy access)
                    if selectedComponentType != nil {
                        styleSelectionSection
                        
                        // Component Preview
                        componentPreviewSection
                        
                        // MIDI Configuration
                        midiConfigurationSection
                        
                        // Component Properties
                        componentPropertiesSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .background(theme.look.backgroundPrimary)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Add Component")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.look.textPrimary)
                
                Spacer()
                
                // Immediate add button - no extra steps
                if selectedComponentType != nil {
                    Button("Add to Canvas") {
                        addComponentToCanvas()
                    }
                    .buttonStyle(ComponentPalettePrimaryButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Divider()
                .overlay(theme.look.neutralDivider)
        }
    }
    
    // MARK: - Component Type Selection
    private var componentTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Component Type")
                .font(.headline)
                .foregroundColor(theme.look.textPrimary)
            
            // Smaller cards in a 2-column grid for better fit
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(componentTypes, id: \.self) { componentType in
                    componentTypeCard(componentType)
                }
            }
        }
    }
    
    // MARK: - Component Type Card (Smaller, Non-Interactive Preview)
    private func componentTypeCard(_ componentType: AudioUIComponentType) -> some View {
        Button(action: {
            selectedComponentType = componentType
            // Reset configuration when selecting new component
            midiChannel = 1
            ccNumber = 1
            componentScale = 1.0
            selectedStyle = "Minimal"
        }) {
            VStack(spacing: 12) {
                // Component Preview with proper clipping - NON-INTERACTIVE
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(theme.look.surfaceElevated)
                        .frame(width: 60, height: 60)
                    
                    // NON-INTERACTIVE preview - just visual representation
                    nonInteractiveComponentPreview(for: componentType, style: "Minimal")
                        .frame(width: 50, height: 50)
                        .clipped()
                        .allowsHitTesting(false) // Disable all interactions
                }
                
                Text(componentDisplayName(componentType))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.look.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, minHeight: 100) // Smaller but still clickable
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedComponentType == componentType ? theme.look.accent.opacity(0.2) : theme.look.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedComponentType == componentType ? theme.look.accent : theme.look.glassBorder,
                                lineWidth: selectedComponentType == componentType ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Style Selection Section (Improved Clickability)
    private var styleSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Component Style")
                .font(.headline)
                .foregroundColor(theme.look.textPrimary)
            
            HStack(spacing: 12) {
                ForEach(availableStyles, id: \.self) { style in
                    Button(action: {
                        selectedStyle = style
                    }) {
                        Text(style)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedStyle == style ? .white : theme.look.textPrimary)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedStyle == style ? theme.look.accent : theme.look.surfaceElevated)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(theme.look.glassBorder, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Component Preview Section
    private var componentPreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(theme.look.textPrimary)
            
            HStack {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.look.surfaceElevated)
                        .frame(width: 140, height: 140)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(theme.look.glassBorder, lineWidth: 1)
                        )
                    
                    if let componentType = selectedComponentType {
                        // NON-INTERACTIVE preview that updates with style selection
                        nonInteractiveComponentPreview(for: componentType, style: selectedStyle)
                            .frame(width: 120, height: 120)
                            .clipped()
                            .allowsHitTesting(false) // Disable all interactions
                    }
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - MIDI Configuration Section
    private var midiConfigurationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("MIDI Configuration")
                .font(.headline)
                .foregroundColor(theme.look.textPrimary)
            
            HStack(spacing: 24) {
                // MIDI Channel
                VStack(alignment: .leading, spacing: 12) {
                    Text("Channel")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.look.textSecondary)
                    
                    ComponentPaletteCustomStepperStyle(
                        label: "\(midiChannel)",
                        value: midiChannel,
                        onIncrement: { 
                            if midiChannel < 16 { midiChannel += 1 }
                        },
                        onDecrement: { 
                            if midiChannel > 1 { midiChannel -= 1 }
                        }
                    )
                }
                
                // CC Number
                VStack(alignment: .leading, spacing: 12) {
                    Text("CC Number")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.look.textSecondary)
                    
                    ComponentPaletteCustomStepperStyle(
                        label: "\(ccNumber)",
                        value: ccNumber,
                        onIncrement: { 
                            if ccNumber < 127 { ccNumber += 1 }
                        },
                        onDecrement: { 
                            if ccNumber > 1 { ccNumber -= 1 }
                        }
                    )
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Component Properties Section
    private var componentPropertiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Component Properties")
                .font(.headline)
                .foregroundColor(theme.look.textPrimary)
            
            // Scale Slider
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Scale")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.look.textSecondary)
                    
                    Spacer()
                    
                    Text("\(componentScale, specifier: "%.1f")x")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.look.textPrimary)
                }
                
                Slider(value: $componentScale, in: 0.5...2.0, step: 0.1)
                    .accentColor(theme.look.accent)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func addComponentToCanvas() {
        guard let componentType = selectedComponentType else { return }
        
        // Create a full CanvasComponent with all the configuration INCLUDING STYLE
        var component = CanvasComponent(
            type: componentType,
            position: CGPoint(x: 200, y: 200),
            style: selectedStyle // ENSURE STYLE IS SET CORRECTLY
        )
        
        // Apply MIDI configuration
        component.midiMapping.midiChannel = midiChannel
        component.midiMapping.ccNumber = ccNumber
        
        // Apply component properties
        component.customization.scale = componentScale
        
        // Add the component with the correct style
        onComponentAdd(component)
        
        // Debug print to verify style is being set
        print("Adding component: \(componentDisplayName(componentType)) with style: \(selectedStyle)")
    }
    
    // MARK: - NON-INTERACTIVE Component Preview (Visual Only)
    @ViewBuilder
    private func nonInteractiveComponentPreview(for componentType: AudioUIComponentType, style: String) -> some View {
        Group {
            switch componentType {
            case .knobMinimal1:
                if style == "Neumorphic" {
                    KnobNeumorphic1(value: .constant(0.5))
                        .scaleEffect(0.7)
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    KnobDotted1(value: .constant(0.5))
                        .scaleEffect(0.7)
                        .allowsHitTesting(false)
                } else {
                    KnobMinimal1(value: .constant(0.5))
                        .scaleEffect(0.7)
                        .allowsHitTesting(false)
                }
            case .sliderMinimal1:
                if style == "Neumorphic" {
                    SliderNeumorphic1(value: .constant(0.5))
                        .scaleEffect(0.5)
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    SliderDotted1(value: .constant(0.5))
                        .scaleEffect(0.5)
                        .allowsHitTesting(false)
                } else {
                    SliderMinimal1(value: .constant(0.5))
                        .scaleEffect(0.5)
                        .allowsHitTesting(false)
                }
            case .xyPadMinimal1:
                if style == "Neumorphic" {
                    XYPadNeumorphic1(value: .constant(CGPoint(x: 0.5, y: 0.5)))
                        .scaleEffect(0.6)
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    XYPadDotted1(value: .constant(CGPoint(x: 0.5, y: 0.5)))
                        .scaleEffect(0.6)
                        .allowsHitTesting(false)
                } else {
                    XYPadMinimal1(value: .constant(CGPoint(x: 0.5, y: 0.5)))
                        .scaleEffect(0.6)
                        .allowsHitTesting(false)
                }
            case .drumPadMinimal1:
                if style == "Neumorphic" {
                    DrumPadNeumorphic1()
                        .scaleEffect(0.5)
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    DrumPadDotted1()
                        .scaleEffect(0.5)
                        .allowsHitTesting(false)
                } else {
                    DrumPadMinimal1()
                        .scaleEffect(0.5)
                        .allowsHitTesting(false)
                }
            case .toggleButtonNeumorphic1:
                if style == "Dotted" {
                    ButtonDotted1(isOn: .constant(false), icon: "power", label: "PWR")
                        .scaleEffect(0.6)
                        .allowsHitTesting(false)
                } else if style == "Minimal" {
                    ButtonMinimal1(isOn: .constant(false), icon: "power", label: "PWR")
                        .scaleEffect(0.6)
                        .allowsHitTesting(false)
                } else {
                    ToggleButtonNeumorphic1(isOn: .constant(false), onIcon: "power", offIcon: "power")
                        .scaleEffect(0.6)
                        .allowsHitTesting(false)
                }
            case .gyroMinimal:
                if style == "Neumorphic" {
                    GyroNeumorphic1(rotation: .constant(GyroRotation.zero))
                        .scaleEffect(0.4)
                        .clipped()
                        .allowsHitTesting(false)
                } else if style == "Dotted" {
                    GyroDotted1(rotation: .constant(GyroRotation.zero))
                        .scaleEffect(0.4)
                        .clipped()
                        .allowsHitTesting(false)
                } else {
                    GyroMinimal(rotation: .constant(GyroRotation.zero))
                        .scaleEffect(0.4)
                        .clipped()
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

// MARK: - Custom Stepper Style
struct ComponentPaletteCustomStepperStyle: View {
    let label: String
    let value: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.look.textPrimary)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.look.surfaceElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(theme.look.glassBorder, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(theme.look.textPrimary)
                .frame(minWidth: 40)
            
            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.look.textPrimary)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.look.surfaceElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(theme.look.glassBorder, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Custom Button Styles

struct ComponentPalettePrimaryButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(theme.look.accent)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

struct ComponentPaletteSecondaryButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(theme.look.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(theme.look.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(theme.look.glassBorder, lineWidth: 1)
                    )
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

struct ComponentPaletteDestructiveButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

// MARK: - Component Palette View (Original)
struct ComponentPaletteView: View {
    let onComponentAdd: (CanvasComponent) -> Void
    @Environment(\.theme) private var theme
    
    var body: some View {
        EnhancedComponentPalette(onComponentAdd: onComponentAdd)
    }
} 