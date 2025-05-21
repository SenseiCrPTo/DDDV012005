import SwiftUI

struct BodyWidgetView: View {
    @EnvironmentObject var bodyDataStore: BodyDataStore

    var body: some View {
        NavigationLink(destination: BodyMiniAppView()) { // <--- ИСПРАВЛЕНО
            VStack(alignment: .leading, spacing: 4) {
                Text("Тело").font(.system(.headline, design: .rounded).bold())
            
                MetricRow(label:"Вес:", value: bodyDataStore.currentWeightString)
                MetricRow(label:"Дней тренировок (всего):", value:"\(bodyDataStore.totalTrainingDays)")
                MetricRow(label:"Цель (нед.):", value: "\(bodyDataStore.targetWorkoutsPerWeek) дн.")

                Text("Тренировки (нед.):").font(.caption.bold()).padding(.top,2)
                
                HabitTrackerBar(daysDone: bodyDataStore.workoutsThisWeekCount, totalDays: 7, activeColor: .indigo)
                
                Text("\(bodyDataStore.workoutsThisWeekCount) из \(bodyDataStore.targetWorkoutsPerWeek > 0 ? String(bodyDataStore.targetWorkoutsPerWeek) : "~") (цель)").font(.caption2).foregroundColor(.gray)
                
                Spacer()
            }
            .padding(10).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .contentShape(Rectangle()).background(Material.thin).cornerRadius(16).foregroundColor(.primary)
        }
    }
}
struct BodyWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        BodyWidgetView().environmentObject(BodyDataStore.preview)
            .padding().previewLayout(.fixed(width: 170, height: 170)).background(Color(UIColor.systemGray6))
    }
}
