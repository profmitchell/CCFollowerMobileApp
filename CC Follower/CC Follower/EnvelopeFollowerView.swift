import SwiftUI

struct EnvelopeFollowerView: View {
    @State private var conductor = EnvelopeFollowerConductor()
    @State private var midiHelper = MIDIHelper()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
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
                
                Spacer()
            }
            .padding()
            .navigationTitle("Envelope Follower")
            .onAppear {
                conductor.setupMIDI(midiHelper: midiHelper)
            }
        }
    }
}

struct StatusSection: View {
    var conductor: EnvelopeFollowerConductor
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Circle()
                    .fill(conductor.microphonePermissionGranted ? .green : .red)
                    .frame(width: 12, height: 12)
                Text("Microphone: \(conductor.microphonePermissionGranted ? "Granted" : "Denied")")
                Spacer()
            }
            
            HStack {
                Circle()
                    .fill(conductor.isEngineRunning ? .green : .gray)
                    .frame(width: 12, height: 12)
                Text("Engine: \(conductor.isEngineRunning ? "Running" : "Stopped")")
                Spacer()
            }
            
            HStack {
                Circle()
                    .fill(conductor.isActive ? .blue : .gray)
                    .frame(width: 12, height: 12)
                Text("Envelope Following: \(conductor.isActive ? "Active" : "Inactive")")
                Spacer()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct AmplitudeMeterView: View {
    let amplitude: Float
    
    var body: some View {
        VStack {
            Text("Input Level")
                .font(.headline)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 20)
                    
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.green, .yellow, .red]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * CGFloat(amplitude), height: 20)
                }
            }
            .frame(height: 20)
            .cornerRadius(10)
            
            Text(String(format: "%.3f", amplitude))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct AudioParametersSection: View {
    @Bindable var conductor: EnvelopeFollowerConductor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Audio Parameters")
                .font(.headline)
            
            VStack {
                HStack {
                    Text("Threshold")
                    Spacer()
                    Text(String(format: "%.2f", conductor.threshold))
                        .foregroundColor(.secondary)
                }
                Slider(value: $conductor.threshold, in: 0...0.5, step: 0.01)
            }
            
            VStack {
                HStack {
                    Text("Gain")
                    Spacer()
                    Text(String(format: "%.1f", conductor.gain))
                        .foregroundColor(.secondary)
                }
                Slider(value: $conductor.gain, in: 0.1...10.0, step: 0.1)
            }
            
            VStack {
                HStack {
                    Text("Smoothing")
                    Spacer()
                    Text(String(format: "%.2f", conductor.smoothing))
                        .foregroundColor(.secondary)
                }
                Slider(value: $conductor.smoothing, in: 0...0.99, step: 0.01)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct MIDIParametersSection: View {
    @Bindable var conductor: EnvelopeFollowerConductor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("MIDI Parameters")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Channel")
                    Picker("Channel", selection: $conductor.midiChannel) {
                        ForEach(0..<16, id: \.self) { channel in
                            Text("\(channel + 1)").tag(channel)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                }
                
                VStack(alignment: .leading) {
                    Text("CC Number")
                    Picker("CC", selection: $conductor.ccNumber) {
                        ForEach(Array(1..<128), id: \.self) { cc in
                            Text("\(cc)").tag(cc)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                }
            }
            
            HStack {
                Text("Current CC Value:")
                Spacer()
                Text("\(conductor.ccValue)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ControlsSection: View {
    var conductor: EnvelopeFollowerConductor
    var midiHelper: MIDIHelper
    
    @State private var showingBluetoothMIDI = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Main control button
            Button(action: {
                conductor.toggleActive()
            }) {
                HStack {
                    Image(systemName: conductor.isActive ? "stop.circle.fill" : "play.circle.fill")
                    Text(conductor.isActive ? "Stop Following" : "Start Following")
                }
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(conductor.isActive ? Color.red : Color.green)
                .cornerRadius(10)
            }
            .disabled(!conductor.microphonePermissionGranted)
            
            // MIDI controls
            HStack(spacing: 15) {
                Button("Test MIDI") {
                    midiHelper.sendTestMIDIEvent()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                #if os(iOS)
                Button("Bluetooth MIDI") {
                    showingBluetoothMIDI = true
                }
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(8)
                #endif
            }
        }
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

#Preview {
    EnvelopeFollowerView()
} 