//
//  Onboarding2.swift
//  Kora
//
//  Created by mac on 4/4/26.
//
import SwiftUI

struct Onboarding2View: View {
    var onNext: () -> Void
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Let's Eat")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Theme.text(for: scheme))
                .padding(.bottom, 8)
            
            Text("Thousands of restaurants are waiting for you. Don't wait - dig in!")
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.text(for: scheme).opacity(0.7))
                .padding(.horizontal, 32)
                .lineSpacing(4)
            Spacer()
            
            PrimaryButton(title: "Let's Goooooooooo!!!!!", icon: "arrow.right", action: onNext)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

#Preview {
    Onboarding2View(
        onNext: {}
    )
}
