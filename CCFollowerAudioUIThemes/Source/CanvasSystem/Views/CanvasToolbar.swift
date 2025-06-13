//
//  CanvasToolbar.swift
//  CntrlSuite - Professional Audio Controller
//  © 2025 CohenConcepts • Licensed under MIT License
//

import SwiftUI
import AudioUIComponents
import AudioUITheme
import GestureCanvasKit

// MARK: - Unified Canvas Toolbar
@available(iOS 18.0, macOS 13.0, *)
struct CanvasToolbar: View {
    @Binding var isEditMode: Bool
    @Binding var isCanvasLocked: Bool
    @Binding var showValueLabels: Bool
    @Binding var showComponentPalette: Bool
    @Binding var selectedComponent: CanvasComponent?
    @Binding var showInspector: Bool
    
    let storageAdapter: CanvasStorageAdapter
    let canvasStorage: EnhancedCanvasStorage // Keep for preset functionality
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                VStack(spacing: 12) {
                    // Lock button (always visible at top)
                    Button(action: { 
                        withAnimation(.spring()) {
                            isCanvasLocked.toggle()
                        }
                    }) {
                        Image(systemName: isCanvasLocked ? "lock.fill" : "lock.open")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isCanvasLocked ? theme.look.stateWarning : theme.look.textSecondary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                isCanvasLocked ? theme.look.stateWarning.opacity(0.3) : theme.look.glassBorder.opacity(0.3), 
                                                lineWidth: 1
                                            )
                                    )
                            )
                    }
                    

                    
                    // Edit mode toggle / Add component (swapped positions in edit mode)
                    if isEditMode {
                        // Plus icon in edit mode (bottom position)
                        Button(action: { 
                            withAnimation(.spring()) {
                                showComponentPalette.toggle()
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(theme.look.brandPrimary)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(theme.look.brandPrimary.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    } else {
                        // Edit mode toggle (bottom position when not in edit mode)
                        Button(action: { 
                            withAnimation(.spring()) {
                                isEditMode.toggle()
                                if !isEditMode {
                                    selectedComponent = nil
                                    showInspector = false
                                    showComponentPalette = false
                                    isCanvasLocked = false
                                }
                            }
                        }) {
                            Image(systemName: "wrench.adjustable")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(theme.look.textSecondary)
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
                    }
                    
                    // Direct preset menu (visible in edit mode)
                    if isEditMode {
                        SimplePresetMenu(storageAdapter: storageAdapter, canvasStorage: canvasStorage)
                    }
                    
                    // Checkmark to exit edit mode (only visible in edit mode, bottom position now)
                    if isEditMode {
                        Button(action: { 
                            withAnimation(.spring()) {
                                isEditMode = false
                                selectedComponent = nil
                                showInspector = false
                                showComponentPalette = false
                                isCanvasLocked = false
                            }
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(theme.look.brandPrimary)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(theme.look.brandPrimary.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 40)
            }
        }
        .zIndex(20)
    }
}

// MARK: - Simple Preset Menu (Updated for GestureCanvasKit)
@available(iOS 18.0, macOS 13.0, *)
struct SimplePresetMenu: View {
    let storageAdapter: CanvasStorageAdapter
    let canvasStorage: EnhancedCanvasStorage
    @StateObject private var presetManager = PresetStorageManager()
    @State private var showSavePresetSheet = false
    @State private var showUserPresetsSheet = false
    @Environment(\.theme) private var theme
    
    var body: some View {
        Menu {
            // Built-in presets section
            Section("Built-in Presets") {
                Button("Clear Canvas") {
                    storageAdapter.clearCanvas()
                }
                
                Divider()
                
                Button("Load DJ Setup") {
                    CanvasPresetManager.loadPreset(.dj, canvasStorage: canvasStorage)
                    storageAdapter.syncFromOriginal()
                }
                
                Button("Load Producer Setup") {
                    CanvasPresetManager.loadPreset(.producer, canvasStorage: canvasStorage)
                    storageAdapter.syncFromOriginal()
                }
                
                Button("Load Performance Setup") {
                    CanvasPresetManager.loadPreset(.performance, canvasStorage: canvasStorage)
                    storageAdapter.syncFromOriginal()
                }
            }
            
            Divider()
            
            // User presets section
            Section("Your Presets") {
                Button("Save Current Setup") {
                    showSavePresetSheet = true
                }
                
                Button("Manage Presets") {
                    showUserPresetsSheet = true
                }
                
                if !presetManager.userPresets.isEmpty {
                    Divider()
                    
                    ForEach(presetManager.userPresets.prefix(5)) { preset in
                        Button(preset.name) {
                            presetManager.loadPreset(preset, canvasStorage: canvasStorage)
                            storageAdapter.syncFromOriginal()
                        }
                    }
                    
                    if presetManager.userPresets.count > 5 {
                        Button("More...") {
                            showUserPresetsSheet = true
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "square.grid.3x2.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(theme.look.brandPrimary)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.look.glassBorder.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
        }
        .sheet(isPresented: $showSavePresetSheet) {
            SavePresetSheet(presetManager: presetManager, canvasStorage: canvasStorage)
        }
        .sheet(isPresented: $showUserPresetsSheet) {
            UserPresetsSheet(presetManager: presetManager, canvasStorage: canvasStorage)
        }
    }
}

// MARK: - Enhanced Canvas Preset Menu with User Presets (Legacy)
@available(iOS 18.0, macOS 13.0, *)
struct CanvasPresetMenu: View {
    let isEditMode: Bool
    let canvasStorage: EnhancedCanvasStorage
    @StateObject private var presetManager = PresetStorageManager()
    @State private var showSavePresetSheet = false
    @State private var showUserPresetsSheet = false
    @Environment(\.theme) private var theme
    
    var body: some View {
        // Enhanced preset menu - remove VStack and spacers to prevent pushing
        HStack {
                if isEditMode {
                    Menu {
                        // Built-in presets section
                        Section("Built-in Presets") {
                            Button("Clear Canvas") {
                                canvasStorage.clearCanvas()
                            }
                            
                            Divider()
                            
                            Button("Load DJ Setup") {
                                CanvasPresetManager.loadPreset(.dj, canvasStorage: canvasStorage)
                            }
                            
                            Button("Load Producer Setup") {
                                CanvasPresetManager.loadPreset(.producer, canvasStorage: canvasStorage)
                            }
                            
                            Button("Load Performance Setup") {
                                CanvasPresetManager.loadPreset(.performance, canvasStorage: canvasStorage)
                            }
                        }
                        
                        Divider()
                        
                        // User presets section
                        Section("Your Presets") {
                            Button("Save Current Setup") {
                                showSavePresetSheet = true
                            }
                            
                            Button("Manage Presets") {
                                showUserPresetsSheet = true
                            }
                            
                            if !presetManager.userPresets.isEmpty {
                                Divider()
                                
                                ForEach(presetManager.userPresets.prefix(5)) { preset in
                                    Button(preset.name) {
                                        presetManager.loadPreset(preset, canvasStorage: canvasStorage)
                                    }
                                }
                                
                                if presetManager.userPresets.count > 5 {
                                    Button("More...") {
                                        showUserPresetsSheet = true
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "list.bullet")
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
                }
                
                Spacer()
            }
            .zIndex(15) // High z-index to overlay properly
        .sheet(isPresented: $showSavePresetSheet) {
            SavePresetSheet(presetManager: presetManager, canvasStorage: canvasStorage)
        }
        .sheet(isPresented: $showUserPresetsSheet) {
            UserPresetsSheet(presetManager: presetManager, canvasStorage: canvasStorage)
        }
    }
}

// MARK: - Save Preset Sheet
@available(iOS 18.0, macOS 13.0, *)
struct SavePresetSheet: View {
    let presetManager: PresetStorageManager
    let canvasStorage: EnhancedCanvasStorage
    
    @State private var presetName = ""
    @State private var presetDescription = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Save Canvas Preset")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(theme.look.textPrimary)
                    
                    Text("Save your current canvas configuration including all components, positions, and MIDI mappings.")
                        .font(.subheadline)
                        .foregroundColor(theme.look.textSecondary)
                }
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preset Name")
                            .font(.headline.weight(.medium))
                            .foregroundColor(theme.look.textPrimary)
                        
                        TextField("Enter preset name", text: $presetName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline.weight(.medium))
                            .foregroundColor(theme.look.textPrimary)
                        
                        TextField("Optional description", text: $presetDescription, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3)
                    }
                }
                
                VStack(spacing: 8) {
                    Text("Components: \(canvasStorage.components.count)")
                        .font(.caption)
                        .foregroundColor(theme.look.textSecondary)
                    
                    if !canvasStorage.components.isEmpty {
                        Text("Including: \(canvasStorage.components.map { $0.type.displayName }.joined(separator: ", "))")
                            .font(.caption2)
                            .foregroundColor(theme.look.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Save Preset") {
                        presetManager.savePreset(
                            name: presetName.isEmpty ? "Untitled Preset" : presetName,
                            description: presetDescription,
                            canvasStorage: canvasStorage
                        )
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(canvasStorage.components.isEmpty)
                }
            }
            .padding(24)
            .background(theme.look.backgroundPrimary)
        }
    }
}

// MARK: - User Presets Sheet
@available(iOS 18.0, macOS 13.0, *)
struct UserPresetsSheet: View {
    let presetManager: PresetStorageManager
    let canvasStorage: EnhancedCanvasStorage
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    
    var body: some View {
        NavigationView {
            VStack {
                if presetManager.userPresets.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "square.stack.3d.up")
                            .font(.system(size: 64))
                            .foregroundColor(theme.look.textSecondary)
                        
                        Text("No Saved Presets")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(theme.look.textPrimary)
                        
                        Text("Create your first preset by setting up your canvas and tapping 'Save Current Setup'")
                            .font(.subheadline)
                            .foregroundColor(theme.look.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(32)
                } else {
                    List {
                        ForEach(presetManager.userPresets) { preset in
                            PresetRow(
                                preset: preset,
                                onLoad: {
                                    presetManager.loadPreset(preset, canvasStorage: canvasStorage)
                                    dismiss()
                                },
                                onDelete: {
                                    presetManager.deletePreset(preset)
                                }
                            )
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Your Presets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preset Row
@available(iOS 18.0, macOS 13.0, *)
struct PresetRow: View {
    let preset: UserCanvasPreset
    let onLoad: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.name)
                        .font(.headline.weight(.medium))
                        .foregroundColor(theme.look.textPrimary)
                    
                    if !preset.description.isEmpty {
                        Text(preset.description)
                            .font(.subheadline)
                            .foregroundColor(theme.look.textSecondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(preset.components.count) components")
                        .font(.caption.weight(.medium))
                        .foregroundColor(theme.look.textSecondary)
                    
                    Text(preset.createdAt, style: .date)
                        .font(.caption2)
                        .foregroundColor(theme.look.textTertiary)
                }
            }
            
            HStack(spacing: 12) {
                Button("Load") {
                    onLoad()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Delete") {
                    showDeleteAlert = true
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
        .alert("Delete Preset", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete '\(preset.name)'? This action cannot be undone.")
        }
    }
} 