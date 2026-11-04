import SwiftUI
#if canImport(UIKit)
import UIKit

// MARK: - Global UIKit Keyboard Dismiss Accessory View
// Tüm TextField ve TextView'ların üstüne otomatik 'Klavyeyi Kapat' barı ekler
public final class KeyboardAccessoryHelper {
    public static func makeToolbar(target: Any?, action: Selector) -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 42))
        toolbar.barStyle = .black
        toolbar.isTranslucent = true
        toolbar.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 22/255, alpha: 0.96)
        toolbar.tintColor = UIColor(red: 0.0, green: 1.0, blue: 0.53, alpha: 1.0) // 00FF87 Yeşil
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(
            title: "✓ Klavyeyi Kapat",
            style: .done,
            target: target,
            action: action
        )
        doneBtn.setTitleTextAttributes([
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor(red: 0.0, green: 1.0, blue: 0.53, alpha: 1.0)
        ], for: .normal)
        
        toolbar.items = [flex, doneBtn]
        toolbar.sizeToFit()
        return toolbar
    }
}

extension UITextField {
    @objc open override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.inputAccessoryView == nil {
            self.inputAccessoryView = KeyboardAccessoryHelper.makeToolbar(
                target: self,
                action: #selector(resignFirstResponder)
            )
        }
    }
}

extension UITextView {
    @objc open override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.inputAccessoryView == nil {
            self.inputAccessoryView = KeyboardAccessoryHelper.makeToolbar(
                target: self,
                action: #selector(resignFirstResponder)
            )
        }
    }
}
#endif

// MARK: - SwiftUI View Modifiers for Keyboard
public extension View {
    /// Klavyeyi anında kapatır
    func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
    
    /// Klavyenin üzerine 'Klavyeyi Kapat' butonu ekler
    func keyboardDismissToolbar(buttonTitle: String = "Klavyeyi Kapat") -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    hideKeyboard()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 13, weight: .bold))
                        Text(buttonTitle)
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "00FF87"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    /// Boş bir alana dokunulduğunda klavyeyi kapatır
    func hideKeyboardOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                hideKeyboard()
            }
        )
    }
}
