//
//  Login.swift
//  swifty-proteins
//
//  Created by XPI-9 on 2/9/2026.
//

import SwiftUI

struct Login: View {
    @EnvironmentObject var appState: AppState
    
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @FocusState private var focusedField: Field?
    @State private var animateIn: Bool = false
    @State private var isSignUp: Bool = false

    enum Field {
        case username, password, confirmPassword
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                RoundedPolygon.hexagon(cornerRadius: 12)
                    .stroke(AppConfig.shared.theme.subText.opacity(0.3), lineWidth: 1)
                    .frame(width: 132, height: 132)

                Image("methane")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
            }

            Spacer().frame(height: 30)

            VStack(spacing: 7) {
                Text("Welcome back")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(AppConfig.shared.theme.font)
                    .tracking(0.2)
                    .contentTransition(.opacity)

                Text("Sign in to continue")
                    .font(.system(size: 15.5, weight: .medium))
                    .foregroundColor(AppConfig.shared.theme.subText)
                    .contentTransition(.opacity)
            }
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 12)

            Spacer().frame(height: 34)

            card
                .padding(.horizontal, 22)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)

            Spacer().frame(height: 24)

            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundColor(AppConfig.shared.theme.subText)
                Button {
                    isSignUp = true
                } label: {
                    Text("Create Account")
                        .fontWeight(.bold)
                        .foregroundColor(AppConfig.shared.theme.accent)
                }
            }
            .font(.system(size: 14))
            .contentTransition(.opacity)
            .opacity(animateIn ? 1 : 0)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppConfig.shared.theme.background)
        .task {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.05)) {
                animateIn = true
            }
        }
        .fullScreenCover(isPresented: $isSignUp) {
           SignUp(isPresented: $isSignUp)
        }
    }

    private var card: some View {
        VStack(spacing: 16) {
            authField(
                icon: "person.fill",
                placeholder: "Email",
                text: $username,
                isSecure: false,
                field: .username
            )

            authField(
                icon: "lock.fill",
                placeholder: "Password",
                text: $password,
                isSecure: true,
                field: .password
            )

            primaryButton
                .padding(.top, 6)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppConfig.shared.theme.card)
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.gray.opacity(0.2)))
        )
    }

    private func authField(icon: String, placeholder: String, text: Binding<String>, isSecure: Bool, field: Field) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14.5, weight: .semibold))
                .foregroundColor(focusedField == field ? AppConfig.shared.theme.accent : AppConfig.shared.theme.subText)
                .frame(width: 18)

            Group {
                if isSecure && !fieldVisibility(for: field) {
                    SecureField("", text: text, prompt: placeholderText(placeholder))
                } else {
                    TextField("", text: text, prompt: placeholderText(placeholder))
                }
            }
            .font(.system(size: 15.5))
            .foregroundColor(AppConfig.shared.theme.font)
            .focused($focusedField, equals: field)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

            if isSecure {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        toggleVisibility(for: field)
                    }
                } label: {
                    Image(systemName: fieldVisibility(for: field) ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 14.5))
                        .foregroundColor(AppConfig.shared.theme.subText.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppConfig.shared.theme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(focusedField == field ? AppConfig.shared.theme.accent : .gray.opacity(0.1), lineWidth: focusedField == field ? 1.4 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.15), value: focusedField)
    }

    private func fieldVisibility(for field: Field) -> Bool {
        field == .confirmPassword ? isConfirmPasswordVisible : isPasswordVisible
    }

    private func toggleVisibility(for field: Field) {
        if field == .confirmPassword {
            isConfirmPasswordVisible.toggle()
        } else {
            isPasswordVisible.toggle()
        }
    }

    private func placeholderText(_ text: String) -> Text {
        Text(text).foregroundColor(AppConfig.shared.theme.subText)
    }

    private var primaryButton: some View {
        Button {
            appState.switchTo(.dashboard)
        } label: {
            Text("Login")
                .font(.system(size: 16.5, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16.5)
                .background(
                    LinearGradient(
                        colors: [AppConfig.shared.theme.accent, Color(hex: "#33cccc")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        }
        .buttonStyle(PressableButtonStyle())
    }

}

private struct ForgotPasswordSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var code: String = ""
    @State private var step: Step = .email
    @FocusState private var isFieldFocused: Bool

    enum Step {
        case email, code
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if step == .code {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            step = .email
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppConfig.shared.theme.font)
                    }
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppConfig.shared.theme.subText)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            Spacer()

            VStack(spacing: 7) {
                Text(step == .email ? "Reset your password" : "Enter verification code")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppConfig.shared.theme.font)

                Text(step == .email
                     ? "Enter the email linked to your account and we'll send you a reset code."
                     : "We sent a 6-digit code to \(email.isEmpty ? "your email" : email).")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppConfig.shared.theme.subText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
            .padding(.horizontal, 12)

            Spacer().frame(height: 30)

            Group {
                if step == .email {
                    emailField
                } else {
                    codeField
                }
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 20)

            primaryButton
                .padding(.horizontal, 24)

            if step == .code {
                resendRow
                    .padding(.top, 14)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppConfig.shared.theme.background)
        .task {
            isFieldFocused = true
        }
    }

    private var emailField: some View {
        HStack(spacing: 12) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 14.5, weight: .semibold))
                .foregroundColor(AppConfig.shared.theme.subText)
                .frame(width: 18)

            TextField("", text: $email, prompt: Text("Email").foregroundColor(AppConfig.shared.theme.subText))
                .font(.system(size: 15.5))
                .foregroundColor(AppConfig.shared.theme.font)
                .focused($isFieldFocused)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppConfig.shared.theme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isFieldFocused ? AppConfig.shared.theme.accent : .gray.opacity(0.1), lineWidth: isFieldFocused ? 1.4 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isFieldFocused)
    }

    private var codeField: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 14.5, weight: .semibold))
                .foregroundColor(AppConfig.shared.theme.subText)
                .frame(width: 18)

            TextField("", text: $code, prompt: Text("6-digit code").foregroundColor(AppConfig.shared.theme.subText))
                .font(.system(size: 15.5))
                .foregroundColor(AppConfig.shared.theme.font)
                .focused($isFieldFocused)
                .keyboardType(.numberPad)
                .onChange(of: code) { newValue in
                    if newValue.count > 6 {
                        code = String(newValue.prefix(6))
                    }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppConfig.shared.theme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isFieldFocused ? AppConfig.shared.theme.accent : .gray.opacity(0.1), lineWidth: isFieldFocused ? 1.4 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isFieldFocused)
    }

    private var primaryButton: some View {
        Button {
            if step == .email {
                // send reset code to `email`
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    step = .code
                }
            } else {
                // verify `code` for `email`
            }
        } label: {
            Text(step == .email ? "Send Code" : "Verify Code")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15.5)
                .background(
                    LinearGradient(
                        colors: [AppConfig.shared.theme.accent, Color(red: 0.06, green: 0.24, blue: 0.72)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(step == .email ? email.isEmpty : code.count < 6)
        .opacity((step == .email ? email.isEmpty : code.count < 6) ? 0.5 : 1)
    }

    private var resendRow: some View {
        HStack(spacing: 4) {
            Text("Didn't get a code?")
                .foregroundColor(AppConfig.shared.theme.subText)
            Button {
                // resend code
            } label: {
                Text("Resend")
                    .fontWeight(.bold)
                    .foregroundColor(AppConfig.shared.theme.accent)
            }
        }
        .font(.system(size: 13.5))
    }
}

// MARK: - Shapes & Button Styles

private struct RoundedPolygon: Shape {
    var sides: Int
    var cornerRadius: CGFloat
    var rotationDegrees: Double = 0

    func path(in rect: CGRect) -> Path {
        guard sides >= 3 else { return Path() }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let angleIncrement = 2 * CGFloat.pi / CGFloat(sides)
        let rotation = CGFloat(rotationDegrees * .pi / 180)

        var points: [CGPoint] = []
        for i in 0..<sides {
            let angle = angleIncrement * CGFloat(i) - .pi / 2 + rotation
            points.append(CGPoint(x: center.x + radius * cos(angle),
                                   y: center.y + radius * sin(angle)))
        }

        var path = Path()
        for i in 0..<points.count {
            let curr = points[i]
            let next = points[(i + 1) % points.count]
            let prev = points[(i - 1 + points.count) % points.count]

            let toNext = CGVector(dx: next.x - curr.x, dy: next.y - curr.y)
            let toPrev = CGVector(dx: prev.x - curr.x, dy: prev.y - curr.y)
            let lenNext = sqrt(toNext.dx * toNext.dx + toNext.dy * toNext.dy)
            let lenPrev = sqrt(toPrev.dx * toPrev.dx + toPrev.dy * toPrev.dy)
            let cr = min(cornerRadius, min(lenNext, lenPrev) / 2)

            let startPoint = CGPoint(x: curr.x + toPrev.dx / lenPrev * cr,
                                      y: curr.y + toPrev.dy / lenPrev * cr)
            let endPoint = CGPoint(x: curr.x + toNext.dx / lenNext * cr,
                                    y: curr.y + toNext.dy / lenNext * cr)

            if i == 0 {
                path.move(to: startPoint)
            } else {
                path.addLine(to: startPoint)
            }
            path.addQuadCurve(to: endPoint, control: curr)
        }
        path.closeSubpath()
        return path
    }
}

private extension Shape where Self == RoundedPolygon {
    static func hexagon(cornerRadius: CGFloat) -> RoundedPolygon {
        RoundedPolygon(sides: 6, cornerRadius: cornerRadius, rotationDegrees: 30)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
