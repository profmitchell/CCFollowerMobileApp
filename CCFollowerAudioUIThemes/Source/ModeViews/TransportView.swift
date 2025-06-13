//
//  TransportView.swift
//  CntrlSuite - Professional Audio Controller
//  © 2025 CohenConcepts • Licensed under MIT License
//

import SwiftUI
import AudioUIComponents
import AudioUICore
import AudioUITheme
import MIDIKitIO
import Foundation

// MARK: - Mackie Control Commands
public enum MackieControlCommand: UInt8, CaseIterable {
    case rewind = 0x5B
    case fastForward = 0x5C
    case stop = 0x5D
    case play = 0x5E
    case record = 0x5F
    case cursorUp = 0x60
    case cursorDown = 0x61
    case cursorLeft = 0x62
    case cursorRight = 0x63
    case zoom = 0x64
    case scrub = 0x65
    case loop = 0x66
    case click = 0x67
    
    public var icon: String {
        switch self {
        case .rewind: return "backward.fill"
        case .fastForward: return "forward.fill"
        case .stop: return "stop.fill"
        case .play: return "play.fill"
        case .record: return "record.circle.fill"
        case .cursorUp: return "chevron.up"
        case .cursorDown: return "chevron.down"
        case .cursorLeft: return "chevron.left"
        case .cursorRight: return "chevron.right"
        case .zoom: return "plus.magnifyingglass"
        case .scrub: return "dial.high"
        case .loop: return "repeat"
        case .click: return "metronome"
        }
    }
}

// MARK: - Inset Neumorphic Button
public struct InsetNeumorphicButton: View {
    @Environment(\.theme) private var theme
    
    let icon: String
    let size: CGFloat
    let isActive: Bool
    let glowColor: Color?
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var pulseAnimation = false
    
    public init(
        icon: String,
        size: CGFloat = 56,
        isActive: Bool = false,
        glowColor: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.isActive = isActive
        self.glowColor = glowColor
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }) {
            ZStack {
                // Outer glow for active state
                if isActive {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    (glowColor ?? theme.look.glowAccent).opacity(0.8),
                                    (glowColor ?? theme.look.glowAccent).opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: size * 0.1,
                                endRadius: size * 0.8
                            )
                        )
                        .frame(width: size * 1.8, height: size * 1.8)
                        .blur(radius: 15)
                        .scaleEffect(pulseAnimation ? 1.15 : 0.95)
                        .animation(
                            .easeInOut(duration: 2.5)
                            .repeatForever(autoreverses: true),
                            value: pulseAnimation
                        )
                }
                
                // Base with inset effect
                Circle()
                    .fill(isPressed ? theme.look.surfacePressed : theme.look.surface)
                    .frame(width: size, height: size)
                    .overlay(
                        // Inner gradient for depth
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        theme.look.shadowDark.opacity(isPressed ? 0.4 : 0.2),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blendMode(.multiply)
                    )
                    .shadow(
                        color: theme.look.shadowDark.opacity(0.6),
                        radius: isPressed ? 3 : 6,
                        x: isPressed ? 2 : 4,
                        y: isPressed ? 2 : 4
                    )
                    .shadow(
                        color: theme.look.shadowLight.opacity(0.8),
                        radius: isPressed ? 3 : 6,
                        x: isPressed ? -2 : -4,
                        y: isPressed ? -2 : -4
                    )
                    .overlay(
                        // Rim highlight
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        theme.look.glassBorder.opacity(0.3),
                                        theme.look.glassBorder.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                
                // Icon
                Image(systemName: icon)
                    .font(.system(size: size * 0.38, weight: .medium, design: .default))
                    .foregroundStyle(
                        LinearGradient(
                            colors: isActive ?
                            [glowColor ?? theme.look.glowAccent, (glowColor ?? theme.look.glowAccent).opacity(0.8)] :
                                [theme.look.textSecondary, theme.look.textTertiary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(
                        color: isActive ? (glowColor ?? theme.look.glowAccent).opacity(0.6) : .clear,
                        radius: 8
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if isActive {
                pulseAnimation = true
            }
        }
    }
}

// MARK: - Compact Neumorphic Card
public struct CompactNeumorphicCard<Content: View>: View {
    @Environment(\.theme) private var theme
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.look.surfaceElevated)
                    .shadow(
                        color: theme.look.shadowDark.opacity(0.4),
                        radius: 10,
                        x: 5,
                        y: 5
                    )
                    .shadow(
                        color: theme.look.shadowLight.opacity(0.8),
                        radius: 10,
                        x: -5,
                        y: -5
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        theme.look.glassBorder.opacity(0.2),
                                        theme.look.glassBorder.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
    }
}

// MARK: - LED Status Indicator
public struct LEDIndicator: View {
    @Environment(\.theme) private var theme
    let isOn: Bool
    let color: Color
    
    @State private var glowAnimation = false
    
    public var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: isOn ?
                    [color, color.opacity(0.6), color.opacity(0.3)] :
                        [theme.look.surfaceDeep, theme.look.surfaceDeep.opacity(0.8)],
                    center: .center,
                    startRadius: 0,
                    endRadius: 8
                )
            )
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .fill(isOn ? color.opacity(0.3) : Color.clear)
                    .blur(radius: 6)
                    .scaleEffect(glowAnimation ? 1.5 : 1.0)
                    .animation(
                        isOn ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default,
                        value: glowAnimation
                    )
            )
            .shadow(
                color: theme.look.shadowDark.opacity(0.6),
                radius: 2,
                x: 1,
                y: 1
            )
            .onAppear {
                if isOn {
                    glowAnimation = true
                }
            }
    }
}

