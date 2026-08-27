//
//  SnackbarModifier.swift
//  Kora
//
//  Created by mac on 4/6/26.
//
import SwiftUI

struct SnackbarModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let duration: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                VStack {
                    Spacer()
                    Text(message)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(1)
                }
                .animation(.easeInOut(duration: 0.3), value: isPresented)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func snackbar(isPresented: Binding<Bool>, message: String, duration: Double = 2.0) -> some View {
        modifier(SnackbarModifier(isPresented: isPresented, message: message, duration: duration))
    }
}
