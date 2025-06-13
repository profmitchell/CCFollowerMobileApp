//
//  ThemeBrowserView.swift
//  CntrlSuite - Professional Audio Controller
//  © 2025 CohenConcepts • Licensed under MIT License
//

import SwiftUI
import AudioUIComponents
import AudioUICore
import AudioUITheme

struct ThemeBrowserView: View {
    @Environment(\.theme) private var currentTheme
    @Environment(ThemeManager.self) private var themeManager
    @State private var selectedTheme: Theme = .audioUI
    @State private var hoveredTheme: Theme?
    @State private var showingPreview = false
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(allThemeOptions.enumerated()), id: \.offset) { index, themeInfo in
                    themeCard(for: themeInfo)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(currentTheme.look.backgroundPrimary.ignoresSafeArea())
        .onAppear {
            selectedTheme = themeManager.selectedTheme
        }
    }
    
    // All available themes with metadata
    var allThemeOptions: [ThemeInfo] {
        [
            ThemeInfo(name: "AudioUI", description: "Elegant light blue", theme: .audioUI, category: .core),
            ThemeInfo(name: "Dark Pro", description: "Professional dark", theme: .darkPro, category: .core),
            ThemeInfo(name: "Ocean", description: "Vibrant cyan depths", theme: .ocean, category: .core),
            ThemeInfo(name: "Sunset", description: "Warm orange purple", theme: .sunset, category: .core),
            ThemeInfo(name: "Forest", description: "Rich natural green", theme: .forest, category: .core),
            ThemeInfo(name: "Neon", description: "Electric cyberpunk", theme: .neon, category: .vibrant),
            ThemeInfo(name: "Retro", description: "Warm vintage tones", theme: .retro, category: .vintage),
            ThemeInfo(name: "Monochrome", description: "Black and white", theme: .monochrome, category: .minimal),
            ThemeInfo(name: "Cosmic", description: "Deep space purple", theme: .cosmic, category: .vibrant),
            ThemeInfo(name: "Dune Desert", description: "Spice red sands", theme: .duneDesert, category: .vibrant),
            ThemeInfo(name: "Arctic Ice", description: "Crystal blue ice", theme: .arcticIce, category: .cool),
            ThemeInfo(name: "Magma Fire", description: "Molten lava red", theme: .magmaFire, category: .warm),
            ThemeInfo(name: "Soft Pink", description: "Gentle rose blush", theme: .softPink, category: .soft),
            ThemeInfo(name: "Sage Green", description: "Natural earth sage", theme: .sageGreen, category: .soft),
            ThemeInfo(name: "Midnight Blue", description: "Deep navy sapphire", theme: .midnightBlue, category: .cool),
            ThemeInfo(name: "Golden Hour", description: "Luxurious amber gold", theme: .goldenHour, category: .warm),
            ThemeInfo(name: "Royal Purple", description: "Rich violet amethyst", theme: .royalPurple, category: .vibrant),
            ThemeInfo(name: "Aurora", description: "Mystical northern lights", theme: .aurora, category: .vibrant),
            ThemeInfo(name: "Cherry Blossom", description: "Delicate sakura pink", theme: .cherryBlossom, category: .soft),
            ThemeInfo(name: "Cloud Dream", description: "Dreamy pastel sky", theme: .cloudDream, category: .soft),
            ThemeInfo(name: "Deep Ocean", description: "Profound aquatic blue", theme: .deepOcean, category: .cool),
            ThemeInfo(name: "Neon Cyberpunk", description: "Electric neon pulse", theme: .neonCyberpunk, category: .vibrant),
            ThemeInfo(name: "Peachy Cream", description: "Warm coral comfort", theme: .peachyCream, category: .warm),
        ]
    }
    
    // MARK: - Theme Card
    private func themeCard(for themeInfo: ThemeInfo) -> some View {
        let isSelected = themeInfo.name == getThemeName(selectedTheme)
        
        return Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                selectedTheme = themeInfo.theme
                themeManager.setTheme(themeInfo.theme)
            }
        }) {
            VStack(spacing: 12) {
                // Simple color indicator
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                themeInfo.theme.look.brandPrimary,
                                themeInfo.theme.look.accent
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? currentTheme.look.accent : Color.clear,
                                lineWidth: 3
                            )
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                // Theme name
                Text(themeInfo.name)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? currentTheme.look.textPrimary : currentTheme.look.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? currentTheme.look.surfaceElevated : currentTheme.look.surfacePrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? currentTheme.look.accent.opacity(0.6) : currentTheme.look.glassBorder.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    // Helper function to get theme name by comparing against static instances
    private func getThemeName(_ theme: Theme) -> String {
        // Compare the theme by checking its look type string representation
        let lookType = String(describing: type(of: theme.look))
        
        switch lookType {
        case "AudioUILook": return "AudioUI"
        case "DarkProLook": return "Dark Pro"
        case "OceanLook": return "Ocean"
        case "SunsetLook": return "Sunset"
        case "ForestLook": return "Forest"
        case "NeonLook": return "Neon"
        case "RetroLook": return "Retro"
        case "MonochromeLook": return "Monochrome"
        case "CosmicLook": return "Cosmic"
        case "DuneDesertLook": return "Dune Desert"
        case "ArcticIceLook": return "Arctic Ice"
        case "MagmaFireLook": return "Magma Fire"
        case "SoftPinkLook": return "Soft Pink"
        case "SageGreenLook": return "Sage Green"
        case "MidnightBlueLook": return "Midnight Blue"
        case "GoldenHourLook": return "Golden Hour"
        case "RoyalPurpleLook": return "Royal Purple"
        case "AuroraLook": return "Aurora"
        case "CherryBlossomLook": return "Cherry Blossom"
        case "CloudDreamLook": return "Cloud Dream"
        case "DeepOceanLook": return "Deep Ocean"
        case "NeonCyberpunkLook": return "Neon Cyberpunk"
        case "PeachyCreamLook": return "Peachy Cream"
        case "SimpleMonoLook": return "Simple Mono"
        case "SimpleBlueOrangeLook": return "Simple Blue Orange"
        case "SimpleGreenPurpleLook": return "Simple Green Purple"
        default: return "Unknown"
        }
    }
}

