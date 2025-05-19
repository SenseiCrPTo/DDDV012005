import Foundation // Для DateComponentsFormatter

struct SetTemplate: Identifiable, Hashable, Codable {
    let id: UUID
    var setIndex: Int
    var targetReps: String? // Например "8-12" или "AMRAP"
    var targetWeight: Double?
    var targetDuration: TimeInterval?
    var targetRestTime: TimeInterval? // Время отдыха после этого подхода

    init(id: UUID = UUID(), setIndex: Int, targetReps: String? = "8-12", targetWeight: Double? = nil, targetDuration: TimeInterval? = nil, targetRestTime: TimeInterval? = nil) {
        self.id = id
        self.setIndex = setIndex
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.targetDuration = targetDuration
        self.targetRestTime = targetRestTime
    }

    var displayString:String {
        var p:[String]=[]
        if let r=targetReps, !r.isEmpty {p.append("\(r) повт.")}
        if let w=targetWeight {p.append(String(format:"%.1f",w)+" кг")}
        if let d=targetDuration, d>0 {
            let f=DateComponentsFormatter()
            f.allowedUnits=[.minute,.second]
            f.unitsStyle = .abbreviated
            p.append(f.string(from:d) ?? "\(Int(d)) сек")
        }
        if p.isEmpty{ return "Подход \(setIndex)" }
        return "Подход \(setIndex): "+p.joined(separator:" / ")
    }
}
