//
//  OnboardingView.swift
//  swifty-proteins
//
//  Created by XPI-9 on 2/9/2026.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var isFirstLaunch: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $viewModel.currentPageIndex) {
                    ForEach(viewModel.onboardingPages.indices, id: \.self) { index in
                        OnboardingPageView(page: viewModel.onboardingPages[index], index: index)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
     
            let stepColors: [Color] = [
                Color(hex: "#5b9afd"),
                Color(hex: "#81F17E"),
                Color(hex: "#f6c51b"),
                Color(hex: "#998cdb"),
            ]
            
            GeometryReader { geo in
                VStack {
                    CustomTabIndicator(pageCount: viewModel.onboardingPages.count, currentIndex: viewModel.currentPageIndex)
                        .padding(.bottom, 15)
                    
                    let btnTxt = (viewModel.currentPageIndex == viewModel.onboardingPages.count - 1) ? "Get started" : "Next"
                    
                    Button(action: {
                        viewModel.goToNextPage()
                        if (btnTxt == "Get started") {
                            isFirstLaunch.toggle()
                        }
                    }) {
                        Text(btnTxt)
                            .font(.system(size: 13, weight: .bold, design: .default))
                            .foregroundColor(AppConfig.shared.theme.xBack)
                            .padding(.vertical, 16)
                            .frame(width: 260)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(
                                stepColors[viewModel.currentPageIndex % stepColors.count],
                                lineWidth: 1
                            )
                    )
                    .padding(.bottom, 20)
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.horizontal, 25)
                .padding(.bottom, (geo.safeAreaInsets.bottom  == 0) ? 15 : 0)
               
            }
        }
        .background {
            backgroundGradient()
                .mask {
                    Image("atomBackground")
                        .resizable()
                        .renderingMode(.template)
                }
                .edgesIgnoringSafeArea(.all)
        }
        .background(AppConfig.shared.theme.background)
    }
    
    func backgroundGradient() -> LinearGradient {
        let topStop = min(460 / UIScreen.main.bounds.height, 1)

        switch viewModel.currentPageIndex {
        case 1: // Green
            return LinearGradient(
                stops: [
                    .init(color: Color(hex: "#81F17E").opacity(0.8), location: 0),
                    .init(color: Color(hex: "#81F17E").opacity(0.2), location: topStop * 0.6),
                    .init(color: AppConfig.shared.theme.background, location: topStop),
                    .init(color: AppConfig.shared.theme.background, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

        case 3: // Purple
            return LinearGradient(
                stops: [
                    .init(color: Color(hex: "#998CDB").opacity(0.8), location: 0),
                    .init(color: Color(hex: "#998CDB").opacity(0.2), location: topStop * 0.6),
                    .init(color: AppConfig.shared.theme.background, location: topStop),
                    .init(color: AppConfig.shared.theme.background, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

        case 2: // Yellow
            return LinearGradient(
                stops: [
                    .init(color: Color(hex: "#F6C51B").opacity(0.8), location: 0),
                    .init(color: Color(hex: "#F6C51B").opacity(0.2), location: topStop * 0.6),
                    .init(color: AppConfig.shared.theme.background, location: topStop),
                    .init(color: AppConfig.shared.theme.background, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

        case 0: // Blue
            return LinearGradient(
                stops: [
                    .init(color: Color(hex: "#5B9AFD").opacity(0.8), location: 0),
                    .init(color: Color(hex: "#5B9AFD").opacity(0.2), location: topStop * 0.6),
                    .init(color: AppConfig.shared.theme.background, location: topStop),
                    .init(color: AppConfig.shared.theme.background, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

        default:
            return LinearGradient(colors: [.black, .black], startPoint: .top, endPoint: .bottom)
        }
    }
}


struct OnboardingPageView: View {
    let page: OnboardingPage
    let index: Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Image(page.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: (UIScreen.main.bounds.height * 0.3))
                .padding(.bottom, 20)
            
            VStack {
                Text(page.title)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(AppConfig.shared.theme.font)
                    .padding(.bottom, 20)
                
                Text(page.description)
                    .lineSpacing(10)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppConfig.shared.theme.subText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .animation(.easeInOut, value: index)
                    .padding()
                    .background(
                        AnimatedGlassBorder()
                    )
            }
            
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 25)
    }
}

struct AnimatedGlassBorder: View {
    @State private var progress: CGFloat = 0

       var body: some View {
           RoundedRectangle(cornerRadius: 15)
               .fill(LinearGradient(gradient: Gradient(colors: [AppConfig.shared.theme.card, AppConfig.shared.theme.background, AppConfig.shared.theme.background]), startPoint: .topLeading, endPoint: .bottomTrailing))
               .overlay(
                   RoundedRectangle(cornerRadius: 15)
                       .trim(from: progress, to: progress + 0.15)
                       .stroke(
                           AngularGradient(
                               colors: [
                                AppConfig.shared.theme.xBack.opacity(0.02),
                                AppConfig.shared.theme.xBack.opacity(0.9),
                                AppConfig.shared.theme.xBack.opacity(0.02)
                               ],
                               center: .center
                           ),
                           style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                       )
               )
               .onAppear {
                   withAnimation(
                       .linear(duration: 5)
                       .repeatForever(autoreverses: false)
                   ) {
                       progress = 1
                   }
               }
       }
}

struct CustomTabIndicator: View {
    let pageCount: Int
    let currentIndex: Int
    
    // Define colors for each step using your hex colors
    let stepColors: [Color] = [
        Color(hex: "#5b9afd"),
        Color(hex: "#81F17E"),
        Color(hex: "#f6c51b"),
        Color(hex: "#998cdb"),
    ]
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(currentIndex == index ? colorForCurrentStep() : Color(.gray).opacity(0.1))
                    .frame(width: currentIndex == index ? 50 : 30, height: 8)
                    .animation(.spring(), value: currentIndex)
            }
        }
    }
    
    private func colorForCurrentStep() -> Color {
        return stepColors[currentIndex % stepColors.count]
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { uiView.effect = effect }
}
