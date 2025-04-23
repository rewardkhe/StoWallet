import SwiftUI
import AVFoundation
import Vision

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, BarcodeScannerDelegate {
        let parent: BarcodeScannerView

        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }

        func didFind(code: String) {
            parent.scannedCode = code
            parent.dismiss()
        }
    }
}

protocol BarcodeScannerDelegate {
    func didFind(code: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var delegate: BarcodeScannerDelegate?
    var captureSession = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        print("Camera view loaded") // debug check
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else { return }

        captureSession.addInput(videoInput)

        let output = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.ean13, .code128, .qr]
        }

        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.frame = view.layer.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)

        captureSession.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readable = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readable.stringValue {
            captureSession.stopRunning()
            delegate?.didFind(code: stringValue)
        }
    }
}
