import SwiftUI
import AudioUIComponents
import AudioUICore
import AudioUITheme
import AudioKit
import AVFoundation
import AVFAudio
import MIDIKitIO

struct EnvelopeFollowerView: View {
    @State private var conductor = EnvelopeFollowerConductor()
    @Environment(MIDIHelper.self) private var midiHelper
    @Environment(\.theme) private var theme
    
    var body: some View {
        ZStack {
            // Background
            theme.look.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Status Section
                    StatusSection(conductor: conductor)
                    
                    // Amplitude Meter
                    AmplitudeMeterView(amplitude: conductor.currentAmplitude)
                    
                    // Audio Parameters
                    AudioParametersSection(conductor: conductor)
                    
                    // MIDI Parameters
                    MIDIParametersSection(conductor: conductor)
                    
                    // Controls
                    ControlsSection(conductor: conductor, midiHelper: midiHelper)
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .onAppear {
            conductor.setupMIDI(midiHelper: midiHelper)
        }
    }
}

struct StatusSection: View {
    var conductor: EnvelopeFollowerConductor
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: 16) {
            Text("System Status")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(theme.look.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                StatusRow(
                    title: "Microphone",
                    status: conductor.microphonePermissionGranted ? "Granted" : "Denied",
                    isActive: conductor.microphonePermissionGranted
                )
                
                StatusRow(
                    title: "Audio Engine",
                    status: conductor.isEngineRunning ? "Running" : "Stopped",
                    isActive: conductor.isEngineRunning
                )
                
                StatusRow(
                    title: "Envelope Following",
                    status: conductor.isActive ? "Active" : "Inactive",
                    isActive: conductor.isActive
                )
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
}

struct StatusRow: View {
    let title: String
    let status: String
    let isActive: Bool
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack {
            Circle()
                .fill(isActive ? theme.look.stateSuccess : theme.look.stateError)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(theme.look.textPrimary.opacity(0.2), lineWidth: 1)
                )
            
            Text(title)
                .foregroundColor(theme.look.textPrimary)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(status)
                .foregroundColor(theme.look.textSecondary)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct AmplitudeMeterView: View {
    let amplitude: Float
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Input Level")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(theme.look.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.look.surfaceSecondary)
                            .frame(height: 24)
                        
                        // Level indicator
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        theme.look.stateSuccess,
                                        theme.look.stateWarning,
                                        theme.look.stateError
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * CGFloat(amplitude),
                                height: 24
                            )
                            .animation(.easeInOut(duration: 0.1), value: amplitude)
                    }
                }
                .frame(height: 24)
                
                Text(String(format: "%.3f", amplitude))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(theme.look.textSecondary)
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
}

struct AudioParametersSection: View {
    @Bindable var conductor: EnvelopeFollowerConductor
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Audio Parameters")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(theme.look.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 20) {
                ParameterSlider(
                    title: "Threshold",
                    value: $conductor.threshold,
                    range: 0...0.5,
                    step: 0.01,
                    format: "%.2f"
                )
                
                ParameterSlider(
                    title: "Gain",
                    value: $conductor.gain,
                    range: 0.1...10.0,
                    step: 0.1,
                    format: "%.1f"
                )
                
                ParameterSlider(
                    title: "Smoothing",
                    value: $conductor.smoothing,
                    range: 0...0.99,
                    step: 0.01,
                    format: "%.2f"
                )
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
}

struct ParameterSlider: View {
    let title: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    let step: Float
    let format: String
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .foregroundColor(theme.look.textPrimary)
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: format, value))
                    .foregroundColor(theme.look.textSecondary)
                    .font(.system(.body, design: .monospaced))
            }
            
            Slider(value: $value, in: range, step: step)
                .tint(theme.look.accent)
        }
    }
}

struct MIDIParametersSection: View {
    @Bindable var conductor: EnvelopeFollowerConductor
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: 16) {
            Text("MIDI Parameters")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(theme.look.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Channel")
                        .foregroundColor(theme.look.textPrimary)
                        .fontWeight(.medium)
                    
                    Picker("Channel", selection: $conductor.midiChannel) {
                        ForEach(0..<16, id: \.self) { channel in
                            Text("\(channel + 1)").tag(channel)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.look.surfaceSecondary.opacity(0.5))
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("CC Number")
                        .foregroundColor(theme.look.textPrimary)
                        .fontWeight(.medium)
                    
                    Picker("CC", selection: $conductor.ccNumber) {
                        ForEach(Array(1..<128), id: \.self) { cc in
                            Text("\(cc)").tag(cc)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.look.surfaceSecondary.opacity(0.5))
                    )
                }
            }
            
            // Current CC Value Display
            VStack(spacing: 8) {
                Text("Current CC Value")
                    .foregroundColor(theme.look.textPrimary)
                    .fontWeight(.medium)
                
                Text("\(conductor.ccValue)")
                    .font(.system(.largeTitle, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(theme.look.accent)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.look.surfaceElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.look.glassBorder, lineWidth: 1)
                            )
                    )
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
}

struct ControlsSection: View {
    var conductor: EnvelopeFollowerConductor
    var midiHelper: MIDIHelper
    @Environment(\.theme) private var theme
    @State private var showingBluetoothMIDI = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Controls")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(theme.look.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                // Main control button
                Button(action: {
                    conductor.toggleActive()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: conductor.isActive ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title2)
                        Text(conductor.isActive ? "Stop Following" : "Start Following")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(conductor.isActive ? theme.look.stateError : theme.look.stateSuccess)
                    )
                }
                .disabled(!conductor.microphonePermissionGranted)
                .opacity(conductor.microphonePermissionGranted ? 1.0 : 0.6)
                
                // Secondary controls
                HStack(spacing: 16) {
                    Button("Test MIDI") {
                        midiHelper.sendTestMIDIEvent()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.look.accent)
                    )
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    
                    #if os(iOS)
                    Button("Bluetooth") {
                        showingBluetoothMIDI = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.look.brandPrimary)
                    )
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    #endif
                }
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
        #if os(iOS)
        .sheet(isPresented: $showingBluetoothMIDI) {
            NavigationView {
                BluetoothMIDIView()
                    .navigationTitle("Bluetooth MIDI")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingBluetoothMIDI = false
                            }
                        }
                    }
            }
        }
        #endif
    }
}

// MARK: - Preview
#Preview {
    EnvelopeFollowerView()
        .environment(MIDIHelper())
        .theme(.audioUI)
} 