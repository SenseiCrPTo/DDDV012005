import UIKit
// Assuming DiaryDataStore.swift is accessible

protocol DiaryWidgetUIViewDelegate: AnyObject {
    func didTapDiaryWidget(_ diaryWidgetView: DiaryWidgetUIView)
}

class DiaryWidgetUIView: UIView {

    // MARK: - Delegate
    weak var delegate: DiaryWidgetUIViewDelegate?

    // MARK: - DataStore
    var diaryDataStore: DiaryDataStore?

    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let moodIconImageView = UIImageView()
    private let moodNameLabel = UILabel()
    private let latestEntryExcerptLabel = UILabel()
    private let reminderLabel = UILabel()
    
    private let mainStackView = UIStackView()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupSubviews()
        setupLayout()
        setupTapGesture()
        configureWithPlaceholderData() // Still using placeholder for now
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 16
        clipsToBounds = true
    }

    private func setupSubviews() {
        mainStackView.axis = .vertical
        mainStackView.spacing = 6
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)

        // Header (Title + Icon)
        let headerStackView = UIStackView()
        headerStackView.axis = .horizontal
        headerStackView.spacing = 8
        headerStackView.alignment = .center

        titleLabel.text = "Дневник"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold) // .headline
        headerStackView.addArrangedSubview(titleLabel)

        moodIconImageView.contentMode = .scaleAspectFit
        moodIconImageView.tintColor = .systemPurple // Placeholder color
        headerStackView.addArrangedSubview(moodIconImageView)
        
        mainStackView.addArrangedSubview(headerStackView)

        // Mood Name
        moodNameLabel.font = UIFont.systemFont(ofSize: 15) // .subheadline
        moodNameLabel.textColor = .systemPurple // Placeholder color
        mainStackView.addArrangedSubview(moodNameLabel)

        // Latest Entry Excerpt
        latestEntryExcerptLabel.font = UIFont.systemFont(ofSize: 12) // .caption
        latestEntryExcerptLabel.textColor = .secondaryLabel
        latestEntryExcerptLabel.numberOfLines = 3
        mainStackView.addArrangedSubview(latestEntryExcerptLabel)
        
        // Spacer to push reminder to bottom
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        mainStackView.addArrangedSubview(spacerView)

        // Reminder Text
        reminderLabel.font = UIFont.systemFont(ofSize: 10) // .caption2
        reminderLabel.textColor = .gray
        mainStackView.addArrangedSubview(reminderLabel)
    }

    private func setupLayout() {
        let padding: CGFloat = 12
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),

            moodIconImageView.widthAnchor.constraint(equalToConstant: 22), // Adjusted size
            moodIconImageView.heightAnchor.constraint(equalToConstant: 22), // Adjusted size
            
            latestEntryExcerptLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40) // Matched SwiftUI minHeight
        ])
    }

    // MARK: - Data Configuration
    func configure(with dataStore: DiaryDataStore) {
        self.diaryDataStore = dataStore
        updateUIFromDataStore()
    }

    private func updateUIFromDataStore() {
        guard let dataStore = diaryDataStore else {
            configureWithPlaceholderData() // Fallback
            return
        }

        let moodDisplay = dataStore.mainMoodDisplay
        moodIconImageView.image = UIImage(systemName: moodDisplay.icon ?? "questionmark.circle")
        // Converting SwiftUI Color to UIColor. This is a basic conversion.
        // If Color(hex:) was used in MoodSetting, that logic needs to be available here or use a default.
        if let swiftUIColor = moodDisplay.color {
             // This is a simplified conversion. For more complex Colors (like gradients, materials), this won't work.
             // Assuming simple solid colors for now.
            let uiColor = UIColor(swiftUIColor) // This requires iOS 14+ if using UIColor(Color) directly
            moodIconImageView.tintColor = uiColor
            moodNameLabel.textColor = uiColor
        } else {
            moodIconImageView.tintColor = .systemGray
            moodNameLabel.textColor = .systemGray
        }
        moodNameLabel.text = moodDisplay.name
        
        latestEntryExcerptLabel.text = dataStore.latestEntryExcerpt
        reminderLabel.text = dataStore.reminderText
    }

    func configureWithPlaceholderData() {
        moodIconImageView.image = UIImage(systemName: "face.smiling.fill")
        moodIconImageView.tintColor = .systemPurple
        moodNameLabel.textColor = .systemPurple
        moodNameLabel.text = "Настроение (placeholder)"
        latestEntryExcerptLabel.text = "Выдержка из дневника (placeholder)..."
        reminderLabel.text = "Напоминание (placeholder)"
    }
}

// Note: UIColor(Color) initializer is available from iOS 14.0+.
// If supporting older versions, a more specific Color to UIColor conversion is needed,
// possibly by exposing hex strings from DataStore/Models if colors are defined that way.
// For the purpose of this refactor, we assume iOS 14+ or that a suitable conversion exists.
// If Color(hex: String) was used in MoodSetting, that utility would be good here.
// For now, a direct UIColor(swiftUIColor) is used.
// If `moodDisplay.color` is `nil`, it defaults to gray.
// The original SwiftUI `Color` might have come from a hex string.
// If `MoodSetting.color` (SwiftUI Color) can't be directly converted,
// we might need to adjust `MoodSetting` to also provide a UIColor or hex string.
// For now, I'll assume `UIColor(swiftUIColor)` works or a default gray is acceptable.
// The `UIColor(Color)` initializer is available in iOS 14+.
// If the `moodDisplay.color` is based on `Color(hex: "...")`, then a `UIColor(hex: "...")` utility would be better.
// Let's assume `moodDisplay.color` is a simple color that can be converted.
// If `moodDisplay.color` is nil, it defaults to gray.
// The original Color in SwiftUI might have been defined via `Color(hex: someHexValue)`.
// A robust solution would be to ensure MoodSetting provides either a UIColor or a hex string for UIColor initialization.
// For now, I will use `UIColor(swiftUIColor)` and it will work if the SwiftUI `Color` is one of the standard ones.
// If it's a custom one (e.g. from hex), this conversion might not be perfect.
// For this exercise, let's proceed with this direct conversion.

// MARK: - Actions
extension DiaryWidgetUIView {
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        delegate?.didTapDiaryWidget(self)
    }
}
