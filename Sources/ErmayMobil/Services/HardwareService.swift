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
#if canImport(ContactsUI)
import ContactsUI
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

public struct ContactPickResult {
    public let unvan: String
    public let telefon: String?
    public let email: String?
    public let adres: String?
    
    public init(unvan: String, telefon: String? = nil, email: String? = nil, adres: String? = nil) {
        self.unvan = unvan
        self.telefon = telefon
        self.email = email
        self.adres = adres
    }
}

#if canImport(UIKit) && canImport(ContactsUI)
public struct ContactPickerBridge: UIViewControllerRepresentable {
    public let onSelect: (ContactPickResult) -> Void
    @Environment(\.dismiss) private var dismiss
    
    public init(onSelect: @escaping (ContactPickResult) -> Void) {
        self.onSelect = onSelect
    }
    
    public func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPickerBridge
        
        init(_ parent: ContactPickerBridge) {
            self.parent = parent
        }
        
        public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let fullName = [contact.organizationName.isEmpty ? nil : contact.organizationName,
                            "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)]
                .compactMap { $0 }
                .first ?? "Yeni Müşteri"
            
            let phone = contact.phoneNumbers.first?.value.stringValue
            let email = contact.emailAddresses.first?.value as String?
            let postal = contact.postalAddresses.first?.value
            let address = postal != nil ? "\(postal!.street), \(postal!.city)" : nil
            
            let result = ContactPickResult(unvan: fullName, telefon: phone, email: email, adres: address)
            parent.onSelect(result)
        }
        
        public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {}
    }
}
#endif

public final class LocationHelper: NSObject, @unchecked Sendable {
    public static let shared = LocationHelper()
    
    #if canImport(CoreLocation)
    private let locationManager = CLLocationManager()
    #endif
    
    private override init() {
        super.init()
    }
    
    public func getCurrentCityAndAddress() async -> (sehir: String, adres: String)? {
        #if canImport(CoreLocation)
        locationManager.requestWhenInUseAuthorization()
        guard let location = locationManager.location else {
            return ("İstanbul", "İkitelli OSB, Başakşehir")
        }
        
        let geocoder = CLGeocoder()
        if let placemarks = try? await geocoder.reverseGeocodeLocation(location),
           let first = placemarks.first {
            let city = first.administrativeArea ?? first.locality ?? "İstanbul"
            let street = [first.thoroughfare, first.subThoroughfare, first.subLocality].compactMap { $0 }.joined(separator: " ")
            return (city, street.isEmpty ? "Merkez" : street)
        }
        return ("İstanbul", "İkitelli OSB")
        #else
        return ("İstanbul", "İkitelli OSB")
        #endif
    }
}
