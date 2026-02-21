//
//  Color+Hex..swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import Foundation
import SwiftUI

extension Color {
    /// Initialize a Color from a hex string, e.g. "#011993" or "011993"
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int = UInt64(0)
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
