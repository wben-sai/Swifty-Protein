//
//  OnboardingViewModel.swift
//  swifty-proteins
//
//  Created by XPI-9 on 2/9/2026.
//

import Foundation
import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    
    @Published var onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "img2",
            title: "Explore Molecular Structures",
            description: " Discover the fascinating world of molecules through interactive 3D visualization. Explore their shapes, atoms, and bonds from every angle."
        ),
        OnboardingPage(
            imageName: "img3",
            title: "Discover Ligands",
            description: "Search and explore a collection of ligands from the Protein Data Bank. Find the molecular structures you’re interested in and load them instantly."
        ),
        OnboardingPage(
            imageName: "img1",
            title: "Interact in 3D",
            description: "Rotate, zoom, and explore molecular models with smooth touch gestures. Tap on atoms to discover detailed information about their elements."
        ),
        OnboardingPage(
            imageName: "img4",
            title: "Learn & Share",
            description: " Understand molecular structures through clear visual representations, then capture and share your favorite 3D views with others."
        )
    ]
    
    
    @Published var currentPageIndex: Int = 0
    @Published var onboardingProgress: CGFloat = 0
    
    var isFinish = false
    
    func updateOnboardingProgress() {
        withAnimation {
            onboardingProgress = CGFloat(currentPageIndex + 1) / CGFloat(onboardingPages.count)
        }
    }
    
    func goToNextPage() {
        if currentPageIndex < onboardingPages.count - 1 {
            withAnimation {
                currentPageIndex += 1
            }
        }
    }
    
    func skipOnboarding() {
        currentPageIndex = onboardingPages.count - 1
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}
