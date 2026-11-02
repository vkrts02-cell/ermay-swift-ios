import SwiftUI
#if canImport(AVFoundation)
import AVFoundation
#endif
#if canImport(UIKit)
import UIKit
#endif

public struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    public let onBarcodeScanned: (String) -> Void
    
    public init(onBarcodeScanned: @escaping (String) -> Void) {
        self.onBarcodeScanned = onBarcodeScanned
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                #if canImport(UIKit) && canImport(AVFoundation)
                CameraScannerBridge { code in
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    onBarcodeScanned(code)
                    dismiss()
                }
                .ignoresSafeArea()
                #else
                Text("Kamera bu platformda desteklenmiyor")
                    .foregroundColor(.white)
                #endif
                
                // Overlay Vizör
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.8))
                                .padding()
                        }
                    }
                    
                    Spacer()
                    
                    // Tarama Kutusu (Target Area)
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.6), lineWidth: 2)
                            .frame(width: 260, height: 180)
                        
                        // Kırmızı Lazer Çizgisi
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: 240, height: 2)
                    }
                    
                    Text("Barkod veya QR Kodu çerçeveye ortalayın")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.top, 24)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#if canImport(UIKit) && canImport(AVFoundation)
struct CameraScannerBridge: UIViewControllerRepresentable {
    let onCode: (String) -> Void
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.onCodeFound = onCode
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeFound: ((String) -> Void)?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasFoundCode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              session.canAddInput(videoInput) else {
            return
        }
        
        session.addInput(videoInput)
        let metadataOutput = AVCaptureMetadataOutput()
        
        guard session.canAddOutput(metadataOutput) else { return }
        session.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.ean13, .ean8, .qr, .code128, .code39, .upce]
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.layer.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        self.previewLayer = preview
        self.captureSession = session
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !hasFoundCode,
              let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }
        hasFoundCode = true
        captureSession?.stopRunning()
        onCodeFound?(stringValue)
    }
}
#endif

