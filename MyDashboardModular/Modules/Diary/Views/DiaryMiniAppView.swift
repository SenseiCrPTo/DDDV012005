import SwiftUI

struct DiaryMiniAppView: View {
    @EnvironmentObject var diaryDataStore: DiaryDataStore // <--- ИЗМЕНЕНО
    @State private var showingAddEntrySheet = false
    @State private var entryToEdit: DiaryEntry? = nil

    var body: some View {
        List {
            if diaryDataStore.entries.isEmpty {
                Text("Пока нет ни одной записи в дневнике. Нажмите '+' чтобы добавить первую.")
                    .foregroundColor(.gray).multilineTextAlignment(.center)
                    .padding(.vertical, 50).listRowSeparator(.hidden)
            } else {
                ForEach(diaryDataStore.entries) { entry in
                    // DiaryEntryRowView должен быть обновлен или получать moodSettings как параметр
                    DiaryEntryRowView(entry: entry, moodSettings: diaryDataStore.moodSettings)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.entryToEdit = entry
                            self.showingAddEntrySheet = true
                        }
                }
                .onDelete(perform: deleteEntries)
            }
        }
        .navigationTitle("Мой Дневник")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { EditButton() }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // MoodSettingsListView и DiaryStatsView должны быть обновлены
                NavigationLink(destination: MoodSettingsListView()) { Label("Настройки", systemImage: "slider.horizontal.3") }
                NavigationLink(destination: DiaryStatsView()) { Label("Статистика", systemImage: "chart.bar.xaxis") }
                Button {
                    self.entryToEdit = nil
                    self.showingAddEntrySheet = true
                } label: { Label("Новая запись", systemImage: "plus.circle.fill") }
            }
        }
        .sheet(isPresented: $showingAddEntrySheet) {
            // AddEditDiaryEntryView должен быть обновлен
            AddEditDiaryEntryView(entryToEdit: entryToEdit)
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        offsets.map { diaryDataStore.entries[$0].id }.forEach { id in
            diaryDataStore.deleteEntry(id: id)
        }
    }
}

struct DiaryMiniAppView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DiaryMiniAppView()
                .environmentObject(DiaryDataStore.preview) // Убедись, что DiaryDataStore.preview существует
        }
    }
}
