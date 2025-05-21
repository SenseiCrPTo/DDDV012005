import Foundation // Для Date, TimeInterval

struct WorkoutSet: Identifiable, Hashable, Codable {
    let id: UUID
    var exerciseID: UUID
    var setIndex: Int
    var reps: Int?
    var weight: Double?
    var duration: TimeInterval?

    var isCompleted: Bool = false
    var completionTimestamp: Date?
    var notes: String?

    init(id: UUID = UUID(), exerciseID: UUID, setIndex: Int, reps: Int? = nil, weight: Double? = nil, duration: TimeInterval? = nil, isCompleted: Bool = false, completionTimestamp: Date? = nil, notes: String? = nil) {
        self.id = id
        self.exerciseID = exerciseID
        self.setIndex = setIndex
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.isCompleted = isCompleted
        self.completionTimestamp = completionTimestamp
        self.notes = notes
    }

    static func from(templateSet: SetTemplate, exerciseID: UUID) -> WorkoutSet {
        let intReps: Int? = Int(templateSet.targetReps?.components(separatedBy: CharacterSet.decimalDigits.inverted).first ?? "")
        return WorkoutSet(exerciseID: exerciseID, setIndex: templateSet.setIndex, reps: intReps, weight: templateSet.targetWeight, duration: templateSet.targetDuration)
    }

    var displayString: String {
        var p:[String]=[]
        if let r=reps{p.append("\(r) повт.")}
        if let w=weight{p.append(String(format:"%.1f",w)+" кг")}
        if let d=duration,d>=0{
            if d > 0 || (reps==nil && weight==nil && duration != nil ) {
                p.append("\(Int(d)) сек")
            }
        }
        if p.isEmpty && (reps != nil || weight != nil || duration != nil) { return "Подход \(setIndex)" }
        else if p.isEmpty { return "Подход \(setIndex): Пусто" }
        return "Подход \(setIndex): "+p.joined(separator:" / ")
    }
}
