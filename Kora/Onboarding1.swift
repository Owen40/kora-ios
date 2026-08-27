//
//  Untitled.swift
//  Kora
//
//  Created by mac on 4/4/26.
//
import SwiftUI

struct Onboarding1View: View {
    var onNext: () -> Void
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Curb Your Cravings")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Theme.text(for: scheme))
                .padding(.bottom, 8)
            
            Text("Hungry? We've got you. From cheesy Pizza to juicy burgers. Find your favourites in seconds.")
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.text(for: scheme).opacity(0.9))
                .padding(.horizontal, 32)
                .lineSpacing(4)
            Spacer()
            
            PrimaryButton(title: "Bring it on", action: onNext)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

#Preview {
    Onboarding1View(
        onNext: {}
    )
}
