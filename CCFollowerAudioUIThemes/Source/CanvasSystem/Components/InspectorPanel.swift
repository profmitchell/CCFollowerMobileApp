//
//  InspectorPanel.swift
//  CntrlSuite - Professional Audio Controller
//  © 2025 CohenConcepts • Licensed under MIT License
//

import SwiftUI
import AudioUIComponents
import AudioUITheme

// MARK: - Superior Inspector Panel
struct SuperiorInspectorPanel: View {
    @Binding var selectedComponent: CanvasComponent
    let canvasStorage: EnhancedCanvasStorage
    let onUpdate: (CanvasComponent) -> Void
    let onDelete: () -> Void
    
    @State private var tempMidiChannel: Int = 1
    @State private var tempMidiCC: Int = 1
    @State private var tempLabel: String = ""
    @State private var tempScale: Double = 1.0
    @State private var showDeleteConfirmation = false
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: 16) {
            // Configuration sections (no header)
            ScrollView {
                VStack(spacing: 16) {
                    midiConfigurationSection
                    customizationSection
                    actionsSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.look.surfaceElevated)
                .shadow(color: .black.opacity(0.2), radius: 12, x: 4, y: 0)
        )
        .onAppear {
            loadComponentData()
        }
    }
    
    private var inspectorHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Inspector")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(theme.look.textPrimary)
                
                Text(selectedComponent.type.displayName)
                    .font(.subheadline)
                    .foregroundColor(theme.look.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: selectedComponent.type.iconName)
                .font(.title2)
                .foregroundColor(theme.look.brandPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    private var midiConfigurationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Channel")
                        .font(.caption.weight(.medium))
                        .foregroundColor(theme.look.textSecondary)
                    
                    Picker("Channel", selection: $tempMidiChannel) {
                        ForEach(1...16, id: \.self) { channel in
                            Text("\(channel)").tag(channel)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 80)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("CC Number")
                        .font(.caption.weight(.medium))
                        .foregroundColor(theme.look.textSecondary)
                    
                    Picker("CC", selection: $tempMidiCC) {
                        ForEach(1...127, id: \.self) { cc in
                            Text("\(cc)").tag(cc)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 80)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.look.backgroundPrimary)
        )
    }
    
    private var customizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 12) {
                HStack {
                    Text("Label")
                        .font(.caption.weight(.medium))
                        .foregroundColor(theme.look.textSecondary)
                    
                    Spacer()
                    
                    TextField("Component Label", text: $tempLabel)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 150)
                }
                
                HStack {
                    Text("Scale")
                        .font(.caption.weight(.medium))
                        .foregroundColor(theme.look.textSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(tempScale * 100))%")
                        .font(.caption)
                        .foregroundColor(theme.look.textTertiary)
                        .frame(width: 40)
                    
                    Slider(value: $tempScale, in: 0.5...2.0, step: 0.1)
                        .frame(maxWidth: 120)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.look.backgroundPrimary)
        )
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button("Apply Changes") {
                applyChanges()
            }
            .buttonStyle(CanvasPrimaryButtonStyle(theme: theme))
            
            Button("Delete Component") {
                showDeleteConfirmation = true
            }
            .buttonStyle(CanvasDangerButtonStyle(theme: theme))
        }
        .alert("Delete Component", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this component? This action cannot be undone.")
        }
    }
    
    private func loadComponentData() {
        tempMidiChannel = selectedComponent.midiMapping.midiChannel
        tempMidiCC = selectedComponent.midiMapping.ccNumber
        tempLabel = selectedComponent.customization.label
        tempScale = selectedComponent.customization.scale
    }
    
    private func applyChanges() {
        var updatedComponent = selectedComponent
        updatedComponent.midiMapping.midiChannel = tempMidiChannel
        updatedComponent.midiMapping.ccNumber = tempMidiCC
        updatedComponent.customization.label = tempLabel
        updatedComponent.customization.scale = tempScale
        
        onUpdate(updatedComponent)
    }
}

// MARK: - Canvas-Specific Button Styles
struct CanvasPrimaryButtonStyle: ButtonStyle {
    let theme: Theme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.look.brandPrimary)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct CanvasDangerButtonStyle: ButtonStyle {
    let theme: Theme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red.opacity(0.8))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
} 