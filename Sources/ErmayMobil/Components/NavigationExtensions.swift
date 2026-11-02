import SwiftUI
#if canImport(UIKit)
import UIKit

// MARK: - Native UINavigationController Interactive Pop Gesture
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        interactivePopGestureRecognizer?.isEnabled = true
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
#endif

// MARK: - Universal SwiftUI Edge Swipe-Back Modifier
public struct SwipeBackModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    
    public func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 15, coordinateSpace: .global)
                    .onEnded { value in
                        // Detect left edge swipe (starting at x < 65) moving right by at least 60px
                        if value.startLocation.x < 65 && value.translation.width > 60 && abs(value.translation.height) < 90 {
                            dismiss()
                        }
                    }
            )
    }
}

extension View {
    public func enableSwipeBack() -> some View {
        self.modifier(SwipeBackModifier())
    }
}
