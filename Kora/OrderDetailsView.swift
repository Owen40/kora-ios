//
//  OrderDetailsView.swift
//  Kora
//
//  Created by mac on 4/10/26.
//
import SwiftUI

struct OrderDetailsView: View {
    @Environment(\.colorScheme) var scheme
    let state: UserOrderUiState
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Theme.button(for: scheme).opacity(0.15))
                            .frame(width: 60, height: 60)
                        Image(systemName: "checkmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Theme.button(for: scheme))
                    }
                    .padding(.top, 20)
                    
                    Text("Order #\(state.order.id ?? "0000")")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Theme.text(for: scheme))
                    
                    Text(state.formattedDate)
                        .font(.system(size: 14))
                        .foregroundColor(Theme.placeholderText(for: scheme))
                    
                    Text(state.statusText.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Theme.background(for: scheme))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Theme.text(for: scheme))
                        .cornerRadius(20)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .background(Theme.card(for: scheme))
                .cornerRadius(20)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Items Ordered")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Theme.text(for: scheme))
                    
                    ForEach(state.order.items, id: \.dishId) { item in
                        HStack(spacing: 16) {
                            // Food Image (Fallback to placeholder if no URL in model)
                            Rectangle()
                                .fill(Theme.placeholderText(for: scheme).opacity(0.2))
                                .frame(width: 60, height: 60)
                                .cornerRadius(12)
                                .overlay(Image(systemName: "photo").foregroundColor(.gray))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.text(for: scheme))
                                Text("Standard") // Placeholder for variation
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.placeholderText(for: scheme))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(String(format: "$%.2f", item.price))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.text(for: scheme))
                                
                                Text("\(item.quantity)x")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Theme.button(for: scheme))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Theme.button(for: scheme).opacity(0.15))
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Theme.card(for: scheme))
                        .cornerRadius(16)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Delivery Details")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Theme.text(for: scheme))
                    
                    VStack(spacing: 0) {
                        HStack(alignment: .top, spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Theme.placeholderText(for: scheme).opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(Theme.text(for: scheme))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("ADDRESS")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Theme.placeholderText(for: scheme))
                                Text(state.order.deliveryAddress.street)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.text(for: scheme))
                                Text(state.order.deliveryAddress.city)
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.placeholderText(for: scheme))
                            }
                            Spacer()
                        }
                        .padding()
                        
                        // Dotted Line Divider
                        Line()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundColor(Theme.placeholderText(for: scheme).opacity(0.3))
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                        
                        HStack(alignment: .top, spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Theme.placeholderText(for: scheme).opacity(0.2))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "box.truck.fill")
                                    .foregroundColor(Theme.text(for: scheme))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("METHOD")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Theme.placeholderText(for: scheme))
                                Text("Standard Delivery")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.text(for: scheme))
                                Text("Leave at door")
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.placeholderText(for: scheme))
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .background(Theme.card(for: scheme))
                    .cornerRadius(16)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("Financial Summary")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Theme.text(for: scheme))
                    
                    VStack(spacing: 16) {
                        BillRow(title: "Subtotal", amount: state.order.subtotal, scheme: scheme)
                        BillRow(title: "Delivery Fee", amount: state.order.deliveryFee, scheme: scheme)
                        BillRow(title: "Tax", amount: state.order.tax, scheme: scheme)
                        
                        Line()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundColor(Theme.placeholderText(for: scheme).opacity(0.3))
                            .frame(height: 1)
                        
                        HStack {
                            Text("Total Paid")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Theme.text(for: scheme))
                            Spacer()
                            Text(String(format: "KES %.2f", state.order.total))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Theme.button(for: scheme))
                        }
                        
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Text("Reorder")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Theme.button(for: scheme))
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {}) {
                                Text("Get Help")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.text(for: scheme))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Theme.placeholderText(for: scheme).opacity(0.5), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Theme.card(for: scheme))
                    .cornerRadius(16)
                }
            }
            .padding(24)
        }
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