struct ThemeInfo {
    let name: String
    let description: String
    let theme: Theme
    let category: ThemeCategory
    
    enum ThemeCategory {
        case core, vibrant, vintage, minimal, cool, warm, soft
        
        var color: Color {
            switch self {
            case .core: return .blue
            case .vibrant: return .purple
            case .vintage: return .orange
            case .minimal: return .gray
            case .cool: return .cyan
            case .warm: return .red
            case .soft: return .pink
            }
        }
        
        var displayName: String {
            switch self {
            case .core: return "Core"
            case .vibrant: return "Vibrant" 
            case .vintage: return "Vintage"
            case .minimal: return "Minimal"
            case .cool: return "Cool"
            case .warm: return "Warm"
            case .soft: return "Soft"
            }
        }
    }
}

struct ThemeCard: View {
    let themeInfo: ThemeInfo
    let isSelected: Bool
    let isHovered: Bool
    let onSelect: () -> Void
    
    @State private var knobValue: Double = 0.6
    @State private var sliderValue: Double = 0.7
    @State private var isToggleOn: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Header with theme name
            VStack(spacing: 4) {
                Text(themeInfo.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(themeInfo.theme.look.textPrimary)
                    .lineLimit(1)
                
                Text(themeInfo.description)
                    .font(.caption2)
                    .foregroundColor(themeInfo.theme.look.textSecondary)
                    .lineLimit(1)
                
                // Category badge
                Text(themeInfo.category.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(themeInfo.category.color.opacity(0.2))
                    .foregroundColor(themeInfo.category.color)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            
            // Color palette preview
            HStack(spacing: 3) {
                ColorSwatch(color: themeInfo.theme.look.brandPrimary)
                ColorSwatch(color: themeInfo.theme.look.brandSecondary)
                ColorSwatch(color: themeInfo.theme.look.brandTertiary)
                ColorSwatch(color: themeInfo.theme.look.accent)
                ColorSwatch(color: themeInfo.theme.look.accentSecondary)
            }
            .padding(.horizontal, 8)
            
            // Mini component preview
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    // Mini knob
                    KnobMinimal1(value: $knobValue)
                        .theme(themeInfo.theme)
                        .scaleEffect(0.25)
                        .frame(width: 30, height: 30)
                    
                    // Mini button
                    ToggleButtonNeumorphic1(isOn: .constant(false))
                        .theme(themeInfo.theme)
                        .scaleEffect(0.5)
                        .frame(width: 30, height: 30)
                }
                
                // Mini slider
                SliderMinimal1(value: $sliderValue)
                    .theme(themeInfo.theme)
                    .scaleEffect(0.4)
                    .frame(width: 60, height: 20)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeInfo.theme.look.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? themeInfo.theme.look.brandPrimary : 
                            isHovered ? themeInfo.theme.look.brandSecondary.opacity(0.5) :
                            themeInfo.theme.look.neutralDivider.opacity(0.3),
                            lineWidth: isSelected ? 2 : isHovered ? 1.5 : 1
                        )
                )
                .shadow(
                    color: isSelected ? themeInfo.theme.look.glowPrimary :
                           isHovered ? themeInfo.theme.look.shadowMedium :
                           themeInfo.theme.look.shadowDark.opacity(0.2),
                    radius: isSelected ? 8 : isHovered ? 6 : 2,
                    x: 0,
                    y: isSelected ? 4 : isHovered ? 3 : 1
                )
        )
        .scaleEffect(isSelected ? 1.05 : isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onTapGesture {
            onSelect()
        }
    }
}

struct ColorSwatch: View {
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
    }
}

// Preview
struct ThemeBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeBrowserView()
            .theme(.audioUI)
            .preferredColorScheme(.dark)
    }
} 