// DashboardContainerView.swift
import SwiftUI

struct DashboardContainerView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Color.backgroundMain.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("DailyDo")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.mainText)
                        Text("Dash")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.dashAccent)
                        // Orange underline
                    }
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.dashAccent)
                        .padding(.top, -8)
                        .frame(width: 110, alignment: .leading) // Подстрой ширину под "Dash"

                    Spacer().frame(height: 8)
                    
                    // Widgets Grid
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            MoneyWidgetView(amount: viewModel.money)
                            TodoWidgetView(todos: viewModel.todos)
                        }
                        .frame(maxHeight: .infinity)
                        HStack(spacing: 12) {
                            BodyWidgetView(info: viewModel.bodyInfo)
                            SecondBrainWidgetView(note: viewModel.secondBrain)
                        }
                        .frame(maxHeight: .infinity)
                        HabitWidgetView(habit: viewModel.habit)
                            .frame(maxWidth: .infinity, minHeight: geo.size.height * 0.18)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 18)
                .padding(.top, 48)
            }
        }
    }
}

