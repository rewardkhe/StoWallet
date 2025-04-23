import Foundation

struct Card: Identifiable, Codable {
    let id: UUID                 // Unique identifier for each card
    var storeName: String       // Name of the store
    var cardNumber: String      // The barcode/loyalty number
    var notes: String?          // Optional notes
    var barcodeType: String     // Type of barcode, like "code128", "qr"
}
