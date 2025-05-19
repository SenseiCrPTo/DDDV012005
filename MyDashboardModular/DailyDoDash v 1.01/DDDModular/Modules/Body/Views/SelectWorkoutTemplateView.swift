import SwiftUI

struct SelectWorkoutTemplateView: View {
    @EnvironmentObject var bodyDataStore: BodyDataStore // <--- ИЗМЕНЕНО
    var onTemplateSelected: (WorkoutTemplate) -> Void
    @Environment(\.dismiss) var dismiss

    // Убираем bodyDataStore из init
    // init(bodyDataStore: BodyDataStore, onTemplateSelected: @escaping (WorkoutTemplate) -> Void, dismiss: DismissAction) { ... }
    // Если конструктор был только для @ObservedObject, он теперь не нужен.
    // Если были другие параметры, их нужно оставить.

    var body: some View {
        NavigationView {
            List {
                if bodyDataStore.workoutTemplates.isEmpty {
                    Text("Нет доступных шаблонов. Сначала создайте их в настройках.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(bodyDataStore.workoutTemplates.sorted(by: { $0.name < $1.name })) { template in
                        Button {
                            onTemplateSelected(template)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading) {
                                Text(template.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                if let typeId = template.workoutTypeID,
                                   let typeName = bodyDataStore.workoutTypes.first(where: {$0.id == typeId})?.name {
                                    Text("Тип: \(typeName)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Text("Упражнений: \(template.templateExercises.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Выбрать шаблон")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SelectWorkoutTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        SelectWorkoutTemplateView(onTemplateSelected: { template in
            print("Выбран шаблон: \(template.name)")
        })
        .environmentObject(BodyDataStore.preview) // <--- ИЗМЕНЕНО
    }
}
