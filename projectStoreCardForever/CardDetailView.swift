import SwiftUI
import CoreImage.CIFilterBuiltins

struct CardDetailView: View {
    let card: Card

    let context = CIContext()

    var body: some View {
        VStack(spacing: 20) {
            Text(card.storeName).font(.title).padding(.top)

            if let image = generateBarcode(from: card.cardNumber, type: card.barcodeType) {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .padding()
            } else {
                Text("⚠️ Barcode generation failed")
                    .foregroundColor(.red)
            }

            Text(card.cardNumber).font(.caption).foregroundColor(.gray)
            Spacer()
        }
        .padding()
        .navigationTitle("Card Details")
    }

    // MARK: - Barcode Generator (switch based on type)
    func generateBarcode(from string: String, type: String) -> UIImage? {
        let data = Data(string.utf8)

        let filter: CIFilter?
        switch type {
        case "qr":
            let qr = CIFilter.qrCodeGenerator()
            qr.setValue(data, forKey: "inputMessage")
            filter = qr
        case "ean13":
            let ean = CIFilter(name: "CICode128BarcodeGenerator")
            ean?.setValue(data, forKey: "inputMessage")
            filter = ean
        case "code128":
            fallthrough
        default:
            let code = CIFilter.code128BarcodeGenerator()
            code.setValue(data, forKey: "inputMessage")
            filter = code
        }

        if let outputImage = filter?.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return nil
    }
}