// MARK: - Transport State
@Observable
public class TransportState {
    public var isPlaying = false
    public var isRecording = false
    public var isStopped = true
    public var isLooping = false
    public var isClickOn = false
    public var bpm: Double = 120.0
}

// MARK: - Condensed Transport View
public struct TransportView: View {
    @Environment(\.theme) private var theme
    @Environment(MIDIHelper.self) private var midiHelper
    @State private var transportState = TransportState()
    @State private var showSettings = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background
            theme.look.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Top spacer for unified header
                    Spacer()
                        .frame(height: 80)
                    
                    // Header (without settings button)
                    transportHeaderSection
                    
                    // Main Transport
                    CompactNeumorphicCard {
                        mainTransportSection
                    }
                    
                    // Status Display
                    CompactNeumorphicCard {
                        statusSection
                    }
                    
                    // Navigation & Utilities
                    HStack(spacing: 16) {
                        CompactNeumorphicCard {
                            navigationSection
                        }
                        
                        CompactNeumorphicCard {
                            utilitiesSection
                        }
                    }
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Transport Header Section (No Settings Button)
    private var transportHeaderSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("MACKIE CONTROL")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.look.textPrimary, theme.look.textSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            HStack(spacing: 8) {
                LEDIndicator(isOn: true, color: theme.look.stateSuccess)
                Text("Connected")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.look.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Main Transport Section
    private var mainTransportSection: some View {
        HStack(spacing: 16) {
            InsetNeumorphicButton(
                icon: MackieControlCommand.rewind.icon,
                size: 44,
                action: { sendCommand(.rewind) }
            )
            
            InsetNeumorphicButton(
                icon: MackieControlCommand.stop.icon,
                size: 52,
                isActive: transportState.isStopped,
                glowColor: theme.look.stateWarning,
                action: {
                    sendCommand(.stop)
                    transportState.isStopped = true
                    transportState.isPlaying = false
                    transportState.isRecording = false
                }
            )
            
            InsetNeumorphicButton(
                icon: MackieControlCommand.play.icon,
                size: 64,
                isActive: transportState.isPlaying,
                glowColor: theme.look.stateSuccess,
                action: {
                    sendCommand(.play)
                    transportState.isPlaying = true
                    transportState.isStopped = false
                    transportState.isRecording = false
                }
            )
            
            InsetNeumorphicButton(
                icon: MackieControlCommand.record.icon,
                size: 52,
                isActive: transportState.isRecording,
                glowColor: theme.look.stateError,
                action: {
                    sendCommand(.record)
                    transportState.isRecording = true
                    transportState.isPlaying = false
                    transportState.isStopped = false
                }
            )
            
            InsetNeumorphicButton(
                icon: MackieControlCommand.fastForward.icon,
                size: 44,
                action: { sendCommand(.fastForward) }
            )
        }
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        HStack(spacing: 24) {
            // Position
            VStack(alignment: .leading, spacing: 4) {
                Text("POSITION")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(theme.look.textTertiary)
                
                Text("00:00:00.00")
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.look.accent, theme.look.accentSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            Spacer()
            
            // BPM
            VStack(alignment: .trailing, spacing: 4) {
                Text("TEMPO")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(theme.look.textTertiary)
                
                HStack(spacing: 4) {
                    Text(String(format: "%.1f", transportState.bpm))
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [theme.look.brandPrimary, theme.look.brandSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("BPM")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(theme.look.textTertiary)
                }
            }
        }
    }
    
    // MARK: - Navigation Section
    private var navigationSection: some View {
        VStack(spacing: 12) {
            InsetNeumorphicButton(
                icon: MackieControlCommand.cursorUp.icon,
                size: 36,
                action: { sendCommand(.cursorUp) }
            )
            
            HStack(spacing: 12) {
                InsetNeumorphicButton(
                    icon: MackieControlCommand.cursorLeft.icon,
                    size: 36,
                    action: { sendCommand(.cursorLeft) }
                )
                
                InsetNeumorphicButton(
                    icon: MackieControlCommand.zoom.icon,
                    size: 44,
                    glowColor: theme.look.accentTertiary,
                    action: { sendCommand(.zoom) }
                )
                
                InsetNeumorphicButton(
                    icon: MackieControlCommand.cursorRight.icon,
                    size: 36,
                    action: { sendCommand(.cursorRight) }
                )
            }
            
            InsetNeumorphicButton(
                icon: MackieControlCommand.cursorDown.icon,
                size: 36,
                action: { sendCommand(.cursorDown) }
            )
        }
    }
    
    // MARK: - Utilities Section
    private var utilitiesSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                VStack(spacing: 6) {
                    InsetNeumorphicButton(
                        icon: MackieControlCommand.loop.icon,
                        size: 44,
                        isActive: transportState.isLooping,
                        glowColor: theme.look.stateInfo,
                        action: {
                            sendCommand(.loop)
                            transportState.isLooping.toggle()
                        }
                    )
                    Text("LOOP")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(theme.look.textTertiary)
                }
                
                VStack(spacing: 6) {
                    InsetNeumorphicButton(
                        icon: MackieControlCommand.click.icon,
                        size: 44,
                        isActive: transportState.isClickOn,
                        glowColor: theme.look.paleGreenAccent,
                        action: {
                            sendCommand(.click)
                            transportState.isClickOn.toggle()
                        }
                    )
                    Text("CLICK")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(theme.look.textTertiary)
                }
            }
            
            VStack(spacing: 6) {
                InsetNeumorphicButton(
                    icon: MackieControlCommand.scrub.icon,
                    size: 44,
                    glowColor: theme.look.subtleAccent,
                    action: { sendCommand(.scrub) }
                )
                Text("SCRUB")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(theme.look.textTertiary)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func sendCommand(_ command: MackieControlCommand) {
        let noteOnData: [UInt8] = [0x90, command.rawValue, 0x7F]
        let noteOffData: [UInt8] = [0x80, command.rawValue, 0x00]
        
        midiHelper.sendRawMIDI(noteOnData)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            midiHelper.sendRawMIDI(noteOffData)
        }
    }
}

// MARK: - Preview
struct TransportView_Previews: PreviewProvider {
    static var previews: some View {
        TransportView()
            .environment(MIDIHelper())
            .theme(.audioUI)
    }
}
