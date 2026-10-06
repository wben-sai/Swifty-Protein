//
//  swifty_proteinsApp.swift
//  swifty-proteins
//
//  Created by XPI-9 on 8/8/2026.
//

import SwiftUI
import CoreData

@main
struct swifty_proteinsApp: App {
   
        
    @State private var isActive = false
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if (isActive) {
                    if (isFirstLaunch) {
                       OnboardingView(viewModel: OnboardingViewModel(), isFirstLaunch: $isFirstLaunch)
                    } else {
                        RootViewSwitcher()
                          .environmentObject(appState)
                    }
                } else {
                    SplashScreen(isActive: $isActive)
                }
            }
        }
    }
}
