import FirebaseAuth
//
//  CheckoutScreen.swift
//  Kora
//
//  Created by mac on 4/7/26.
//
import SwiftUI

struct CheckoutView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var cart: CartManager

    var onOrderSuccess: ((String, String) -> Void)?

    @State private var showSnackbar = false
    @State private var snackbarMessage = ""

    @StateObject private var checkoutViewModel = CheckoutViewModel()
    @StateObject private var addressViewModel = AddressViewModel()
    //    @State private var navigateToOrderSuccess = false
    //    @State private var orderNumber = ""

    @State private var selectedPayment: PaymentMethod?
    @State private var savedCards: [SavedCard] = []
    @State private var savedMpesaNumbers: [SavedMpesa] = []
    @State private var showAddressSheet = false
    @State private var showCardSheet = false
    @State private var showMPesaSheet = false
    @State private var addressNickname: String = "Home"
    @State private var addressStreet: String = ""
    @State private var addressCity: String = "Nairobi"

    @State private var latitude: Double?
    @State private var longitude: Double?

    struct SavedCard: Identifiable {
        let id = UUID()
        let lastFour: String
        let cardType: CardType
        let expiry: String

        var displayName: String {
            return "\(cardType.displayName) ending in \(lastFour)"
        }

        var icon: String {
            return cardType.icon
        }
    }

    struct SavedMpesa: Identifiable {
        let id = UUID()
        let phoneNumber: String

        var displayNumber: String {
            let masked = String(phoneNumber.suffix(4))
            let prefix = String(phoneNumber.prefix(3))
            return "+254 \(prefix)***\(masked)"
        }
    }

    enum CardType {
        case visa, mastercard

        var icon: String {
            switch self {
            case .visa: return "creditcard.fill"
            case .mastercard: return "creditcard.fill"
            }
        }

        var displayName: String {
            switch self {
            case .visa: return "Visa"
            case .mastercard: return "Mastercard"
            }
        }
    }

    enum PaymentMethod: Identifiable {
        case card(SavedCard)
        case mpesa(SavedMpesa)
        case cod

        var id: String {
            switch self {
            case .card(let card): return "card_\(card.id)"
            case .mpesa(let mpesa): return "mpesa_\(mpesa.id)"
            case .cod: return "cod"
            }
        }

        var title: String {
            switch self {
            case .card(let card): return card.displayName
            case .mpesa(let mpesa): return mpesa.displayNumber
            case .cod: return "Cash on Delivery"
            }
        }

        var icon: String {
            switch self {
            case .card(let card): return card.icon
            case .mpesa: return "iphone"
            case .cod: return "banknote.fill"
            }
        }
    }

    private var restaurantId: String? {
        cart.items.first?.dish.restaurantId
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // Section 1: Delivery Address
                    DeliveryAddressSection(
                        addressNickname: addressNickname,
                        addressStreet: addressStreet,
                        scheme: scheme,
                        onEdit: { showAddressSheet = true }
                    )

                    // Section 2: Order Summary
                    OrderSummarySection(cart: cart, scheme: scheme)

                    // Section 3: Payment Method
                    PaymentMethodSection(
                        savedCards: savedCards,
                        savedMpesaNumbers: savedMpesaNumbers,
                        selectedPayment: $selectedPayment,
                        onAddCard: { showCardSheet = true },
                        onAddMpesa: { showMPesaSheet = true },
                        scheme: scheme
                    )

                    // Section 4: Bill Breakdown
                    BillBreakdownSection(
                        subtotal: cart.subtotal,
                        deliveryFee: cart.deliveryFee,
                        tax: cart.tax,
                        total: cart.total,
                        scheme: scheme
                    )

                    Spacer().frame(height: 100)
                }
                .padding(24)
            }

            // Place Order Button
            Button(action: {
                print("🟢 PLACE ORDER TAPPED")

                if checkoutViewModel.uiState == .loading {
                    print("❌ Blocked: Checkout is currently loading")
                    return
                }
                if selectedPayment == nil {
                    print("❌ Blocked: No payment method selected")
                    showSnackbar = true
                    snackbarMessage = "Please select a payment method"
                    return
                }
                if addressStreet.isEmpty {
                    print("❌ Blocked: Address is empty")
                    showSnackbar = true
                    snackbarMessage = "Please add a delivery address"
                    return
                }

                print("✅ All checks passed. Submitting order...")
                placeOrder()
            }) {
                HStack {
                    if checkoutViewModel.uiState == .loading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Place Order")
                            .font(.system(size: 16, weight: .bold))
                    }
                    Spacer()
                    Text(String(format: "KES %.2f", cart.total))
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(Theme.background(for: scheme))
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
                .background(Theme.button(for: scheme))
                .cornerRadius(16)
                .shadow(
                    color: Theme.button(for: scheme).opacity(0.3),
                    radius: 10,
                    x: 0,
                    y: 5
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            //                .disabled(checkoutViewModel.uiState == .loading || selectedPayment == nil || addressStreet.isEmpty)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Checkout")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Theme.text(for: scheme))
            }
        }
        .onAppear {
            if let id = restaurantId {
                checkoutViewModel.fetchDeliveryFee(restaurantId: id)
            }
            loadSavedPaymentMethods()
        }
        .onReceive(checkoutViewModel.$deliveryFee) { fee in
            if fee > 0 {
                cart.deliveryFee = fee
                cart.estimatedTime = checkoutViewModel.estimatedTime
            }
        }
        //            .onReceive(checkoutViewModel.$uiState) { state in
        //                switch state {
        //                case .success(let id):
        //                    onOrderSuccess?(id, cart.estimatedTime)
        //                case .error(let message):
        //                    snackbarMessage = message
        //                    showSnackbar = true
        //                    checkoutViewModel.resetState()
        //                default:
        //                    break
        //                }
        //            }
        .onChange(of: checkoutViewModel.uiState) { _, state in
            if case .success(let id) = state {
                print("✅ Navigating to success")
                onOrderSuccess?(id, cart.estimatedTime)
            }
        }
        .snackbar(isPresented: $showSnackbar, message: snackbarMessage)
        .sheet(isPresented: $showAddressSheet) {
            //                AddressSheet(
            //                    nickname: $addressNickname,
            //                    street: $addressStreet, viewModel: <#AddressViewModel#>,
            //                    latitude: $latitude,
            //                    longitude: $longitude
            //                )
            AddressSheet(viewModel: addressViewModel)
        }
        .sheet(isPresented: $showCardSheet) {
            CardSheet { lastFour, sheetCardType, expiry in
                // CHANGED: Map CardSheet.CardType to CheckoutView.CardType to fix the type mismatch
                let mappedCardType: CheckoutView.CardType =
                    sheetCardType == .visa ? .visa : .mastercard

                let newCard = SavedCard(
                    lastFour: lastFour,
                    cardType: mappedCardType,
                    expiry: expiry
                )
                savedCards.append(newCard)
                selectedPayment = .card(newCard)
                savePaymentMethods()
            }
        }
        .sheet(isPresented: $showMPesaSheet) {
            MPesaSheet { phoneNumber in
                let newMpesa = SavedMpesa(phoneNumber: phoneNumber)
                savedMpesaNumbers.append(newMpesa)
                selectedPayment = .mpesa(newMpesa)
                savePaymentMethods()
            }
        }
    }

    private func loadSavedPaymentMethods() {
        // Load from UserDefaults
        if let cardsData = UserDefaults.standard.data(forKey: "savedCards"),
            let cards = try? JSONDecoder().decode(
                [SavedCard].self,
                from: cardsData
            )
        {
            savedCards = cards
        }

        if let mpesaData = UserDefaults.standard.data(
            forKey: "savedMpesaNumbers"
        ),
            let mpesaNumbers = try? JSONDecoder().decode(
                [SavedMpesa].self,
                from: mpesaData
            )
        {
            savedMpesaNumbers = mpesaNumbers
        }

        // Set default selection if available
        if !savedCards.isEmpty {
            selectedPayment = .card(savedCards.first!)
        } else if !savedMpesaNumbers.isEmpty {
            selectedPayment = .mpesa(savedMpesaNumbers.first!)
        } else {
            selectedPayment = .cod
        }
    }

    private func savePaymentMethods() {
        if let cardsData = try? JSONEncoder().encode(savedCards) {
            UserDefaults.standard.set(cardsData, forKey: "savedCards")
        }

        if let mpesaData = try? JSONEncoder().encode(savedMpesaNumbers) {
            UserDefaults.standard.set(mpesaData, forKey: "savedMpesaNumbers")
        }
    }

    private func placeOrder() {
        let userId =
            Auth.auth().currentUser?.uid ?? "7MgllViCyzYXxZewINdx0kDXq723"
        guard let restaurantId = restaurantId else { return }
        guard let paymentMethod = selectedPayment else { return }

        let address = Address(
            id: UUID().uuidString,  // Assigning a temporary local ID
            nickname: addressNickname,
            street: addressStreet,
            city: addressCity,
            longitude: longitude,
            latitude: latitude,
            deliveryInstructions: nil,
            isDefault: false
        )

        checkoutViewModel.submitOrder(
            cartItems: cart.items,
            subtotal: cart.subtotal,
            tax: cart.tax,
            total: cart.total,
            paymentMethod: paymentMethod.title,
            address: address,
            userId: userId,
            restaurantId: restaurantId
        )
    }
}

