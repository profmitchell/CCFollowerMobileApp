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
    public var midiManager: MIDIManager?
    
    public init() { 
        setupMIDI()
    }
    
    private func setupMIDI() {
        midiManager = MIDIManager(
            clientName: "CC Follower",
            model: "CC Follower",
            manufacturer: "YourCompany"
        )
        
        guard let midiManager = midiManager else { return }
        
        do {
            print("Starting MIDI services.")
            try midiManager.start()
        } catch {
            print("Error starting MIDI services:", error.localizedDescription)
        }
        
        setupConnections()
    }
    
    public func setup(midiManager: MIDIManager) {
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
    
    func sendTestMIDIEvent() {
        let conn = midiManager?.managedOutputConnections["Broadcaster"]
        try? conn?.send(event: .cc(.expression, value: .midi1(64), channel: 0))
    }
}
