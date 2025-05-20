import UIKit

class MoneyViewController: UIViewController {
    private let viewModel = MoneyViewModel()
    private var balanceLabel: UILabel!
    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        title = "Money"
        setupUI()
        reloadUI()
    }

    private func setupUI() {
        balanceLabel = UILabel()
        balanceLabel.font = .boldSystemFont(ofSize: 32)
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false

        let addButton = UIButton(type: .system)
        addButton.setTitle("Add", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MoneyCell")

        view.addSubview(balanceLabel)
        view.addSubview(addButton)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            balanceLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            balanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            addButton.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            tableView.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func addTapped() {
        let alert = UIAlertController(title: "Add Money", message: "Enter amount", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.keyboardType = .decimalPad
            tf.placeholder = "Amount"
        }
        alert.addTextField { tf in
            tf.placeholder = "Note (optional)"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            if let text = alert.textFields?.first?.text,
               let amount = Double(text) {
                let note = alert.textFields?.last?.text
                self.viewModel.addMoney(amount: amount, note: note)
                self.reloadUI()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func reloadUI() {
        balanceLabel.text = "Balance: \(Int(viewModel.balance)) ₽"
        tableView.reloadData()
    }
}

extension MoneyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = viewModel.entries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoneyCell", for: indexPath)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let date = dateFormatter.string(from: entry.date)
        cell.textLabel?.text = "\(date): \(entry.amount)₽ \(entry.note ?? "")"
        return cell
    }
}
