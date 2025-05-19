// MoneyWidget.swift
import SwiftUI

struct MoneyWidget: View {
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            Color.widgetBackground
                .cornerRadius(20)
                .shadow(radius: 5)
            
            VStack {
                Text("Money")
                    .font(.system(size: 55.33, weight: .bold))
                    .foregroundColor(.textPrimary)
                // Добавьте ваши данные здесь
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
        }
        .frame(width: 643.95, height: 894.96)
        .onTapGesture {
            isPressed.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
        }
    }
}
