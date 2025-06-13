//
//  SettingsView.swift
//  CntrlSuite - Professional Audio Controller
//  © 2025 CohenConcepts • Licensed under MIT License
//

import SwiftUI
import MIDIKitIO
import AudioUICore
import AudioUITheme
import Combine

// MARK: - Settings View with Card-based Layout
struct SettingsView: View {
    @Environment(ObservableMIDIManager.self) private var midiManager
    @Environment(MIDIHelper.self) private var midiHelper
    @Environment(\.theme) private var theme
    @State private var showBluetoothCentral = false
    @State private var showBluetoothPeripheral = false
    @State private var showThemeEditor = false
    @State private var enableHapticFeedback = true
    @State private var reducedMotion = false
    @State private var highPerformanceMode = false
    @State private var enableBackgroundProcessing = true
    
    var body: some View {
        ZStack {
            // Glassmorphic background matching ContentView
            glassmorphicBackground
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                   
                    // MIDI & Bluetooth Settings (prioritized)
                    midiSection
                    
                    // Performance Settings (MIDI-related only)
                    performanceSection
                    
                    // User Experience
                    userExperienceSection
                    
                    // About Section
                    aboutSection
                }
                .frame(maxWidth: 700)
                .padding(.horizontal, 32) // More horizontal padding
                .padding(.bottom, 140) // Extra bottom padding
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showBluetoothCentral) {
            #if os(iOS)
            BluetoothMIDIView()
            #else
            Text("Bluetooth MIDI is only available on iOS")
                .padding()
            #endif
        }
        .sheet(isPresented: $showBluetoothPeripheral) {
            #if os(iOS)
            BluetoothMIDIPeripheralView()
            #else
            Text("Bluetooth MIDI is only available on iOS")
                .padding()
            #endif
        }
        .sheet(isPresented: $showThemeEditor) {
            ThemeEditorPlaceholder(theme: theme)
        }
    }
    

    
    // MARK: - MIDI & Bluetooth Section
    private var midiSection: some View {
        settingsSection(
            title: "MIDI & Bluetooth",
            icon: "cable.connector",
            iconColor: theme.look.brandQuaternary,
            backgroundColor: theme.look.brandQuaternary.opacity(0.1)
        ) {
            VStack(spacing: 16) {
                // Connection status
                if midiManager.endpoints.outputs.count > 0 {
                    ConnectionStatusCard(midiManager: midiManager, theme: theme)
                }
                
                // Bluetooth MIDI Controls
                VStack(spacing: 12) {
                    // Advertise as MIDI Device (Peripheral)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Advertise MIDI Service")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(theme.look.textPrimary)
                            Text("Allow other devices to discover and connect")
                                .font(.caption)
                                .foregroundColor(theme.look.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { showBluetoothPeripheral = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.caption)
                                Text("Configure")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.look.brandQuaternary)
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.look.surfaceElevated.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.look.brandQuaternary.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Connect to MIDI Devices (Central)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Connect to MIDI Devices")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(theme.look.textPrimary)
                            Text("Browse and connect to nearby Bluetooth MIDI devices")
                                .font(.caption)
                                .foregroundColor(theme.look.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { showBluetoothCentral = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "wifi.circle")
                                    .font(.caption)
                                Text("Browse")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.look.brandTertiary)
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.look.surfaceElevated.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.look.brandTertiary.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
    
    // MARK: - Performance Section (MIDI-focused)
    private var performanceSection: some View {
        settingsSection(
            title: "MIDI Performance",
            icon: "speedometer",
            iconColor: theme.look.stateInfo,
            backgroundColor: theme.look.stateInfo.opacity(0.1)
        ) {
            VStack(spacing: 16) {
                settingsToggle(
                    title: "Background MIDI Processing",
                    subtitle: "Continue MIDI processing when app is backgrounded",
                    binding: $enableBackgroundProcessing,
                    accentColor: theme.look.brandQuinary
                )
                
                settingsToggle(
                    title: "High Performance Mode",
                    subtitle: "Prioritize MIDI responsiveness over battery life",
                    binding: $highPerformanceMode,
                    accentColor: theme.look.brandQuaternary
                )
            }
        }
    }
    
    // MARK: - User Experience Section
    private var userExperienceSection: some View {
        settingsSection(
            title: "User Experience",
            icon: "hand.tap",
            iconColor: theme.look.accent,
            backgroundColor: theme.look.accent.opacity(0.1)
        ) {
            VStack(spacing: 16) {
                settingsToggle(
                    title: "Haptic Feedback",
                    subtitle: "Feel tactile responses when interacting with controls",
                    binding: $enableHapticFeedback,
                    accentColor: theme.look.accent
                )
                
                settingsToggle(
                    title: "Reduced Motion",
                    subtitle: "Minimize animations for accessibility",
                    binding: $reducedMotion,
                    accentColor: theme.look.accentSecondary
                )
            }
        }
    }
    

    
    // MARK: - About Section
    private var aboutSection: some View {
        settingsSection(
            title: "About",
            icon: "info.circle",
            iconColor: theme.look.brandSecondary,
            backgroundColor: theme.look.brandSecondary.opacity(0.1)
        ) {
            VStack(spacing: 12) {
                aboutRow(title: "Version", value: "1.0.0")
                aboutRow(title: "Build", value: "2025.01.19")
                aboutRow(title: "Framework", value: "AudioUI")
                aboutRow(title: "MIDI Kit", value: "0.9.6")
            }
        }
    }
    
    // MARK: - Helper Views
    private func settingsSection<Content: View>(
        title: String,
        icon: String,
        iconColor: Color,
        backgroundColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 16) {
            // Section header
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(backgroundColor)
                            .overlay(
                                Circle()
                                    .stroke(iconColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.look.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Section content
            VStack(spacing: 12) {
                content()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.look.surfaceElevated.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        iconColor.opacity(0.3),
                                        theme.look.glassBorder.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: theme.look.shadowDark.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
    
    private func settingsToggle(
        title: String,
        subtitle: String,
        binding: Binding<Bool>,
        accentColor: Color
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.look.textPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(theme.look.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Toggle("", isOn: binding)
                .toggleStyle(SwitchToggleStyle(tint: accentColor))
                .scaleEffect(0.9)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.look.surfaceElevated.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            binding.wrappedValue ? 
                            accentColor.opacity(0.4) : 
                            theme.look.glassBorder.opacity(0.2),
                            lineWidth: 1
                        )
                )
        )
    }
    
    private func aboutRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(theme.look.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(theme.look.textPrimary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.look.surface.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(theme.look.glassBorder.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Glassmorphic Background (matching ContentView)
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
            
            // Dynamic floating orbs using multiple brand colors
            glassmorphicOrbs
            
            // Overlay glass effect
            Color.clear
                .background(.ultraThinMaterial, in: Rectangle())
                .ignoresSafeArea()
        }
    }
    
    private var glassmorphicOrbs: some View {
        ZStack {
            // Primary orb using brandQuaternary
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.look.brandQuaternary.opacity(0.4),
                            theme.look.brandQuinary.opacity(0.2),
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
            
            // Secondary orb using accentSecondary
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.look.accentSecondary.opacity(0.3),
                            theme.look.accentTertiary.opacity(0.15),
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
            
            // Tertiary orb using stateInfo
            Circle()
                .fill(theme.look.stateInfo.opacity(0.2))
                .frame(width: 200, height: 200)
                .offset(x: 80, y: -250)
                .blur(radius: 20)
        }
    }
}

// MARK: - Settings Card Component
struct SettingsCard: View {
    let title: String
    let description: String
    let icon: String
    let theme: Theme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(theme.look.accent)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.look.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(theme.look.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(theme.look.textTertiary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(theme.look.glassBorder.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Connection Status Card
struct ConnectionStatusCard: View {
    let midiManager: ObservableMIDIManager
    let theme: Theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(theme.look.stateSuccess)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("MIDI Connected")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.look.textPrimary)
                    
                    Text("\(midiManager.endpoints.inputs.count) input(s), \(midiManager.endpoints.outputs.count) output(s)")
                        .font(.subheadline)
                        .foregroundColor(theme.look.textSecondary)
                }
                
                Spacer()
            }
            
            if !midiManager.endpoints.inputs.isEmpty || !midiManager.endpoints.outputs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Connected Devices:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.look.textPrimary)
                    
                    ForEach(Array(midiManager.endpoints.inputs), id: \.uniqueID) { endpoint in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(theme.look.accent)
                                .frame(width: 6, height: 6)
                            Text("\(endpoint.name) (Input)")
                                .font(.caption)
                                .foregroundColor(theme.look.textSecondary)
                            Spacer()
                        }
                    }
                    
                    ForEach(Array(midiManager.endpoints.outputs), id: \.uniqueID) { endpoint in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(theme.look.accentSecondary)
                                .frame(width: 6, height: 6)
                            Text("\(endpoint.name) (Output)")
                                .font(.caption)
                                .foregroundColor(theme.look.textSecondary)
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.look.stateSuccess.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.look.stateSuccess.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Theme Editor Placeholder
struct ThemeEditorPlaceholder: View {
    let theme: Theme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "paintbrush.pointed.fill")
                    .font(.system(size: 60))
                    .foregroundColor(theme.look.accent)
                
                VStack(spacing: 12) {
                    Text("Theme Editor")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(theme.look.textPrimary)
                    
                    Text("Coming Soon")
                        .font(.headline)
                        .foregroundColor(theme.look.textSecondary)
                    
                    Text("Create and customize your own themes with advanced color palettes, typography, and visual effects.")
                        .font(.subheadline)
                        .foregroundColor(theme.look.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.look.backgroundPrimary)
            .navigationTitle("Theme Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss sheet
                    }
                }
            }
        }
    }
}
