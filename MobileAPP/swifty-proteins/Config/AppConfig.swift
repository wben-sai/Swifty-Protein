//
//  AppConfig.swift
//  swifty-proteins
//
//  Created by XPI-9 on 8/9/2026.
//


import SwiftUI

class AppConfig {
    
    static let shared = AppConfig()
    private init() { loadTheme() }
    
    
    struct Theme : Equatable{
        var background: Color
        var accent: Color
        var font: Color
        var subText: Color
        var card: Color
        
        var xBack: Color
    }
    
    
    var theme: Theme = Theme(
        background: Color(hex: "FFFFFF"),
        accent: Color(hex: "#2ba1a1"),
        font: Color(hex: "000000"),
        subText:  Color(hex: "#8c8c8c"),
        card: .gray.opacity(0.1),
        xBack: Color(hex: "000000")
    )
    
    func loadTheme() {
        self.theme = AppConfig.Theme(
            background: Color(hex: "FFFFFF"),
            accent: Color(hex: "#2ba1a1"),
            font: Color(hex: "000000"),
            subText:  Color(hex: "#8c8c8c"),
            card: .gray.opacity(0.1),
            xBack: Color(hex: "000000")
        )
    }
}
