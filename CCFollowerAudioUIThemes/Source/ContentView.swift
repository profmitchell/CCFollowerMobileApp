//
//  ContentView.swift
//  CntrlSuite - Professional Audio Controller
//  © 2025 CohenConcepts • Licensed under MIT License
//

import SwiftUI
import AudioUIComponents
import AudioUICore
import AudioUITheme
import MappingKit
import MIDIKitIO

// MARK: - Dashboard Card Types
enum DashboardCard: String, CaseIterable, Identifiable {
    case envelopeFollower = "Envelope Follower"
    case settings = "Settings"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .envelopeFollower: return "waveform.path"
        case .settings: return "gearshape"
        }
    }
    
    var description: String {
        switch self {
        case .envelopeFollower: return "Audio envelope to MIDI CC converter"
        case .settings: return "App preferences, MIDI, and Bluetooth configuration"
        }
    }
}

// MARK: - Main Dashboard Content View
struct ContentView: View {
    @Environment(ObservableMIDIManager.self) private var midiManager
    @Environment(MIDIHelper.self) private var midiHelper
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.theme) private var theme
    @State private var selectedCard: DashboardCard? = nil
    @State private var showingFullScreenView = false
    @State private var selectedTheme: AppThemeOption = .audioUI
    @State private var showThemeSelector = false
    
    var body: some View {
        ZStack {
            if showingFullScreenView, let selectedCard = selectedCard {
                // Full-screen view - no containers, no padding, no NavigationStack
                fullScreenView(for: selectedCard)
                    .transition(.identity)
            } else {
                // Dashboard view with containers
                NavigationStack {
                    ZStack {
                        // Enhanced glassmorphic background
                        glassmorphicBackground
                        
                        dashboardView
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                    }
                }
                .transition(.identity)
            }
        }
        .gesture(
            // Swipe gestures for navigation
            DragGesture()
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    let verticalAmount = value.translation.height
                    
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        // Horizontal swipe
                        if horizontalAmount > 100 && showingFullScreenView {
                            // Swipe right to go back
                            showingFullScreenView = false
                            selectedCard = nil
                        }
                    } else if verticalAmount > 100 && showingFullScreenView {
                        // Swipe down to close
                        showingFullScreenView = false
                        selectedCard = nil
                    }
                }
        )
        .animation(nil, value: showingFullScreenView)
        .onAppear {
            // Sync the selectedTheme with the persisted value in ThemeManager
            if let option = AppThemeOption.allCases.first(where: { $0.theme.look.brandPrimary == themeManager.selectedTheme.look.brandPrimary }) {
                selectedTheme = option
            }
            themeManager.setTheme(selectedTheme.theme)
        }
        .onChange(of: selectedTheme) { oldValue, newValue in
            // Update theme manager when selection changes
            themeManager.setTheme(newValue.theme)
        }
    }
    
    // MARK: - Dashboard View
    private var dashboardView: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                dashboardHeader
                
                // Cards Grid
                dashboardCards
                
                // Quick Stats
                quickStats
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Dashboard Header
    private var dashboardHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CntrlSuite")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.look.textPrimary)
                    
                    Text("Professional Audio Controller")
                        .font(.subheadline)
                        .foregroundColor(theme.look.textSecondary)
                }
                
                Spacer()
                
                // Theme Selector
                AppFloatingThemeSelector()
            }
            
            Divider()
                .overlay(theme.look.neutralDivider)
        }
    }
    
    // MARK: - Connection Status
    private var connectionStatusIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(midiManager.endpoints.outputs.count > 0 ? theme.look.stateSuccess : theme.look.stateError)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(theme.look.textPrimary.opacity(0.3), lineWidth: 1)
                )
            
            Text(midiManager.endpoints.outputs.count > 0 ? "Connected" : "Disconnected")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.look.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.look.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.look.glassBorder, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Dashboard Cards
    private var dashboardCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 20) {
            ForEach(DashboardCard.allCases) { card in
                dashboardCard(card)
            }
        }
    }
    
    // MARK: - Individual Dashboard Card
    private func dashboardCard(_ card: DashboardCard) -> some View {
        Button(action: {
            selectedCard = card
            showingFullScreenView = true
        }) {
            VStack(spacing: 16) {
                // Icon with background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    getColor(for: card).opacity(0.2),
                                    getColor(for: card).opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: card.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(getColor(for: card))
                }
                
                // Card content
                VStack(spacing: 6) {
                    Text(card.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.look.textPrimary)
                    
                    Text(card.description)
                        .font(.caption)
                        .foregroundColor(theme.look.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        theme.look.glassBorder.opacity(0.6),
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
                color: Color.black.opacity(0.1),
                radius: 10,
                x: 0,
                y: 5
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(selectedCard == card ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: selectedCard)
    }
    
    // MARK: - Quick Stats
    private var quickStats: some View {
        VStack(spacing: 16) {
            Text("Quick Stats")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(theme.look.textPrimary)
            
            HStack(spacing: 20) {
                quickStatItem(title: "MIDI Devices", value: "\(midiManager.endpoints.outputs.count)")
                quickStatItem(title: "Active Controls", value: "12")
                quickStatItem(title: "Mappings", value: "8")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.look.glassBorder.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func quickStatItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.look.accent)
            
            Text(title)
                .font(.caption)
                .foregroundColor(theme.look.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Full Screen Views
    @ViewBuilder
    private func fullScreenView(for card: DashboardCard) -> some View {
        ZStack {
            // Pure mode view with no navigation
            switch card {
            case .envelopeFollower:
                EnvelopeFollowerView()
            case .settings:
                SettingsView()
            }
            
            // Unified Header Overlay
            VStack {
                UnifiedModeHeader(
                    title: card.rawValue,
                    onBack: {
                        showingFullScreenView = false
                    }
                )
                
                Spacer()
            }
            .zIndex(100)
        }
    }
    
    // MARK: - Unified Mode Header
    private struct UnifiedModeHeader: View {
        let title: String
        let onBack: () -> Void
        @Environment(\.theme) private var theme
        
        var body: some View {
            VStack(spacing: 12) {
                HStack {
                    // Back button
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Dashboard")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(theme.look.accent)
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
                    
                    // Mode title
                    Text(title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.look.textPrimary)
                    
                    Spacer()
                    
                    // Theme selector (replacing settings icons)
                    AppFloatingThemeSelector()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // Separator line (hidden for Envelope Follower for seamless backgrounds)
                if title != "Envelope Follower" {
                    Divider()
                        .overlay(theme.look.neutralDivider.opacity(0.3))
                        .padding(.horizontal, 20)
                }
            }
            .background(
                // Transparent background for Envelope Follower
                Group {
                    if title == "Envelope Follower" {
                        Color.clear
                    } else {
                        Color.clear.background(.ultraThinMaterial.opacity(0.5), in: Rectangle())
                    }
                }
            )
        }
    }
    
    // MARK: - Glassmorphic Background
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
    
    // MARK: - Helper Methods
    private func getColor(for card: DashboardCard) -> Color {
        switch card {
        case .envelopeFollower: return theme.look.accent
        case .settings: return theme.look.brandSecondary
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environment(ObservableMIDIManager(
            clientName: "Preview",
            model: "Preview",
            manufacturer: "Preview"
        ))
        .environment(MIDIHelper())
        .environment(ThemeManager())
        .theme(.audioUI)
}
