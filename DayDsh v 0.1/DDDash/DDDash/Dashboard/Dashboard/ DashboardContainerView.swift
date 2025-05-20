import SwiftUI

struct DashboardContainerView: View {
    @ObservedObject var viewModel: DashboardViewModel
    var coordinator: DashboardCoordinator

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                MoneyWidgetView(amount: viewModel.money)
                    .onTapGesture { coordinator.showMoney() }
                TodoWidgetView(todos: viewModel.todos)
                    .onTapGesture { coordinator.showTodo() }
            }
            HStack(spacing: 16) {
                BodyWidgetView(info: viewModel.bodyInfo)
                    .onTapGesture { coordinator.showBody() }
                SecondBrainWidgetView(note: viewModel.secondBrain)
                    .onTapGesture { coordinator.showSecondBrain() }
            }
            HabitWidgetView(habit: viewModel.habit)
                .onTapGesture { coordinator.showHabit() }
        }
        .padding()
        .background(Color("backgroundMain").ignoresSafeArea())
    }
}
