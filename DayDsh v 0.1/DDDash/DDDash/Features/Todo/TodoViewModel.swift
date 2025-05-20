import Foundation

class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []

    init() {
        load()
    }

    func load() {
        todos = TodoRepository.shared.getTodos()
    }

    func addTodo(title: String, dueDate: Date? = nil) {
        let todo = TodoItem(id: UUID(), title: title, isDone: false, dueDate: dueDate)
        TodoRepository.shared.addTodo(todo)
        load()
    }

    func toggleDone(id: UUID) {
        TodoRepository.shared.toggleDone(id: id)
        load()
    }

    func deleteTodo(id: UUID) {
        TodoRepository.shared.deleteTodo(id: id)
        load()
    }
}
