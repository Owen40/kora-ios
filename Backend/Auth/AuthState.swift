//
//  AuthState.swift
//  Kora
//
//  Created by mac on 4/6/26.
//
import Foundation

enum AuthState: Equatable {
    case idle
    case loading
    case success(String) // String is the role
    case requiresOtp(String) // String is the email to pass to the OTP screen
    case passwordResetEmailSent
    case error(String)
}
