//
//  CanvasView.swift
//  CntrlSuite - Professional Audio Controller
//  © 2025 CohenConcepts • Licensed under MIT License
//

// MARK: - Enhanced Canvas View with GestureCanvasKit Integration
import SwiftUI
import AudioUICore
import AudioUIComponents  
import AudioUITheme
import GestureCanvasKit

// MARK: - Main Enhanced Canvas View
@available(iOS 18.0, macOS 13.0, *)
struct CanvasView: View {
    @StateObject private var canvasStorage = EnhancedCanvasStorage()
    @StateObject private var storageAdapter: CanvasStorageAdapter
    @State private var selectedComponent: CanvasComponent?
    @State private var isEditMode = false
    @State private var showValueLabels = false
    @State private var showComponentPalette = false
    @State private var showInspector = false
    @State private var isCanvasLocked = false
    
    @Environment(\.theme) private var theme
    
    init() {
        let storage = EnhancedCanvasStorage()
        self._canvasStorage = StateObject(wrappedValue: storage)
        self._storageAdapter = StateObject(wrappedValue: CanvasStorageAdapter(originalStorage: storage))
    }
    
    var body: some View {
        ZStack {
            // Enhanced glassmorphic background (same as ContentView)
            glassmorphicBackground
            
            // Main canvas with GestureCanvasKit
            CanvasContainer(
                canvasStorage: canvasStorage,
                storageAdapter: storageAdapter,
                isEditMode: isEditMode,
                isCanvasLocked: isCanvasLocked,
                showValueLabels: showValueLabels,
                selectedComponent: $selectedComponent,
                onComponentTap: handleComponentTap,
                onComponentUpdate: handleComponentUpdate
            )
            
            // Floating Component Palette - WIDER
            if showComponentPalette {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                            .frame(height: 100) // Push down from top
                        
                        EnhancedComponentPalette(onComponentAdd: addComponent)
                            .frame(width: 340, height: 500) // WIDER for better card layout
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        
                        Spacer()
                            .frame(height: 120) // Space at bottom
                    }
                    .padding(.trailing, 20)
                }
                .zIndex(10)
            }
            
            // Enhanced Inspector Panel
            if showInspector, let selectedComponent = selectedComponent {
                VStack {
                    Spacer()
                    HStack {
                        SuperiorInspectorPanel(
                            selectedComponent: Binding(
                                get: { selectedComponent },
                                set: { updatedComponent in
                                    canvasStorage.updateComponent(updatedComponent)
                                    self.selectedComponent = updatedComponent
                                    storageAdapter.syncFromOriginal()
                                }
                            ),
                            canvasStorage: canvasStorage,
                            onUpdate: { component in
                                canvasStorage.updateComponent(component)
                                storageAdapter.syncFromOriginal()
                                showInspector = false
                                self.selectedComponent = nil
                            },
                            onDelete: {
                                canvasStorage.removeComponent(id: selectedComponent.id)
                                storageAdapter.syncFromOriginal()
                                showInspector = false
                                self.selectedComponent = nil
                            }
                        )
                        .frame(maxWidth: 350)
                        Spacer()
                    }
                    Spacer()
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
                .zIndex(15)
            }
            
            // Canvas instructions (only in edit mode)
            if isEditMode && !showComponentPalette && !showInspector && !isCanvasLocked {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Canvas Gestures")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(theme.look.textPrimary)
                            
                            Text("• Drag to pan")
                                .font(.caption2)
                                .foregroundColor(theme.look.textSecondary)
                            
                            Text("• Pinch to zoom")
                                .font(.caption2)
                                .foregroundColor(theme.look.textSecondary)
                            
                            Text("• Double-tap to fit/reset")
                                .font(.caption2)
                                .foregroundColor(theme.look.textSecondary)
                                
                            Text("• Triple-tap to auto-arrange")
                                .font(.caption2)
                                .foregroundColor(theme.look.textSecondary)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(theme.look.glassBorder.opacity(0.4), lineWidth: 1)
                                )
                        )
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.top, 120)
                .zIndex(3)
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }
            
            // Unified toolbar
            CanvasToolbar(
                isEditMode: $isEditMode,
                isCanvasLocked: $isCanvasLocked,
                showValueLabels: $showValueLabels,
                showComponentPalette: $showComponentPalette,
                selectedComponent: $selectedComponent,
                showInspector: $showInspector,
                storageAdapter: storageAdapter,
                canvasStorage: canvasStorage
            )
        }
        .navigationBarHidden(true)
        .gesture(
            // Disable swipe back gesture when in canvas builder
            DragGesture()
                .onChanged { _ in
                    // Consume swipe gestures to prevent navigation
                }
        )
        .onChange(of: selectedComponent) { _, newSelection in
            if isEditMode && newSelection != nil {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showInspector = true
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showInspector = false
                }
            }
        }
    }
    
    // MARK: - Glassmorphic Background (same as ContentView)
    private var glassmorphicBackground: some View {
        ZStack {
            // Base gradient background
            LinearGradient(
                colors: [
                    theme.look.backgroundPrimary,
                    theme.look.backgroundSecondary,
                    theme.look.surfacePrimary.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Dynamic floating orbs
            glassmorphicOrbs
            
            // Overlay glass effect
            Color.clear
                .background(.ultraThinMaterial, in: Rectangle())
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Enhanced Glassmorphic Orbs
    private var glassmorphicOrbs: some View {
        ZStack {
            // Primary orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.look.accent.opacity(0.4),
                            theme.look.accentSecondary.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: -150, y: -200)
                .blur(radius: 40)
            
            // Secondary orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.look.brandSecondary.opacity(0.3),
                            theme.look.brandTertiary.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 150)
                .blur(radius: 25)
            
            // Tertiary accent orb
            Circle()
                .fill(theme.look.brandPrimary.opacity(0.2))
                .frame(width: 200, height: 200)
                .offset(x: 80, y: -250)
                .blur(radius: 20)
        }
    }
    
    // MARK: - Event Handlers
    
    private func handleComponentTap(_ component: CanvasComponent) {
        if isEditMode {
            withAnimation(.easeInOut(duration: 0.2)) {
                // If tapping the canvas (dummy component), deselect
                if component.type == .knobMinimal1 && selectedComponent != nil {
                    selectedComponent = nil
                } else {
                    // Toggle selection for real components
                    selectedComponent = selectedComponent?.id == component.id ? nil : component
                }
            }
        }
    }
    
    private func handleComponentUpdate(_ component: CanvasComponent) {
        canvasStorage.updateComponent(component)
        storageAdapter.syncFromOriginal()
    }
    
    private func addComponent(_ component: CanvasComponent) {
        // Use the component as provided, but ensure it has a reasonable position
        var newComponent = component
        if newComponent.position == CGPoint(x: 200, y: 200) {
            // If it's the default position, center it better
            newComponent.position = CGPoint(x: 400, y: 300)
        }
        
        // Add to both storages
        canvasStorage.addComponent(newComponent)
        storageAdapter.addComponent(newComponent)
        
        // Close the component palette WITHOUT selecting the component
        // This prevents the inspector from appearing
        withAnimation(.spring()) {
            showComponentPalette = false
            selectedComponent = nil // Don't select the new component
        }
    }
}
