import UIKit

class HabitViewController: UIViewController {
    private let viewModel = HabitViewModel()
    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        title = "Habit"
        setupUI()
        reloadUI()
    }

    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))

        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HabitCell")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func addTapped() {
        let alert = UIAlertController(title: "New Habit", message: "Enter habit name", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Habit"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                self.viewModel.addHabit(name: name)
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

extension HabitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.habits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let habit = viewModel.habits[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCell", for: indexPath)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        cell.textLabel?.text = "[\(formatter.string(from: habit.createdAt))] \(habit.name)"
        cell.accessoryType = habit.isDone ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let habit = viewModel.habits[indexPath.row]
        viewModel.toggleDone(id: habit.id)
        reloadUI()
    }

    // Swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let habit = viewModel.habits[indexPath.row]
            viewModel.deleteHabit(id: habit.id)
            reloadUI()
        }
    }
}
