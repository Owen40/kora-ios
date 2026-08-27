//
//  Theme.swift
//  Kora
//
//  Created by mac on 4/4/26.
//
import SwiftUI

// MARK: - Hex Color Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Dynamic Theme Engine
struct Theme {
    static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#1E1A16") : Color(hex: "#F5E9D8")
    }
    
    static func text(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#F0E2D4") : Color(hex: "#3C2A21")
    }
    
    static func primary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#6B9E6A") : Color(hex: "#5B8C5A")
    }
    
    static func button(for scheme: ColorScheme) -> Color {
        Color(hex: "#E76F51") // Constant across both themes based on palette
    }
    
    static func accent(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#249F8F") : Color(hex: "#2A9D8F")
    }
    
    static func card(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "#2A241F") : Color(hex: "#FFF4EC")
    }
    
    static func placeholderText(for scheme: ColorScheme) -> Color {
        Color(hex: "#A59289") // Keeps consistency in input boxes
    }
}
