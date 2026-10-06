//
//  SplashScreen.swift
//  swifty-proteins
//
//  Created by XPI-9 on 2/9/2026.
//

import SwiftUI
import WebKit

struct SplashScreen: View {
    @Binding var isActive: Bool

    @State private var rotation: Double = 0
    @State private var nucleusScale: CGFloat = 0.4
    @State private var nucleusOpacity: Double = 0
    @State private var ringsOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 10
    @State private var taglineOpacity: Double = 0

    var body: some View {
        VStack(spacing: 28) {
                
            GIFView(gifName: "methane")
                .frame(width: 160, height: 160)
                .opacity(ringsOpacity)

            VStack(spacing: 6) {
                Text("42 Carbon")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(AppConfig.shared.theme.font)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                Text("Small tools. Big power.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppConfig.shared.theme.subText)
                    .opacity(taglineOpacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image("atomBackground")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(AppConfig.shared.theme.font)
                .opacity(0.088)
                .mask(
                    LinearGradient(
                        colors: [
                            AppConfig.shared.theme.font,
                            Color.clear,
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .edgesIgnoringSafeArea(.all)
        }
        .background(AppConfig.shared.theme.background)
        .task {
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
                nucleusScale = 1.0
                nucleusOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                ringsOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                taglineOpacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isActive = true
                }
            }
        }
    }
}

struct GIFView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)

        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false

        guard let path = Bundle.main.path(forResource: gifName, ofType: "gif" ) else {
            print("❌ GIF not found: \(gifName).gif")
            return webView
        }

        let url = URL(fileURLWithPath: path)

        do {
            let data = try Data(contentsOf: url)
            webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
        } catch {
            print("❌ Error loading GIF:", error)
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
