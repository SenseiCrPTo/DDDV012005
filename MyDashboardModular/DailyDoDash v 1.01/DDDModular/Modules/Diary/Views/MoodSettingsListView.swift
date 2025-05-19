import SwiftUI

struct MoodSettingsListView: View {
    @EnvironmentObject var diaryDataStore: DiaryDataStore
    @State private var showingAddEditMoodSheet = false
    @State private var moodToEdit: MoodSetting?

    var body: some View {
        List {
            ForEach(diaryDataStore.moodSettings.sorted { $0.name < $1.name }) { mood in // Добавил сортировку
                HStack {
                    if let iconName = mood.iconName, !iconName.isEmpty {
                        Image(systemName: iconName).foregroundColor(mood.color ?? .primary).frame(width: 22, alignment: .center)
                    } else if let color = mood.color {
                        Circle().fill(color).frame(width: 15, height: 15).frame(width: 22, alignment: .center)
                    } else {
                        Circle().fill(Color.gray.opacity(0.3)).frame(width:15, height:15).frame(width: 22, alignment: .center)
                    }
                    Text(mood.name)
                    Spacer()
                    Text("Оценка: \(mood.ratingValue)").font(.caption).foregroundColor(.gray)
                }
                .contentShape(Rectangle())
                .onTapGesture { self.moodToEdit = mood; self.showingAddEditMoodSheet = true }
            }
            .onDelete(perform: deleteMoods)
        }
        .navigationTitle("Настройки настроений")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.moodToEdit = nil
                    self.showingAddEditMoodSheet = true
                } label: { Label("Добавить", systemImage: "plus.circle.fill") }
            }
            ToolbarItem(placement: .navigationBarLeading) { EditButton() }
        }
        .sheet(isPresented: $showingAddEditMoodSheet) {
            // AddEditMoodSettingView должен использовать @EnvironmentObject и не принимать diaryDataStore в init
            AddEditMoodSettingView(moodToEdit: self.moodToEdit) // <--- ИСПРАВЛЕНО: Удален параметр diaryDataStore
        }
    }
    private func deleteMoods(at offsets: IndexSet) {
        let sortedMoods = diaryDataStore.moodSettings.sorted { $0.name < $1.name }
        offsets.map { sortedMoods[$0].id }.forEach { idToDelete in
            diaryDataStore.deleteMoodSetting(id: idToDelete)
        }
    }
}

struct MoodSettingsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MoodSettingsListView()
                .environmentObject(DiaryDataStore.preview)
        }
    }
}
