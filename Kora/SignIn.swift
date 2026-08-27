//
//  SignIn.swift
//  Kora
//
//  Created by mac on 4/4/26.
//
import SwiftUI

struct SignInView: View {
    var onSignUp: () -> Void
    var onSignIn: () -> Void

    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    @State private var showOTPView = false
    @State private var otpEmail = ""
    @Environment(\.colorScheme) var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Welcome Back")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Theme.text(for: scheme))
                Text("Sign In to continue Feasting")
                    .font(.title3)
                    .foregroundColor(Theme.text(for: scheme).opacity(0.5))
            }
            .padding(.top, 40)
            .padding(.bottom, 20)

            GlassTextField(
                label: "Email",
                placeholder: "Enter your email",
                text: $email
            )
            GlassSecureField(
                label: "Password",
                placeholder: "Enter Your Password",
                text: $password
            )

            HStack {
                Spacer()
                Button("Forgot Password") {
                    if !email.isEmpty {
                        authViewModel.resetPassword(email: email)
                    } else {
                        snackbarMessage = "Please enter your email address"
                        showSnackbar = true
                    }
                }
                .font(.subheadline)
                .bold()
                .foregroundColor(Theme.accent(for: scheme))
            }

            PrimaryButton(title: "Sign In") {
                if email.isEmpty || password.isEmpty {
                    snackbarMessage = "Please fill in all the fields"
                    showSnackbar = true
                } else {
                    authViewModel.signIn(email: email, password: password)
                }
            }
            .padding(.top, 20)

            HStack {
                Spacer()
                Text("Don't have an account?")
                    .foregroundColor(Theme.text(for: scheme))
                Button("Sign Up", action: onSignUp)
                    .bold()
                    .foregroundColor(Theme.accent(for: scheme))
                Spacer()
            }
            .padding(.top, 16)

            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .navigationBarHidden(true)
        .onReceive(authViewModel.$authState) { state in
            switch state {
            case .success(let role):
                snackbarMessage = "Signed in Successfully! Role: \(role)"
                showSnackbar = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    onSignIn()
                }
            case .requiresOtp(let email):
                otpEmail = email
                showOTPView = true
                authViewModel.resetState()  // Reset so it doesn't loop
            case .error(let message):
                snackbarMessage = message
                showSnackbar = true
                authViewModel.resetState()
            case .passwordResetEmailSent:
                snackbarMessage = "Password reset email sent! Check your inbox."
                showSnackbar = true
                authViewModel.resetState()
            default:
                break
            }
        }
        // Attach this modifier to the outer VStack or main view
        .fullScreenCover(isPresented: $showOTPView) {
            OTPView(
                email: otpEmail,
                onVerify: {
                    showOTPView = false
                    onSignIn()
                },
                onBack: {
                    showOTPView = false
                }
            )
        }
        .snackbar(isPresented: $showSnackbar, message: snackbarMessage)
    }
}

#Preview {
    SignInView(
        onSignUp: {},
        onSignIn: {}
    )
}
