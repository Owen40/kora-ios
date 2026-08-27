//
//  SignUp.swift
//  Kora
//
//  Created by mac on 4/4/26.
//
import SwiftUI

struct SignUpView: View {
    var onSignIn: () -> Void
    var onSignUp: () -> Void
    
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var isChecked = false
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Let's Get Started")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Theme.text(for: scheme))
                    Text("Your next meal is a few taps away. Sign up now")
                        .font(.title3)
                        .foregroundColor(Theme.text(for: scheme).opacity(0.6))
                }
                .padding(.top, 40)
                .padding(.bottom, 10)
                
                HStack {
                    GlassTextField(label: "First Name", placeholder: "e.g John", text: $firstName)
                    GlassTextField(label: "Last Name", placeholder: "e.g Caroline", text: $lastName)
                }
                GlassTextField(label: "Email", placeholder: "Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                
                GlassTextField(label: "Phone", placeholder: "How should we reach you?", text: $phone)
                    .keyboardType(.phonePad)
                GlassSecureField(label: "Password", placeholder: "Enter Your password", text: $password)
                
                CheckboxField(label: "I agree to the terms of Service and Privacy Policy", isChecked: $isChecked)
                    .padding(.vertical, 8)
                
                PrimaryButton(title: "Sign Me Up") {
                    if firstName.isEmpty || lastName.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty {
                        snackbarMessage = "Please fill in all the fields"
                        showSnackbar = true
                    } else if !isChecked {
                        snackbarMessage = "Please agree to the terms and conditions"
                        showSnackbar = true
                    } else if !isValidEmail(email) {
                        snackbarMessage = "Please enter a valid email address"
                        showSnackbar = true
                    } else if password.count < 6 {
                        snackbarMessage = "Password must be at least 6 characters"
                        showSnackbar = true
                    } else {
                        authViewModel.signUp(firstName: firstName, lastName: lastName, email: email, phone: phone, password: password)
                    }
                }
                    .padding(.top, 10)
                
                HStack {
                    Spacer()
                    Text("Already a member?")
                        .foregroundColor(Theme.text(for: scheme))
                    Button("Sign In", action: onSignIn)
                        .bold()
                        .foregroundColor(Theme.accent(for: scheme))
                    Spacer()
                }
                .padding(.top, 16)
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .navigationBarHidden(true)
        .onReceive(authViewModel.$authState) { state in
            switch state {
            case .success:
                snackbarMessage = "Account created successfully!"
                showSnackbar = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onSignUp()
                }
            case .error(let message):
                snackbarMessage = message
                showSnackbar = true
                authViewModel.resetState()
            default:
                break
            }
        }
        .snackbar(isPresented: $showSnackbar, message: snackbarMessage)
    }
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    SignUpView(
        onSignIn: {}, onSignUp: {}
    )
}
