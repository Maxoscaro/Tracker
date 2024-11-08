//
//  CreateTrackerViewController.swift
//  TrackerApp
//
//  Created by Maksim on 11.10.2024.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var trackersVC: TrackersViewController?
    weak var delegate: TrackerTypeViewController?
    var onTrackerCreated: ((Tracker, String) -> Void)?
    
    // MARK: - Private Properties
    
    private var selectedCategory: TrackerCategory?
    private var selectedSchedule = Set<WeekDay>()
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    private var emojiDelegate = EmojiCollectionViewDelegate()
    private var colorDelegate = ColorCollectionViewDelegate()
    
    private let trackerType: TrackerType
    private let scheduleScreenVC = ScheduleScreenViewController()
    private let categoryVC = ChooseCategoryViewController()

    
    // MARK: - UI Elements
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor(named: "WhiteYP")
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var screenTitle: UILabel = {
        let title = UILabel()
        title.textColor = UIColor(named: "BlackYP")
        title.font = UIFont.systemFont(ofSize: 16)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var newTrackerName: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.backgroundColor = UIColor(named: "Background")
        textField.borderStyle = .none
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = UIColor(named: "BlackYP")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor(named: "WhiteYP"), for: .normal)
        button.setTitleColor(.white, for: .disabled)
        button.backgroundColor = UIColor(named: "GrayYP")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(named: "RedYP"), for: .normal)
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        collectionView.dataSource = emojiDelegate
        collectionView.delegate = emojiDelegate
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.register(EmojiHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "EmojiHeader")
        emojiDelegate.createTrackerVC = self
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        
        let collectionView =  UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        collectionView.dataSource = colorDelegate
        collectionView.delegate = colorDelegate
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.register(ColorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ColorHeader")
        colorDelegate.createTrackerVC = self
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    init(type: TrackerType) {
        self.trackerType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        view.backgroundColor = UIColor(named: "WhiteYP")
        view.addTapGestureToHideKeyboard()
        categoryVC.delegate = self
        scheduleScreenVC.delegate = self
        setupUI()
        setupConstraints()
        configureForTrackerType()
        updateCreateButtonState()
    }
    
    private func configureForTrackerType() {
        switch trackerType {
        case .habit:
            screenTitle.text = "Новая привычка"
        case .notRegularEvent:
            screenTitle.text = "Новое нерегулярное событие"
        }
    }
    
    private func updateCreateButtonState() {
        let isNameValid = !(newTrackerName.text?.isEmpty ?? true)
        let isScheduleValid = trackerType == .notRegularEvent || !selectedSchedule.isEmpty
        createButton.isEnabled = isNameValid && isScheduleValid
        createButton.backgroundColor = createButton.isEnabled ? UIColor(named: "BlackYP") : UIColor(named: "GrayYP")
        createButton.titleLabel?.textColor = UIColor(named: "WhiteYP")
    }
    
    private func convertWeekdaysToString(_ selectedWeekdays: Set<WeekDay>) -> String {
        let abbreviations: [WeekDay: String] = [
            .monday: "Пн",
            .tuesday: "Вт",
            .wednesday: "Ср",
            .thursday: "Чт",
            .friday: "Пт",
            .saturday: "Сб",
            .sunday: "Вс"
        ]
        let abbreviationsArray = selectedWeekdays.compactMap { abbreviations[$0] }
        return abbreviationsArray.joined(separator: ", ")
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func createButtonTapped() {
        guard let trackerName = newTrackerName.text, !trackerName.isEmpty else { return }
        let categoryTitle = selectedCategory?.title ?? "Важное"
        
        let newTracker = Tracker(id: UUID(), title: trackerName, color: .blue, emoji: "🥇", schedule: selectedSchedule)
        
        onTrackerCreated?(newTracker, categoryTitle)
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Public Methods
    
    func updateCategory(_ category: TrackerCategory) {
        self.selectedCategory = category
        updateCreateButtonState()
    }
    
    func updateSelectedWeekdays(_ selectedSchedule: Set<WeekDay>) {
        self.selectedSchedule = selectedSchedule
        tableView.reloadData()
        updateCreateButtonState()
    }
    
    func getEmojies() -> [String] {
        TrackerConstants.emojis
    }
    
    func getColors() -> [UIColor] {
        TrackerConstants.colors
    }
    func getSelectedColorsIndex() -> IndexPath? {
        selectedColorIndex
    }
    
    func getSelectedEmojiIndex() -> IndexPath? {
        selectedEmojiIndex
    }
    
    func setSelectedColorIndex(_ indexPath: IndexPath) {
        selectedColorIndex = indexPath
    }
    
    func setSelectedEmojiIndex(_ indexPath: IndexPath) {
        selectedEmojiIndex = indexPath
    }
    
    
}
// MARK: - ConfigurableProtocol

extension CreateTrackerViewController: UIViewConfigurableProtocol {
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [screenTitle, newTrackerName, tableView, emojiCollectionView, colorCollectionView].forEach { contentView.addSubview($0) }
        [createButton, cancelButton].forEach { view.addSubview($0) }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            screenTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            screenTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            newTrackerName.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 38),
            newTrackerName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            newTrackerName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            newTrackerName.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: newTrackerName.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 250),
            
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 250),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension CreateTrackerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerType == .habit ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        configureCell(cell, at: indexPath)
        return cell
    }
    
    private func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.backgroundColor = UIColor(named: "Background")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textColor = UIColor(named: "BlackYP")
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.textColor = UIColor(named: "GrayYP")
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        
        if trackerType == .habit && indexPath.row == 1 {
            cell.textLabel?.text = "Расписание"
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.detailTextLabel?.text = !selectedSchedule.isEmpty ? convertWeekdaysToString(selectedSchedule) : nil
        } else {
            if trackerType == .notRegularEvent {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            }
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = selectedCategory?.title ?? "Важное"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if trackerType == .notRegularEvent || (trackerType == .habit && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1) {
            cell.layer.cornerRadius = 16
            cell.clipsToBounds = true
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if trackerType == .habit && indexPath.row == 1 {
            scheduleScreenVC.modalPresentationStyle = .pageSheet
            present(scheduleScreenVC, animated: true)
        } else {
            categoryVC.modalPresentationStyle = .pageSheet
            present(categoryVC, animated: true)
        }
    }
}