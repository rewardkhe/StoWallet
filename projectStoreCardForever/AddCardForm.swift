import SwiftUI

struct AddCardForm: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var cards: [Card]
    let saveCards: () -> Void
    let editingCard: Card?
    
    @State private var storeName = ""
    @State private var cardNumber: String? = nil
    @State private var selectedFormat = "code128"
    @State private var showingScanner = false
    @State private var showAlert = false

    let barcodeFormats = ["code128", "qr", "ean13"]

    init(cards: Binding<[Card]>, saveCards: @escaping () -> Void, editingCard: Card? = nil) {
            self._cards = cards
            self.saveCards = saveCards
            self.editingCard = editingCard

            // Pre-fill fields if editing, else empty/default
            _storeName = State(initialValue: editingCard?.storeName ?? "")
            _cardNumber = State(initialValue: editingCard?.cardNumber ?? "")
            _selectedFormat = State(initialValue: editingCard?.barcodeType ?? "code128")
        }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Store Name", text: $storeName)
                TextField("Card Number", text: Binding(
                    get: { cardNumber ?? "" },
                    set: { cardNumber = $0 }
                ))

                Picker("Barcode Format", selection: $selectedFormat) {
                    ForEach(barcodeFormats, id: \.self) { format in
                        Text(format.uppercased())
                    }
                }

                Button("Scan Barcode") {
                    showingScanner = true
                }
            }
            .navigationTitle(editingCard == nil ? "Add Card" : "Edit Card")

            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let finalNumber = cardNumber, !finalNumber.isEmpty, !storeName.isEmpty {
                            let newCard = Card(
                                id: editingCard?.id ?? UUID(),
                                storeName: storeName,
                                cardNumber: finalNumber,
                                notes: nil,
                                barcodeType: selectedFormat
                            )

                            if let index = cards.firstIndex(where: { $0.id == editingCard?.id }) {
                                cards[index] = newCard    // Editing
                            } else {
                                cards.append(newCard)     // Adding
                            }

                            saveCards()
                            dismiss()
                        }

                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView(scannedCode: $cardNumber)
            }
            .alert("Barcode Missing", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please scan or enter a valid card number before saving.")
            }

        }
    }
}
