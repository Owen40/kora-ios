import SwiftUI
import CoreLocation
import Combine

struct AddressSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    
    // Inject the ViewModel
    @ObservedObject var viewModel: AddressViewModel
    
    // Change to local state
    @State private var nickname: String = ""
    @State private var street: String = ""
    @State private var city: String = "Nairobi"
    @State private var latitude: Double? = nil
    @State private var longitude: Double? = nil
    
    @StateObject private var locationManager = LocationManager()
    @State private var isLoadingLocation = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Add Delivery Address").font(.headline).foregroundColor(Theme.text(for: scheme))
            
            Button(action: getCurrentLocation) {
                HStack {
                    if isLoadingLocation {
                        ProgressView()
                            .tint(Theme.button(for: scheme))
                    } else {
                        Image(systemName: "location.fill")
                    }
                    Text(isLoadingLocation ? "Getting location..." : "Get Current Coordinates")
                        .fontWeight(.bold)
                }
                .foregroundColor(Theme.button(for: scheme))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Theme.card(for: scheme))
                .cornerRadius(12)
            }
            .disabled(isLoadingLocation)
            
            if let lat = latitude, let lng = longitude {
                Text("Lat: \(lat), Lng: \(lng)")
                    .font(.caption)
                    .foregroundColor(Theme.accent(for: scheme))
            }
            
            GlassTextField(label: "Street Address", placeholder: "e.g., 123 Main St", text: $street)
            GlassTextField(label: "City", placeholder: "e.g., Nairobi", text: $city)
            GlassTextField(label: "Nickname", placeholder: "e.g., Home, Work", text: $nickname)
            
            PrimaryButton(title: viewModel.state == AddressState.loading ? "Saving..." : "Save Address") {
                if street.isEmpty || city.isEmpty { return } // Basic validation
                let safeNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : nickname
                
                // Trigger the API Call
                viewModel.createAddress(
                    nickname: safeNickname,
                    street: street,
                    city: city,
                    longitude: longitude,
                    latitude: latitude,
                    deliveryInstructions: nil
                )
            }
            .disabled(viewModel.state == AddressState.loading)
        }
        .padding(24)
        .presentationDetents([.fraction(0.75)])
        .presentationBackground(Theme.background(for: scheme))
        .alert("Location Error", isPresented: $locationManager.hasError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(locationManager.errorMessage ?? "Unable to get your location")
        }
        // Dismiss automatically when the API call succeeds
        .onReceive(viewModel.$state) { state in
            if case .success = state {
                dismiss()
                viewModel.resetState()
            }
        }
    }
    
    private func getCurrentLocation() {
        isLoadingLocation = true
        locationManager.requestLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let location = locationManager.location {
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                street = "Current location"
            }
            isLoadingLocation = false
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var hasError = false
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            hasError = true
            errorMessage = "Please enable location permissions in Settings"
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        hasError = true
        errorMessage = error.localizedDescription
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

