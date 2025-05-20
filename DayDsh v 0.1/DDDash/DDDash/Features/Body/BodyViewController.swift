import UIKit

class BodyViewController: UIViewController {
    private let viewModel = BodyViewModel()
    private var tableView: UITableView!
    private var latestLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        title = "Body"
        setupUI()
        reloadUI()
    }

    private func setupUI() {
        latestLabel = UILabel()
        latestLabel.font = .boldSystemFont(ofSize: 24)
        latestLabel.translatesAutoresizingMaskIntoConstraints = false

        let addButton = UIButton(type: .system)
        addButton.setTitle("Add", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BodyCell")

        view.addSubview(latestLabel)
        view.addSubview(addButton)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            latestLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            latestLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            addButton.centerYAnchor.constraint(equalTo: latestLabel.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            tableView.topAnchor.constraint(equalTo: latestLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func addTapped() {
        let alert = UIAlertController(title: "Add Record", message: "Enter today's data", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Weight (kg)"
            tf.keyboardType = .decimalPad
        }
        alert.addTextField { tf in
            tf.placeholder = "Steps"
            tf.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            let weight = Double(alert.textFields?[0].text ?? "")
            let steps = Int(alert.textFields?[1].text ?? "")
            self.viewModel.addRecord(weight: weight, steps: steps)
            self.reloadUI()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func reloadUI() {
        viewModel.load()
        if let latest = viewModel.latestRecord {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            var text = "Latest: \(formatter.string(from: latest.date))"
            if let w = latest.weight { text += ", \(w) кг" }
            if let s = latest.steps { text += ", \(s) steps" }
            latestLabel.text = text
        } else {
            latestLabel.text = "No records"
        }
        tableView.reloadData()
    }
}

extension BodyViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = viewModel.records[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BodyCell", for: indexPath)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        var text = formatter.string(from: record.date)
        if let w = record.weight { text += ", \(w) кг" }
        if let s = record.steps { text += ", \(s) steps" }
        cell.textLabel?.text = text
        return cell
    }

    // Swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let record = viewModel.records[indexPath.row]
            viewModel.deleteRecord(id: record.id)
            reloadUI()
        }
    }
}
