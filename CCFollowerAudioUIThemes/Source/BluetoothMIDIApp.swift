//
//  BluetoothMIDIApp.swift
//  CntrlMIDI
//
//  Created by Mitchell Cohen on 10/16/24.
//

import SwiftUI
import AudioUIComponents
import AudioUICore
import AudioUITheme
import MIDIKitIO

// MARK: - Theme Manager
@Observable
class ThemeManager {
    private let userDefaultsKey = "selectedThemeOption"
    
    // Persisted selected theme – default to AudioUI until loaded
    var selectedTheme: Theme
    
    init() {
        // Attempt to load previously-selected theme from UserDefaults
        if let rawValue = UserDefaults.standard.string(forKey: userDefaultsKey),
           let option = AppThemeOption(rawValue: rawValue) {
            selectedTheme = option.theme
        } else {
            selectedTheme = .audioUI
        }
    }
    
    /// Updates the current theme and persists the choice for next launch.
    func setTheme(_ theme: Theme) {
        selectedTheme = theme
        // Persist the corresponding AppThemeOption raw value (if any can be matched)
        if let matchedOption = AppThemeOption.allCases.first(where: { $0.theme.look.brandPrimary == theme.look.brandPrimary }) {
            UserDefaults.standard.set(matchedOption.rawValue, forKey: userDefaultsKey)
        }
    }
}

@main
struct BluetoothMIDIApp: App {
    
    // MARK: - MIDI Manager
    
    @State private var midiManager = ObservableMIDIManager(
        clientName: "CntrlSuiteApp",
        model: "CntrlSuite",
        manufacturer: "CohenConcepts"
    )
    
    @State private var midiHelper = MIDIHelper()
    @State private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(midiManager)
                .environment(midiHelper)
                .environment(themeManager)
                .theme(themeManager.selectedTheme)
                .onAppear {
                    midiHelper.setup(midiManager: midiManager)
                }
        }
    }
}
