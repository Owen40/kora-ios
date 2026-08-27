//
//  Untitled.swift
//  Kora
//
//  Created by mac on 4/5/26.
//
import SwiftUI

struct FavouritesView: View {
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.button(for: scheme))
                    .frame(width: 130, height: 130)
                Image(systemName: "heart")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(Theme.background(for: scheme))
            }
            
            VStack(spacing: 12) {
                Text("No Love Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.text(for: scheme))
                
                Text("Tap the heart icon on any restaurant to save it here for later.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.text(for: scheme).opacity(0.5))
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background(for: scheme).ignoresSafeArea())
    }
}

#Preview {
    FavouritesView()
}
