//
//  Components.swift
//  Kora
//
//  Created by mac on 4/4/26.
//
import SwiftUI

// MARK: - Primary App Button
struct PrimaryButton: View {
    var title: String
    var icon: String? = nil
    var action: () -> Void
    @Environment(\.colorScheme) var scheme

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                if let icon = icon {
                    Image(systemName: icon)
                        .fontWeight(.bold)
                }
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(Theme.background(for: scheme)) // Uses dynamic text color ensuring contrast
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Theme.button(for: scheme))
            .cornerRadius(16)
            .shadow(color: Theme.button(for: scheme).opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - Liquid Glass Text Field
struct GlassTextField: View {
    var label: String
    var placeholder: String
    @Binding var text: String
    @Environment(\.colorScheme) var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Theme.text(for: scheme))
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Theme.placeholderText(for: scheme)))
                .padding()
                .background(
                    ZStack {
                        Theme.card(for: scheme).opacity(0.6)
                        Rectangle().fill(.ultraThinMaterial)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.text(for: scheme).opacity(0.15), lineWidth: 1)
                )
                .foregroundColor(Theme.text(for: scheme))
        }
    }
}

// MARK: - Liquid Glass Secure Field
struct GlassSecureField: View {
    var label: String
    var placeholder: String
    @Binding var text: String
    @State private var isVisible: Bool = false
    @Environment(\.colorScheme) var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Theme.text(for: scheme))
            
            HStack {
                Group {
                    if isVisible {
                        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Theme.placeholderText(for: scheme)))
                    } else {
                        SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(Theme.placeholderText(for: scheme)))
                    }
                }
                
                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Theme.text(for: scheme).opacity(0.8))
                }
            }
            .padding()
            .background(
                ZStack {
                    Theme.card(for: scheme).opacity(0.6)
                    Rectangle().fill(.ultraThinMaterial)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.text(for: scheme).opacity(0.15), lineWidth: 1)
            )
            .foregroundColor(Theme.text(for: scheme))
        }
    }
}

// MARK: - Custom Checkbox
struct CheckboxField: View {
    var label: String
    @Binding var isChecked: Bool
    @Environment(\.colorScheme) var scheme

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: { isChecked.toggle() }) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundColor(Theme.text(for: scheme))
            }
            
            Text(label)
                .font(.footnote)
                .foregroundColor(Theme.text(for: scheme))
        }
    }
}

//MARK: - Profile Row
struct ProfileRow: View {
    var icon: String
    var title: String
    var subtitle: String
    var scheme: ColorScheme
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Theme.text(for: scheme))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.text(for: scheme))
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.text(for: scheme).opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.text(for: scheme).opacity(0.3))
        }
    }
}

//MARK: -  Restaurant Card
struct RestaurantCard: View {
    let restaurant: Restaurant
    let scheme: ColorScheme
    let isFavourite: Bool
    let onFavouriteToggle: () -> Void
    
    private var isOpen: Bool {
        restaurant.isRestaurantOpen()
    }
    
    private var timeStatusText: String {
        restaurant.getTimeStatusText()
    }
    
    private var timeStatusIcon: String {
        restaurant.getTimeStatusIcon()
    }
    
    private var timeStatusColor: Color {
        restaurant.getTimeStatusColor(for: scheme)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                // Restaurant Image
                ZStack {
                    AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(Theme.placeholderText(for: scheme).opacity(0.3))
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    if !isOpen {
                        Rectangle()
                            .fill(Color.black.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                Text("CLOSED")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(8)
                            )
                    }
                }
                
                // Favourite Button
                Button(action: onFavouriteToggle) {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(isFavourite ? .red : .white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(12)
                .disabled(!isOpen)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(restaurant.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Theme.text(for: scheme))
                
                Text(restaurant.cuisine ?? "")
                    .font(.subheadline)
                    .foregroundColor(Theme.text(for: scheme).opacity(0.7))
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "bicycle")
                            .font(.caption)
                        Text("\(restaurant.estTime) min")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "kenyan.shilling.sign")
                            .font(.caption)
                        Text("Kes \(restaurant.deliveryFee)")
                            .font(.caption)
                    }
                }
                .foregroundColor(Theme.text(for: scheme).opacity(0.6))
                
                HStack(spacing: 4) {
                    Image(systemName: timeStatusIcon)
                        .font(.caption)
                    Text(timeStatusText)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(timeStatusColor)
                .padding(.top, 4)
            }
            .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

