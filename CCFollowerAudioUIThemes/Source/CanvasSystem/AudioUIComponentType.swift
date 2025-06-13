import Foundation
import SwiftUI

// MARK: - AudioUI Component Type
public enum AudioUIComponentType: String, CaseIterable, Identifiable, Codable, Sendable {
    case knobMinimal1
    case sliderMinimal1
    case xyPadMinimal1
    case drumPadMinimal1
    case toggleButtonNeumorphic1
    case gyroMinimal
    
    public var id: String { self.rawValue }
    
    public var displayName: String {
        switch self {
        case .knobMinimal1:
            return "Minimal Knob"
        case .sliderMinimal1:
            return "Minimal Slider"
        case .xyPadMinimal1:
            return "XY Pad"
        case .drumPadMinimal1:
            return "Drum Pad"
        case .toggleButtonNeumorphic1:
            return "Toggle Button"
        case .gyroMinimal:
            return "Gyroscope"
        }
    }
    
    public var iconName: String {
        switch self {
        case .knobMinimal1:
            return "circle.grid.3x3.fill"
        case .sliderMinimal1:
            return "slider.horizontal.3"
        case .xyPadMinimal1:
            return "square.grid.3x3.fill"
        case .drumPadMinimal1:
            return "square.grid.2x2.fill"
        case .toggleButtonNeumorphic1:
            return "power"
        case .gyroMinimal:
            return "gyroscope"
        }
    }
    
    public var defaultSize: CGSize {
        switch self {
        case .knobMinimal1:
            return CGSize(width: 80, height: 80)
        case .sliderMinimal1:
            return CGSize(width: 150, height: 50)
        case .xyPadMinimal1:
            return CGSize(width: 180, height: 180)
        case .drumPadMinimal1:
            return CGSize(width: 100, height: 100)
        case .toggleButtonNeumorphic1:
            return CGSize(width: 80, height: 80)
        case .gyroMinimal:
            return CGSize(width: 120, height: 120)
        }
    }
} 