// MARK: - Reusable UI Elements for Checkout
struct PaymentOptionRow: View {
    var icon: String
    var title: String
    var isSelected: Bool
    var scheme: ColorScheme
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Theme.text(for: scheme))
                    .frame(width: 40, height: 40)
                    .background(Theme.background(for: scheme))
                    .cornerRadius(8)

                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.text(for: scheme))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.button(for: scheme))
                        .font(.system(size: 24))
                } else {
                    Circle()
                        .stroke(
                            Theme.placeholderText(for: scheme).opacity(0.5),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                }
            }
            .padding()
            .background(Theme.card(for: scheme))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Theme.button(for: scheme) : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DeliveryAddressSection: View {
    let addressNickname: String
    let addressStreet: String
    let scheme: ColorScheme
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Delivery Address")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Theme.text(for: scheme))

            Button(action: onEdit) {
                HStack(spacing: 16) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Theme.button(for: scheme))
                        .background(Theme.button(for: scheme).opacity(0.2))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(addressNickname)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.text(for: scheme))
                        Text(
                            addressStreet.isEmpty
                                ? "Add delivery address" : addressStreet
                        )
                        .font(.system(size: 12))
                        .foregroundColor(Theme.placeholderText(for: scheme))
                    }
                    Spacer()
                    Image(systemName: "pencil")
                        .foregroundColor(Theme.button(for: scheme))
                }
                .padding()
                .background(Theme.card(for: scheme))
                .cornerRadius(16)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct OrderSummarySection: View {
    let cart: CartManager
    let scheme: ColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Summary")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Theme.text(for: scheme))

            ForEach(cart.items) { item in
                HStack(spacing: 16) {
                    AsyncImage(url: URL(string: item.dish.imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(
                                    Theme.placeholderText(for: scheme).opacity(
                                        0.2
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .cornerRadius(12)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .cornerRadius(12)
                        case .failure:
                            Rectangle()
                                .fill(
                                    Theme.placeholderText(for: scheme).opacity(
                                        0.2
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .cornerRadius(12)
                                .overlay(Image(systemName: "photo"))
                        @unknown default:
                            EmptyView()
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.dish.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.text(for: scheme))
                        Text("\(item.quantity)x")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.accent(for: scheme))
                    }
                    Spacer()
                    Text(
                        "KES \(Int(item.dish.price.doubleValue * Double(item.quantity)))"
                    )
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Theme.text(for: scheme))
                }
                .padding()
                .background(Theme.card(for: scheme))
                .cornerRadius(16)
            }
        }
    }
}

