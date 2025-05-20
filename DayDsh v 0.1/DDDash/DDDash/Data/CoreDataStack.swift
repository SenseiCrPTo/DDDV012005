import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "Entities") // Имя = имя .xcdatamodeld файла
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data stack failed to load: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("CoreData save error: \(error)")
            }
        }
    }
}
