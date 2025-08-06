//
//  View+GlassBackground.swift
//  OrderMate
//
//  Created by Naveen on 8/5/25.
//

// View+GlassBackground.swift
import SwiftUI

extension View {
    func glassBackground(cornerRadius: CGFloat = 20) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
}