struct PaymentMethodSection: View {
    let savedCards: [CheckoutView.SavedCard]
    let savedMpesaNumbers: [CheckoutView.SavedMpesa]
    @Binding var selectedPayment: CheckoutView.PaymentMethod?
    let onAddCard: () -> Void
    let onAddMpesa: () -> Void
    let scheme: ColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Method")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Theme.text(for: scheme))

            // Saved Cards
            ForEach(savedCards) { card in
                PaymentOptionRow(
                    icon: card.icon,
                    title: card.displayName,
                    isSelected: selectedPayment?.id == "card_\(card.id)",
                    scheme: scheme,
                    action: { selectedPayment = .card(card) }
                )
            }

            Button(action: onAddCard) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add New Card")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.button(for: scheme))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)

            // Saved M-Pesa Numbers
            ForEach(savedMpesaNumbers) { mpesa in
                PaymentOptionRow(
                    icon: "iphone",
                    title: mpesa.displayNumber,
                    isSelected: selectedPayment?.id == "mpesa_\(mpesa.id)",
                    scheme: scheme,
                    action: { selectedPayment = .mpesa(mpesa) }
                )
            }

            Button(action: onAddMpesa) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add M-Pesa Number")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.button(for: scheme))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)

            // Cash on Delivery
            PaymentOptionRow(
                icon: "banknote.fill",
                title: "Cash on Delivery",
                isSelected: selectedPayment?.id == "cod",
                scheme: scheme,
                action: { selectedPayment = .cod }
            )
        }
    }
}

