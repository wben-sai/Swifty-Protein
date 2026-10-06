//
//  RootViewSwitcher.swift
//  swifty-proteins
//
//  Created by XPI-9 on 2/9/2026.
//



import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    enum RootView {
        case login
        case dashboard
    }

    @Published var rootView: RootView = .login
    @Published private(set) var transition: AnyTransition = .moveOutToTop

    func switchTo(_ view: RootView) {
        switch view {
            case .login: transition = .moveOutToBottom
            case .dashboard: transition = .moveOutToTop
        }

        withAnimation(.easeInOut(duration: 0.35)) {
            rootView = view
        }
    }
}

struct RootViewSwitcher: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            switch appState.rootView {
            case .login:
                Login()
                    .transition(appState.transition)
            case .dashboard:
                Dashboard()
                    .transition(appState.transition)
            }
        }
    }
}

extension AnyTransition {
    static var moveOutToTop: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .bottom),
            removal: .move(edge: .top)
        )
    }
    
    static var moveOutToBottom: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .top),
            removal: .move(edge: .bottom)
        )
    }
}
