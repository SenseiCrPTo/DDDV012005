import Foundation

struct BodyWeightLog:Identifiable,Codable,Hashable{
    let id:UUID
    var date:Date
    var weightInKg:Double

    init(id:UUID=UUID(),date:Date=Date(),weightInKg:Double){
        self.id=id
        self.date=date
        self.weightInKg=weightInKg
    }
}
