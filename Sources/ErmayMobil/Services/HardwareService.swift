import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(ContactsUI)
import ContactsUI
#endif
#if canImport(CoreLocation)
import CoreLocation
#endif

public struct ContactPickResult {
    public let unvan: String
    public let telefon: String?
    public let email: String?
    public let adres: String?
}

#if canImport(UIKit) && canImport(ContactsUI)
import SwiftUI

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

