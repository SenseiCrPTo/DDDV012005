import UIKit

class TodoViewController: UIViewController {
    private let viewModel = TodoViewModel()
    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        title = "To-do"
        setupUI()
        reloadUI()
    }

    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))

        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TodoCell")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func addTapped() {
        let alert = UIAlertController(title: "New Task", message: "Enter task name", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Title"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            if let title = alert.textFields?.first?.text, !title.isEmpty {
                self.viewModel.addTodo(title: title)
                self.reloadUI()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func reloadUI() {
        viewModel.load()
        tableView.reloadData()
    }
}

extension TodoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todo = viewModel.todos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        cell.textLabel?.text = todo.title
        cell.accessoryType = todo.isDone ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = viewModel.todos[indexPath.row]
        viewModel.toggleDone(id: todo.id)
        reloadUI()
    }

    // Swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todo = viewModel.todos[indexPath.row]
            viewModel.deleteTodo(id: todo.id)
            reloadUI()
        }
    }
}
