import SwiftUI

// MARK: - Universal SwiftUI Edge Swipe-Back Modifier (HIGH-IOS-04 Safe Localized Gesture)
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
