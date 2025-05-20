import UIKit

class SecondBrainViewController: UIViewController {
    private let viewModel = SecondBrainViewModel()
    private var tableView: UITableView!
    private var addButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        title = "Second Brain"
        setupUI()
        reloadUI()
    }

    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))

        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NoteCell")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func addTapped() {
        let alert = UIAlertController(title: "New Note", message: "Enter note", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Note"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            if let content = alert.textFields?.first?.text, !content.isEmpty {
                self.viewModel.addNote(content: content)
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

extension SecondBrainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = viewModel.notes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        cell.textLabel?.text = "[\(formatter.string(from: note.createdAt))] \(note.content)"
        cell.textLabel?.numberOfLines = 2
        return cell
    }

    // Swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = viewModel.notes[indexPath.row]
            viewModel.deleteNote(id: note.id)
            reloadUI()
        }
    }
}
