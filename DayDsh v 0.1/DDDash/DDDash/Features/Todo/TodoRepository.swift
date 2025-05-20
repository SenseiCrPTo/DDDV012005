import Foundation

class TodoRepository {
    static let shared = TodoRepository()
    private let todosKey = "todo_items"

    private init() {}

    func getTodos() -> [TodoItem] {
        guard let data = UserDefaults.standard.data(forKey: todosKey),
              let decoded = try? JSONDecoder().decode([TodoItem].self, from: data)
        else { return [] }
        return decoded
    }

    func saveTodos(_ todos: [TodoItem]) {
        if let data = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(data, forKey: todosKey)
        }
    }

    func addTodo(_ todo: TodoItem) {
        var todos = getTodos()
        todos.insert(todo, at: 0)
        saveTodos(todos)
    }

    func toggleDone(id: UUID) {
        var todos = getTodos()
        if let index = todos.firstIndex(where: { $0.id == id }) {
            todos[index].isDone.toggle()
            saveTodos(todos)
        }
    }

    func deleteTodo(id: UUID) {
        var todos = getTodos()
        todos.removeAll { $0.id == id }
        saveTodos(todos)
    }
}
