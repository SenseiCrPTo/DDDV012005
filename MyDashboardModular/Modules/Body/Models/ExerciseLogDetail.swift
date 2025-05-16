import Foundation

struct ExerciseLogDetail: Identifiable, Hashable, Codable {
    let id: UUID
    var exercise: Exercise   // Использует Exercise
    var sets: [WorkoutSet] // Использует WorkoutSet

    init(id: UUID = UUID(), exercise: Exercise, sets: [WorkoutSet] = []) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
    }

    static func from(templateDetail: ExerciseTemplateDetail, exercise: Exercise) -> ExerciseLogDetail {
        return ExerciseLogDetail(id:UUID(),exercise:exercise,sets:templateDetail.sets.map{WorkoutSet.from(templateSet:$0,exerciseID:exercise.id)})
    }
}
