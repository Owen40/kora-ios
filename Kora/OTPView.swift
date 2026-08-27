//
//  OTPView.swift
//  Kora
//
//  Created by mac on 8/13/26.
//
import SwiftUI
import Combine

struct OTPView: View {
    var email: String
    var onVerify: () -> Void
    var onBack: () -> Void
    
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var otpCode = ""
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(Theme.text(for: scheme))
            }
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Verify Your Account")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Theme.text(for: scheme))
                Text("We've sent a 6-digit OTP to \(email)")
                    .font(.title3)
                    .foregroundColor(Theme.text(for: scheme).opacity(0.6))
            }
            .padding(.vertical, 20)
            
            GlassTextField(label: "OTP Code", placeholder: "Enter 6-digit code", text: $otpCode)
                .keyboardType(.numberPad)
            
            PrimaryButton(title: "Verify") {
                if otpCode.isEmpty {
                    snackbarMessage = "Please enter the OTP"
                    showSnackbar = true
                } else {
                    authViewModel.verifyOtp(email: email, otpCode: otpCode)
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .navigationBarHidden(true)
        .onReceive(authViewModel.$authState) { state in
            switch state {
            case .success:
                snackbarMessage = "Verified Successfully!"
                showSnackbar = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onVerify()
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
}
