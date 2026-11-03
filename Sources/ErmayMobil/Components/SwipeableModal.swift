import SwiftUI

public struct SwipeableModal<Content: View>: View {
    @Binding public var isPresented: Bool
    public let title: String
    public let content: Content
    
    public init(
        isPresented: Binding<Bool>,
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.title = title
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            if isPresented {
                // Dimmed Overlay
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
                
                // Bottom Sheet Container
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Drag Handle
                        Capsule()
                            .fill(AppTheme.textMuted.opacity(0.5))
                            .frame(width: 36, height: 5)
                            .padding(.top, 10)
                            .padding(.bottom, 8)
                        
                        // Header
                        HStack {
                            Text(title)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    isPresented = false
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        
                        Divider().background(AppTheme.border)
                        
                        // Body Content
                        ScrollView {
                            content
                                .padding(16)
                        }
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.82)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(hex: "121214"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(AppTheme.borderLight, lineWidth: 1)
                            )
                    )
                    .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: isPresented)
    }
}

