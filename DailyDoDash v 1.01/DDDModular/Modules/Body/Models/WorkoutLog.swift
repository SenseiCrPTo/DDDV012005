import Foundation

struct WorkoutLog: Identifiable, Codable {
    let id: UUID
    var date: Date
    var workoutTypeID: UUID?
    var duration: TimeInterval?
    var exercisesWithSets: [ExerciseLogDetail] // Использует ExerciseLogDetail
    var notes: String?

    init(id:UUID=UUID(),date:Date=Date(),workoutTypeID:UUID?=nil,duration:TimeInterval?=nil,exercisesWithSets:[ExerciseLogDetail]=[],notes:String?=nil){
        self.id=id
        self.date=date
        self.workoutTypeID=workoutTypeID
        self.duration=duration
        self.exercisesWithSets=exercisesWithSets
        self.notes=notes
    }
}
