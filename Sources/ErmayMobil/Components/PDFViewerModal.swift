import SwiftUI
#if canImport(UIKit)
import UIKit
import PDFKit
#endif

#if canImport(UIKit)
public struct PDFKitRepresentedView: UIViewRepresentable {
    public let pdfData: Data
    
    public init(pdfData: Data) {
        self.pdfData = pdfData
    }
    
    public func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = PDFDocument(data: pdfData)
        pdfView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        return pdfView
    }
    
    public func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document == nil || uiView.document?.dataRepresentation() != pdfData {
            uiView.document = PDFDocument(data: pdfData)
        }
    }
}
#endif

public struct PDFViewerModal: View {
    @Environment(\.dismiss) private var dismiss
    public let title: String
    public let pdfData: Data
    public let fileName: String
    
    public init(title: String, pdfData: Data, fileName: String? = nil) {
        self.title = title
        self.pdfData = pdfData
        self.fileName = fileName ?? "\(title.replacingOccurrences(of: " ", with: "_")).pdf"
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                #if canImport(UIKit)
                VStack(spacing: 0) {
                    // Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text("Resmi PDF Doküman Önizleme")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "8E8E93"))
                        }
                        
                        Spacer()
                        
                        // Print Button
                        Button {
                            printPDF()
                        } label: {
                            Image(systemName: "printer.fill")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        // Share / Save Button
                        Button {
                            sharePDF()
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Paylaş")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color(hex: "2563EB"))
                            .cornerRadius(8)
                        }
                        
                        // Dismiss
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "8E8E93"))
                                .padding(.leading, 6)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(hex: "121216"))
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    // PDF View
                    PDFKitRepresentedView(pdfData: pdfData)
                        .edgesIgnoringSafeArea(.bottom)
                }
                #else
                Text("PDF önizleme bu platformda desteklenmiyor.")
                    .foregroundColor(.white)
                #endif
            }
            .navigationBarHidden(true)
        }
    }
    
    #if canImport(UIKit)
    private func sharePDF() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try pdfData.write(to: tempURL)
            let av = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                // iPad popover crash önlemi
                if let popover = av.popoverPresentationController {
                    popover.sourceView = rootVC.view
                    popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                rootVC.present(av, animated: true)
            }
        } catch {
            print("PDF kaydetme hatası: \(error)")
        }
    }
    
    private func printPDF() {
        guard UIPrintInteractionController.isPrintingAvailable else { return }
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = title
        printController.printInfo = printInfo
        printController.printingItem = pdfData
        printController.present(animated: true, completionHandler: nil)
    }
    #endif
}

