//
//  ThemeOptions.swift
//  CntrlMIDI
//
//  Created by Mitchell Cohen on 1/19/25.
//

import SwiftUI
import AudioUITheme

// MARK: - Shared Theme Options
enum AppThemeOption: String, CaseIterable {
    case audioUI = "AudioUI"
    case darkPro = "Dark Pro" 
    case ocean = "Ocean"
    case sunset = "Sunset"
    case forest = "Forest"
    case neon = "Neon"
    case retro = "Retro"
    case monochrome = "Monochrome"
    case cosmic = "Cosmic"
    case duneDesert = "Dune Desert"
    case arcticIce = "Arctic Ice"
    case magmaFire = "Magma Fire"
    case softPink = "Soft Pink"
    case sageGreen = "Sage Green"
    case midnightBlue = "Midnight Blue"
    case goldenHour = "Golden Hour"
    case royalPurple = "Royal Purple"
    case aurora = "Aurora"
    case cherryBlossom = "Cherry Blossom"
    case cloudDream = "Cloud Dream"
    case deepOcean = "Deep Ocean"
    case neonCyberpunk = "Neon Cyberpunk"
    case peachyCream = "Peachy Cream"
    
    var theme: Theme {
        switch self {
        case .audioUI: return .audioUI
        case .darkPro: return .darkPro
        case .ocean: return .ocean
        case .sunset: return .sunset
        case .forest: return .forest
        case .neon: return .neon
        case .retro: return .retro
        case .monochrome: return .monochrome
        case .cosmic: return .cosmic
        case .duneDesert: return .duneDesert
        case .arcticIce: return .arcticIce
        case .magmaFire: return .magmaFire
        case .softPink: return .softPink
        case .sageGreen: return .sageGreen
        case .midnightBlue: return .midnightBlue
        case .goldenHour: return .goldenHour
        case .royalPurple: return .royalPurple
        case .aurora: return .aurora
        case .cherryBlossom: return .cherryBlossom
        case .cloudDream: return .cloudDream
        case .deepOcean: return .deepOcean
        case .neonCyberpunk: return .neonCyberpunk
        case .peachyCream: return .peachyCream
        }
    }
    
    var colorPreview: Color {
        theme.look.brandPrimary
    }
}

// MARK: - Enhanced Floating Theme Selector
struct AppFloatingThemeSelector: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.theme) private var theme
    @State private var selectedTheme: AppThemeOption = .audioUI
    @State private var showThemeSelector = false
    
    var body: some View {
        ZStack {
            // Theme Selector Button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showThemeSelector.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(selectedTheme.colorPreview)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(theme.look.brandSecondary.opacity(0.6), lineWidth: 1)
                        )
                    
                    if showThemeSelector {
                        Text(selectedTheme.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(theme.look.textPrimary)
                    }
                    
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(theme.look.textSecondary)
                        .rotationEffect(.degrees(showThemeSelector ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: showThemeSelector)
                }
                .padding(.horizontal, showThemeSelector ? 16 : 10)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            theme.look.brandPrimary.opacity(0.6),
                                            theme.look.brandSecondary.opacity(0.4),
                                            theme.look.glassBorder.opacity(0.4)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(
                    color: theme.look.shadowDark.opacity(0.15),
                    radius: 4,
                    x: 0,
                    y: 2
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Theme Options Overlay - Absolute positioned, doesn't push content
            if showThemeSelector {
                VStack {
                    Spacer()
                        .frame(height: 60) // Space from button
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(AppThemeOption.allCases, id: \.self) { themeOption in
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        selectedTheme = themeOption
                                        themeManager.setTheme(themeOption.theme)
                                        showThemeSelector = false
                                    }
                                }) {
                                    // Just the color circle - no text for thin bar
                                    Circle()
                                        .fill(themeOption.colorPreview)
                                        .frame(width: 28, height: 28) // Smaller for thin bar
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    selectedTheme == themeOption ? 
                                                    theme.look.brandPrimary : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                        .shadow(
                                            color: selectedTheme == themeOption ? 
                                            theme.look.glowPrimary.opacity(0.6) : Color.clear,
                                            radius: selectedTheme == themeOption ? 6 : 0
                                        )
                                    // No background for theme items - just the color circles
                                }
                                .buttonStyle(PlainButtonStyle())
                                .scaleEffect(selectedTheme == themeOption ? 1.15 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedTheme == themeOption)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .frame(height: 52) // Thin bar height
                    .background(
                        RoundedRectangle(cornerRadius: 26) // Pill shape
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 26)
                                    .stroke(theme.look.glassBorder.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
                    )
                    .onTapGesture {
                        // Tap anywhere on bar to close
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showThemeSelector = false
                        }
                    }
                    
                    Spacer() // Push to top
                }
                .zIndex(100) // High z-index to overlay above everything
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .onAppear {
            // Initialize with current theme
            if let currentOption = AppThemeOption.allCases.first(where: { $0.theme.look.brandPrimary == theme.look.brandPrimary }) {
                selectedTheme = currentOption
            }
        }
        .onChange(of: selectedTheme) { oldValue, newValue in
            themeManager.setTheme(newValue.theme)
        }
    }
} 