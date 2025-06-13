//
//  MIDIHelper.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2025 Steffan Andrews • Licensed under MIT License
//

import MIDIKitIO
import SwiftUI

/// Receiving MIDI happens on an asynchronous background thread. That means it cannot update
/// SwiftUI view state directly. Therefore, we need a helper class marked with `@Observable`
/// which contains properties that SwiftUI can use to update views.
@Observable final class MIDIHelper {
    private weak var midiManager: ObservableMIDIManager?
    
    public init() { }
    
    public func setup(midiManager: ObservableMIDIManager) {
        self.midiManager = midiManager
        
        do {
            print("Starting MIDI services.")
            try midiManager.start()
        } catch {
            print("Error starting MIDI services:", error.localizedDescription)
        }
        
        setupConnections()
    }
    
    // MARK: - Connections
    
    private func setupConnections() {
        guard let midiManager else { return }
        
        // set up a listener that automatically connects to all MIDI outputs
        // and prints the events to the console
        
        do {
            try midiManager.addInputConnection(
                to: .allOutputs, // auto-connect to all outputs that may appear
                tag: "Listener",
                filter: .owned(), // don't allow self-created virtual endpoints
                receiver: .eventsLogging(options: [
                    .bundleRPNAndNRPNDataEntryLSB,
                    .filterActiveSensingAndClock
                ])
            )
        } catch {
            print(
                "Error setting up managed MIDI all-listener connection:",
                error.localizedDescription
            )
        }
        
        // set up a broadcaster that can send events to all MIDI inputs
        
        do {
            try midiManager.addOutputConnection(
                to: .allInputs, // auto-connect to all inputs that may appear
                tag: "Broadcaster",
                filter: .owned() // don't allow self-created virtual endpoints
            )
        } catch {
            print(
                "Error setting up managed MIDI all-listener connection:",
                error.localizedDescription
            )
        }
    }
    
    // MARK: - MIDI Sending
    
    func sendTestMIDIEvent() {
        let conn = midiManager?.managedOutputConnections["Broadcaster"]
        try? conn?.send(event: .cc(.expression, value: .midi1(64), channel: 0))
    }
    
    func sendComponentMIDI(_ event: MIDIEvent) {
        guard let midiManager = midiManager,
              let connection = midiManager.managedOutputConnections["Broadcaster"] else {
            print("No MIDI connection available for component event")
            return
        }
        
        do {
            try connection.send(event: event)
        } catch {
            print("Error sending component MIDI event: \(error.localizedDescription)")
        }
    }
    
    /// Send raw MIDI data bytes for protocols like Mackie Control
    func sendRawMIDI(_ data: [UInt8]) {
        guard let midiManager = midiManager,
              let connection = midiManager.managedOutputConnections["Broadcaster"] else {
            print("No MIDI connection available for raw data")
            return
        }
        
        do {
            // Convert raw bytes to MIDI events based on the data type
            if data.count >= 3 {
                let status = data[0]
                let data1 = data[1]
                let data2 = data.count > 2 ? data[2] : 0
                
                // Handle different MIDI message types
                switch status & 0xF0 {
                case 0x90: // Note On
                    let event = MIDIEvent.noteOn(
                        UInt7(data1 & 0x7F), // Convert UInt8 to UInt7
                        velocity: .midi1(UInt7(data2 & 0x7F)),
                        channel: UInt4(status & 0x0F)
                    )
                    try connection.send(event: event)
                    
                case 0x80: // Note Off
                    let event = MIDIEvent.noteOff(
                        UInt7(data1 & 0x7F), // Convert UInt8 to UInt7
                        velocity: .midi1(UInt7(data2 & 0x7F)),
                        channel: UInt4(status & 0x0F)
                    )
                    try connection.send(event: event)
                    
                case 0xB0: // Control Change
                    let event = MIDIEvent.cc(
                        UInt7(data1 & 0x7F), // Convert UInt8 to UInt7
                        value: .midi1(UInt7(data2 & 0x7F)),
                        channel: UInt4(status & 0x0F)
                    )
                    try connection.send(event: event)
                    
                case 0xF0: // System Exclusive
                    if status == 0xF0 {
                        let event = try MIDIEvent.sysEx7(rawBytes: data)
                        try connection.send(event: event)
                    }
                    
                default:
                    print("Unsupported MIDI message type: \(String(status, radix: 16))")
                }
            }
        } catch {
            print("Error sending raw MIDI data: \(error.localizedDescription)")
        }
    }
}