struct BillBreakdownSection: View {
    let subtotal: Double
    let deliveryFee: Double
    let tax: Double
    let total: Double
    let scheme: ColorScheme

    var body: some View {
        VStack(spacing: 12) {
            BillRow(title: "Subtotal", amount: subtotal, scheme: scheme)
            BillRow(
                title: "Delivery Fee",
                amount: deliveryFee,
                scheme: scheme,
                isHighlight: true
            )
            BillRow(title: "Tax (16%)", amount: tax, scheme: scheme)

            Divider().padding(.vertical, 4)

            HStack {
                Text("Total")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Theme.text(for: scheme))
                Spacer()
                Text(String(format: "KES %.2f", total))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Theme.button(for: scheme))
            }
        }
        .padding()
        .background(Theme.card(for: scheme))
        .cornerRadius(16)
    }
}

struct BillRow: View {
    var title: String
    var amount: Double
    var scheme: ColorScheme
    var isHighlight: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(Theme.placeholderText(for: scheme))
            Spacer()
            Text(String(format: "Ksh %.2f", amount))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(
                    isHighlight
                        ? Theme.accent(for: scheme) : Theme.text(for: scheme)
                )
        }
    }
}

struct CardSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    @State private var cardNum = ""
    @State private var expiry = ""
    @State private var cvv = ""
    @State private var cardType: CardType = .unknown
    let onSave: (String, CardType, String) -> Void

    enum CardType {
        case visa, mastercard, unknown

        var icon: String {
            switch self {
            case .visa: return "visa"
            case .mastercard: return "mastercard"
            case .unknown: return "creditcard"
            }
        }

        var displayName: String {
            switch self {
            case .visa: return "Visa"
            case .mastercard: return "Mastercard"
            case .unknown: return "Card"
            }
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Add New Card").font(.headline).foregroundColor(
                Theme.text(for: scheme)
            )

            VStack(alignment: .trailing, spacing: 8) {
                GlassTextField(
                    label: "Card Number",
                    placeholder: "XXXX XXXX XXXX XXXX",
                    text: $cardNum
                )
                .onChange(of: cardNum) { _, newValue in
                    cardNum = formatCardNumber(newValue)
                    detectCardType()
                }

                if cardType != .unknown {
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: cardType.icon)
                                .font(.caption)
                            Text(cardType.displayName)
                                .font(.caption)
                                .foregroundColor(
                                    Theme.text(for: scheme).opacity(0.7)
                                )
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Theme.card(for: scheme))
                        .cornerRadius(8)
                    }
                    .padding(.trailing, 4)
                }
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Expiry Date")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.text(for: scheme))

                    TextField("MM/YY", text: $expiry)
                        .keyboardType(.numberPad)
                        .foregroundColor(Theme.text(for: scheme))
                        .onChange(of: expiry) { _, newValue in
                            expiry = formatExpiryDate(newValue)
                        }
                        .padding()
                        .background(
                            ZStack {
                                Theme.card(for: scheme).opacity(0.6)
                                Rectangle().fill(.ultraThinMaterial)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        )
                }

                GlassTextField(label: "CVV", placeholder: "123", text: $cvv)
                    .onChange(of: cvv) { _, newValue in
                        if newValue.count > 3 {
                            cvv = String(newValue.prefix(3))
                        }
                    }
            }

            PrimaryButton(
                title: "Save Card",
                action: {
                    let cleaned = cardNum.replacingOccurrences(
                        of: " ",
                        with: ""
                    )
                    let lastFour = String(cleaned.suffix(4))
                    let cardType: CardType =
                        cleaned.hasPrefix("4") ? .visa : .mastercard
                    onSave(lastFour, cardType, expiry)
                    dismiss()
                }
            )
            .disabled(cardNum.count < 19 || expiry.count < 5 || cvv.count < 3)
        }
        .padding(24)
        .presentationDetents([.fraction(0.55)])
        .presentationBackground(Theme.background(for: scheme))
    }
    private func formatCardNumber(_ number: String) -> String {
        let cleaned = number.replacingOccurrences(of: " ", with: "")
        var formatted = ""
        for (index, char) in cleaned.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted.append(" ")
            }
            formatted.append(char)
        }
        // Limit to 19 characters (16 digits + 3 spaces)
        return String(formatted.prefix(19))
    }

    private func detectCardType() {
        let cleaned = cardNum.replacingOccurrences(of: " ", with: "")

        if cleaned.hasPrefix("4") {
            cardType = .visa
        } else if cleaned.hasPrefix("5")
            && (1...5).contains(Int(cleaned.prefix(2)) ?? 0)
        {
            cardType = .mastercard
        } else {
            cardType = .unknown
        }
    }

    private func formatExpiryDate(_ date: String) -> String {
        let cleaned = date.replacingOccurrences(of: "/", with: "")
        var formatted = ""

        for (index, char) in cleaned.enumerated() {
            if index == 2 {
                formatted.append("/")
            }
            formatted.append(char)

            // Validate month
            if index == 1 {
                let month = Int(String(cleaned.prefix(2))) ?? 0
                if month > 12 {
                    // Reset if month > 12
                    return ""
                }
            }
        }

        // Limit to 5 characters (MM/YY)
        return String(formatted.prefix(5))
    }
}

