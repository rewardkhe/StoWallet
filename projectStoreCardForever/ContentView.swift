import SwiftUI

struct ContentView: View {
    @State private var cards: [Card] = []                         // Reactive state for cards
    @State private var showingAddCardForm = false                 // Controls visibility of AddCardForm sheet
    @State private var selectedCardToEdit: Card? = nil
    @State private var showingEditForm = false

    let fileName = "cards.json"                                   // File to save cards

    var body: some View {
        NavigationView {
            List {
                ForEach(cards) { card in
                    NavigationLink(destination: CardDetailView(card: card)) {
                        VStack(alignment: .leading) {
                            Text(card.storeName).font(.headline)
                            Text(card.cardNumber).font(.subheadline)
                        }
                    }
                    //Add swipe actions
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            selectedCardToEdit = card
                            showingEditForm = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }.tint(.blue)
                    }
                }
                .onDelete(perform: deleteCard)
            }

            .navigationTitle("My Cards")                          // Top bar title
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCardForm = true }) {
                        Image(systemName: "plus")                 // "+" button to add new card
                    }
                }
            }

            .sheet(isPresented: $showingAddCardForm) {
                NavigationView {
                    AddCardForm(cards: $cards, saveCards: saveCards, editingCard: nil)
                }
            }

            .sheet(isPresented: $showingEditForm) {
                if let card = selectedCardToEdit {
                    NavigationView {
                        AddCardForm(cards: $cards, saveCards: saveCards, editingCard: card)
                    }
                }
            }




        }
        .onAppear(perform: loadCards)                             // Load saved cards when app starts
    }

    // MARK: - Load Cards from File
    func loadCards() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName) // Create file URL
        if let data = try? Data(contentsOf: url) {                          // Try reading file
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded                                            // Load into state
            }
        }
    }

    // MARK: - Save Cards to File
    func saveCards() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName) // Create file URL
        if let data = try? JSONEncoder().encode(cards) {                   // Encode cards as JSON
            try? data.write(to: url)                                       // Save to file
        }
    }
        // DElete
    func deleteCard(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)  // Remove selected card(s)
        saveCards()                       // Save the updated list
    }


    // MARK: - Helper to Get File Path
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // Get the app's documents folder
    }
}
