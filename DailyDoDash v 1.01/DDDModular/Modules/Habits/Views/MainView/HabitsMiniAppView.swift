import SwiftUI

struct HabitsMiniAppView: View {
    var body: some View {
        HabitsListView()
    }
}

struct HabitsMiniAppView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Обертка для корректного отображения заголовка из HabitsListView
            HabitsMiniAppView()
                .environmentObject(HabitDataStore.preview)
        }
    }
}
