import SwiftUI

struct AllergenSelectionView: View {
    @Environment(\.colorScheme) var scheme
    var onComplete: () -> Void
    
    @StateObject private var viewModel = AllergenViewModel()
    @State private var selectedAllergens: Set<String> = []
    
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Any food allergies?")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Theme.text(for: scheme))
                .padding(.top, 40)
            
            Text("Select any allergens below so we can tailor your menu.")
                .font(.title3)
                .foregroundColor(Theme.text(for: scheme).opacity(0.6))
            
            if viewModel.allergenState == AllergenState.loading && viewModel.availableAllergens.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.availableAllergens) { allergen in
                            AllergenBubble(
                                title: allergen.name,
                                isSelected: selectedAllergens.contains(allergen.id),
                                scheme: scheme
                            ) {
                                toggleSelection(for: allergen.id)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                PrimaryButton(title: viewModel.allergenState == .loading ? "Saving..." : "Save & Continue") {
                    saveAllergens()
                }
                .disabled(viewModel.allergenState == .loading)
                
                Button("Skip for now") {
                    onComplete()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.text(for: scheme).opacity(0.6))
                .disabled(viewModel.allergenState == .loading)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .onAppear {
            viewModel.fetchAllergens()
        }
        .onReceive(viewModel.$allergenState) { state in
            switch state {
            case .saveSuccess:
                onComplete()
            case .error(let message):
                snackbarMessage = message
                showSnackbar = true
                viewModel.resetState()
            default:
                break
            }
        }
        .snackbar(isPresented: $showSnackbar, message: snackbarMessage)
    }
    
    private func toggleSelection(for id: String) {
        if selectedAllergens.contains(id) {
            selectedAllergens.remove(id)
        } else {
            selectedAllergens.insert(id)
        }
    }
    
    private func saveAllergens() {
        guard !selectedAllergens.isEmpty else {
            onComplete()
            return
        }
        viewModel.saveSelections(allergenIds: Array(selectedAllergens))
    }
}
