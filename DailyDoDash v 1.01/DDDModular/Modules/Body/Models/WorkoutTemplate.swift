import Foundation

struct WorkoutTemplate:Identifiable,Codable{
    let id:UUID
    var name:String
    var workoutTypeID:UUID?
    var templateExercises:[ExerciseTemplateDetail] // Использует ExerciseTemplateDetail

    init(id:UUID=UUID(),name:String="",workoutTypeID:UUID?=nil,templateExercises:[ExerciseTemplateDetail]=[]){
        self.id=id
        self.name=name
        self.workoutTypeID=workoutTypeID
        self.templateExercises=templateExercises
    }
}
