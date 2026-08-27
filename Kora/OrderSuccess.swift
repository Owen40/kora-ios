//
//  OrderSuccess.swift
//  Kora
//
//  Created by mac on 4/10/26.
//
import SwiftUI

struct OrderSuccessView: View {
    @Environment(\.colorScheme) var scheme
    let orderNumber: String
    let estimatedTime: String
    var onGoHome: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.button(for: scheme).opacity(0.05))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(Theme.button(for: scheme).opacity(0.1))
                    .frame(width:90, height: 90)
                Circle()
                    .fill(Theme.accent(for: scheme))
                    .frame(width: 60, height: 60)
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 40)
            
            Image("kora_delivery")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding(.bottom, 40)
            
            Text("ORDER #\(orderNumber.prefix(8).uppercased())")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.text(for: scheme).opacity(0.6))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Theme.card(for: scheme))
                .cornerRadius(20)
                .padding(.bottom, 24)
            
            Text("Order Placed successfully!")
                .font(.system(size: 14))
                .foregroundColor(Theme.text(for: scheme))
                .padding(.bottom, 12)
            
            Text("Your delicious meal is on its way. Estimated delivery time: \(estimatedTime) mins")
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.text(for: scheme).opacity(0.6))
                .lineSpacing(4)
            
            Spacer()
            
            Button(action: onGoHome) {
                Text("Go to Home")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.button(for: scheme)) // Orange text
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Theme.button(for: scheme).opacity(0.2)) // Light orange background
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background(for: scheme).ignoresSafeArea())
    }
}

