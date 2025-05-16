import Foundation

struct ExerciseTemplateDetail:Identifiable,Hashable,Codable{
    let id:UUID
    var exerciseID:UUID // Ссылка на Exercise.id
    var sets:[SetTemplate] // Использует SetTemplate

    init(id:UUID=UUID(),exerciseID:UUID,sets:[SetTemplate]=[]){
        self.id=id
        self.exerciseID=exerciseID
        self.sets=sets
    }
}