// MARK: - Menu Item Card Component
struct MenuItemCard: View {
    let dish: Dish
    let scheme: ColorScheme
    let onAddToCart: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Dish Image
            AsyncImage(url: URL(string: dish.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            
            // Dish Details
            VStack(alignment: .leading, spacing: 6) {
                Text(dish.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.text(for: scheme))
                
                Text(dish.description.isEmpty ? "No description available" : dish.description)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.text(for: scheme).opacity(0.7))
                    .lineLimit(2)
                
                if !dish.allergens.isEmpty && dish.allergens.first != "" {
                    VStack(alignment: .leading, spacing: 6) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(dish.allergens, id: \.self) { allergen in
                                    ChipView(
                                        text: allergen,
                                        icon: "exclamationmark.triangle.fill",
                                        color: .orange,
                                        scheme: scheme
                                    )
                                }
                            }
                        }
                    }
                    .padding(.top, 2)
                }
                
                HStack {
                    Text("Kes \(dish.price)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.accent(for: scheme))
                    
                    Spacer()
                    
                    if !dish.isAvailable {
                        Text("Unavailable")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.red)
                    } else {
                        Button(action: onAddToCart) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Theme.button(for: scheme))
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Theme.card(for: scheme))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .opacity(dish.isAvailable ? 1.0 : 0.6)
    }
}

// MARK: - Restaurant Header View
struct RestaurantHeaderView: View {
    let restaurant: Restaurant
    let scheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover Image
            AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(restaurant.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.text(for: scheme))
                
                Text(restaurant.cuisine ?? "")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.text(for: scheme).opacity(0.7))
                
                HStack(spacing: 16) {
                    Label("\(restaurant.estTime) min", systemImage: "clock")
                    Label("Kes \(restaurant.deliveryFee) delivery", systemImage: "bicycle")
                    Label("Closes at \(restaurant.closingTime)", systemImage: "clock.fill")
                }
                .font(.system(size: 14))
                .foregroundColor(Theme.text(for: scheme).opacity(0.6))
            }
            .padding(20)
            .background(Theme.background(for: scheme))
        }
        .background(Theme.background(for: scheme))
    }
}

struct ChipView: View {
    let text: String
    let icon: String
    let color: Color
    let scheme: ColorScheme
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }
}

// MARK: - Cart Item Row
struct CartItemRow: View {
    let item: CartItem
    let scheme: ColorScheme
    let onRemove: () -> Void
    @EnvironmentObject var cart: CartManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if let imageUrl = URL(string: item.dish.imageUrl), !item.dish.imageUrl.isEmpty {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Theme.placeholderText(for: scheme).opacity(0.2))
                            .frame(width: 80, height: 80)
                            .cornerRadius(12)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .cornerRadius(12)
                    case .failure:
                        Rectangle()
                            .fill(Theme.placeholderText(for: scheme).opacity(0.2))
                            .frame(width: 80, height: 80)
                            .cornerRadius(12)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(Theme.placeholderText(for: scheme))
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Rectangle()
                    .fill(Theme.placeholderText(for: scheme).opacity(0.2))
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(Theme.placeholderText(for: scheme))
                    )
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(item.dish.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.text(for: scheme))
                    Spacer()
                    Text("Ksh \(Int(item.dish.price.doubleValue))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.text(for: scheme))
                }
                Text(item.dish.description.isEmpty ? "No description" : item.dish.description)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.placeholderText(for: scheme))
                    .lineLimit(1)
                
                HStack {
                    // Stepper Component
                    HStack(spacing: 0) {
                        Button(action: { withAnimation {
                            if let dishId = item.dish.id {
                                cart.decrementQuantity(dishId: dishId)
                            }
                        }}) {
                            Image(systemName: "minus")
                                .frame(width: 32, height: 32)
                                .foregroundColor(item.quantity == 1 ? Theme.placeholderText(for: scheme).opacity(0.5) : Theme.text(for: scheme))
                        }
                        .disabled(item.quantity == 1)
                        
                        Text("\(item.quantity)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Theme.text(for: scheme))
                            .frame(width: 30)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            withAnimation {
                                if let dishId = item.dish.id {
                                    cart.incrementQuantity(dishId: dishId)
                                }
                            }
                        }) {
                            Image(systemName: "plus")
                                .frame(width: 32, height: 32)
                                .foregroundColor(.white)
                                .background(Theme.accent(for: scheme))
                                .cornerRadius(8)
                        }
                    }
                    .background(Theme.placeholderText(for: scheme).opacity(0.15))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    // Trash Icon
                    Button(action: {
                        withAnimation {
                            if let dishId = item.dish.id {
                                cart.removeFromCart(dishId: dishId)
                            }
                        }
                    }) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.red)
                    }
                    }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Theme.card(for: scheme))
        .cornerRadius(16)
    }
}

struct AllergenBubble: View {
    var title: String
    var isSelected: Bool
    var scheme: ColorScheme
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(isSelected ? Theme.accent(for: scheme) : Theme.button(for: scheme).opacity(0.1))
                .foregroundColor(isSelected ? .white : Theme.text(for: scheme))
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(isSelected ? Theme.accent(for: scheme) : Color.clear, lineWidth: 2)
                )
        }
    }
}

// MARK: - View Extension for Flexible Width
extension View {
    func flexibleWidth() -> some View {
        self
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
