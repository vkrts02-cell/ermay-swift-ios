import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(CoreLocation)
import CoreLocation
#endif
#if canImport(Contacts)
import Contacts
#endif
#if canImport(AVFoundation)
import AVFoundation
#endif

@MainActor
public final class HardwareService: NSObject, ObservableObject {
    public static let shared = HardwareService()
    
    @Published public var userLocation: String? = nil
    @Published public var scannedBarcode: String? = nil
    
    private override init() {
        super.init()
    }
    
    // MARK: - Haptic Feedback
    public nonisolated func hapticSuccess() {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        #endif
    }
    
    public nonisolated func hapticWarning() {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
        #endif
    }
    
    public nonisolated func hapticError() {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        #endif
    }
    
    public nonisolated func hapticImpact() {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        #endif
    }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    
    // MARK: - Add Contact to iOS Address Book
    public func addCariToContacts(cari: CariKart) async -> Bool {
        #if canImport(Contacts)
        let store = CNContactStore()
        do {
            let granted = try await store.requestAccess(for: .contacts)
            guard granted else { return false }
            
            let contact = CNMutableContact()
            contact.organizationName = cari.unvan
            contact.jobTitle = cari.cariTuru ?? "Cari"
            
            if let tel = cari.telefon ?? cari.gsm {
                contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: tel))]
            }
            if let email = cari.email {
                contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: email as NSString)]
            }
            if let adres = cari.adres {
                let postal = CNMutablePostalAddress()
                postal.street = adres
                postal.city = cari.sehir ?? ""
                postal.state = cari.ilce ?? ""
                contact.postalAddresses = [CNLabeledValue(label: CNLabelWork, value: postal)]
            }
            
            let saveRequest = CNSaveRequest()
            saveRequest.add(contact, toContainerWithIdentifier: nil)
            try store.execute(saveRequest)
            hapticSuccess()
            return true
        } catch {
            print("Contact save error: \(error.localizedDescription)")
            hapticError()
            return false
        }
        #else
        return false
        #endif
    }
}