struct MPesaSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    @State private var phone = ""
    let onSave: (String) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Add M-Pesa Number").font(.headline).foregroundColor(
                Theme.text(for: scheme)
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.text(for: scheme))

                HStack {
                    Text("+254")
                        .fontWeight(.bold)
                        .foregroundColor(Theme.text(for: scheme))
                    TextField("712345678", text: $phone)
                        .keyboardType(.numberPad)
                        .foregroundColor(Theme.text(for: scheme))
                        .onChange(of: phone) { _, newValue in
                            if newValue.count > 9 {
                                phone = String(newValue.prefix(9))
                            }
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
                    RoundedRectangle(cornerRadius: 12).stroke(
                        Theme.text(for: scheme).opacity(0.15),
                        lineWidth: 1
                    )
                )
            }

            PrimaryButton(
                title: "Save Number",
                action: {
                    if phone.count >= 9 {
                        onSave(phone)
                        dismiss()
                    }
                }
            )
            .disabled(phone.count < 9)
        }
        .padding(24)
        .presentationDetents([.fraction(0.4)])
        .presentationBackground(Theme.background(for: scheme))
    }
}

// MARK: - Codable Extensions for Saved Payment Methods
extension CheckoutView.SavedCard: Codable {
    enum CodingKeys: String, CodingKey {
        case lastFour
        case cardType
        case expiry
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lastFour, forKey: .lastFour)
        try container.encode(cardType.displayName, forKey: .cardType)
        try container.encode(expiry, forKey: .expiry)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lastFour = try container.decode(String.self, forKey: .lastFour)
        let cardTypeName = try container.decode(String.self, forKey: .cardType)
        cardType = cardTypeName == "Visa" ? .visa : .mastercard
        expiry = try container.decode(String.self, forKey: .expiry)
    }
}

extension CheckoutView.SavedMpesa: Codable {
    enum CodingKeys: String, CodingKey {
        case phoneNumber
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(phoneNumber, forKey: .phoneNumber)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
    }
}

#Preview {
    CheckoutView()
}
