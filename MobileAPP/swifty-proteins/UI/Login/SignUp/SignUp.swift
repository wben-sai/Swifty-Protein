//
//  SignUp.swift
//  swifty-proteins
//
//  Created by XPI-9 on 17/9/2026.
//

import SwiftUI

struct SignUp: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var animateIn: Bool = false
    @FocusState private var focusedField: Field?

    enum Field {
        case firstName, lastName, email, password
    }

    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") && email.contains(".") &&
        password.count >= 6
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppConfig.shared.theme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 50)

                    Image("methane")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70)

                    Spacer().frame(height: 24)

                    VStack(spacing: 7) {
                        Text("Create account")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(AppConfig.shared.theme.font)
                            .tracking(0.2)

                        Text("Sign up to get started")
                            .font(.system(size: 15.5, weight: .medium))
                            .foregroundColor(AppConfig.shared.theme.subText)
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 12)

                    Spacer().frame(height: 30)

                    card
                        .padding(.horizontal, 22)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)

                    Spacer().frame(height: 24)

                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .foregroundColor(AppConfig.shared.theme.subText)
                        Button {
                            isPresented = false
                        } label: {
                            Text("Sign In")
                                .fontWeight(.bold)
                                .foregroundColor(AppConfig.shared.theme.accent)
                        }
                    }
                    .font(.system(size: 14))
                    .opacity(animateIn ? 1 : 0)

                    Spacer().frame(height: 40)
                }
            }
            .scrollDismissesKeyboard(.interactively)

            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppConfig.shared.theme.subText)
                    .padding(20)
            }
        }
        .task {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.05)) {
                animateIn = true
            }
        }
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                authField(icon: "person.fill", placeholder: "First name", text: $firstName,
                          isSecure: false, field: .firstName)
                    .textContentType(.givenName)
                authField(icon: nil, placeholder: "Last name", text: $lastName,
                          isSecure: false, field: .lastName)
                    .textContentType(.familyName)
            }

            authField(icon: "envelope.fill", placeholder: "Email", text: $email,
                      isSecure: false, field: .email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)

            authField(icon: "lock.fill", placeholder: "Password", text: $password,
                      isSecure: true, field: .password)
                .textContentType(.newPassword)

            Text("Password must be at least 6 characters")
                .font(.system(size: 12.5))
                .foregroundColor(AppConfig.shared.theme.subText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, -6)

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

    private func authField(icon: String?, placeholder: String, text: Binding<String>, isSecure: Bool, field: Field) -> some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 14.5, weight: .semibold))
                    .foregroundColor(focusedField == field ? AppConfig.shared.theme.accent : AppConfig.shared.theme.subText)
                    .frame(width: 18)
            }

            Group {
                if isSecure && !isPasswordVisible {
                    SecureField("", text: text, prompt: placeholderText(placeholder))
                } else {
                    TextField("", text: text, prompt: placeholderText(placeholder))
                }
            }
            .font(.system(size: 15.5))
            .foregroundColor(AppConfig.shared.theme.font)
            .focused($focusedField, equals: field)
            .autocorrectionDisabled()
            .textInputAutocapitalization(field == .firstName || field == .lastName ? .words : .never)
            .submitLabel(field == .password ? .done : .next)
            .onSubmit { advanceFocus(from: field) }

            if isSecure {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isPasswordVisible.toggle()
                    }
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
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
                        .stroke(focusedField == field ? AppConfig.shared.theme.accent : .gray.opacity(0.1),
                                lineWidth: focusedField == field ? 1.4 : 1)
                )
        )
        .animation(.easeInOut(duration: 0.15), value: focusedField)
    }

    private func advanceFocus(from field: Field) {
        switch field {
        case .firstName: focusedField = .lastName
        case .lastName:  focusedField = .email
        case .email:     focusedField = .password
        case .password:  focusedField = nil
        }
    }

    private func placeholderText(_ text: String) -> Text {
        Text(text).foregroundColor(AppConfig.shared.theme.subText)
    }

    private var primaryButton: some View {
        Button {
            focusedField = nil
            // TODO: call your register API / auth service with
            // firstName, lastName, email, password
            appState.switchTo(.dashboard)
        } label: {
            Text("Create Account")
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
        .disabled(!isFormValid)
        .opacity(isFormValid ? 1 : 0.5)
    }
}
