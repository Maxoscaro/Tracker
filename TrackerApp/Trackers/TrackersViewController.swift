//
//  TrackersViewController.swift
//  TrackerApp
//
//  Created by Maksim on 04.10.2024.
//

import UIKit

final class TrackersViewController: UIViewController, TrackerStoreDelegate {
    
    // MARK: - Types
    
    private enum Constants {
        static let itemsPerRow: CGFloat = 2
        static let sectionInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let interItemSpacing: CGFloat = 9
    }
    
    // MARK: - Public Properties
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Private Properties
    
    private var trackerStore = TrackerStore.shared
    private var categoryStore = TrackerCategoryStore.shared
    private let trackerTypeVC = TrackerTypeViewController()
    private var selectedCategories: [TrackerCategory] = []
    private var selectedDate: Date?
    private var tracker: [Tracker]?
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barStyle = .default
        searchBar.placeholder = "Поиск"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.textColor = UIColor(named: "BlackYP")
        searchBar.searchTextField.backgroundColor = UIColor(named: "Background")
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constants.interItemSpacing
        layout.minimumLineSpacing = 16
        layout.sectionInset = Constants.sectionInsets
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(TrackerHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "TrackerHeader")
        return collectionView
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    init(trackerStore: TrackerStore) {
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //clearAllTrackers()
        trackerStore.delegate = self
        setupView()
        setupInitialState()
    }
    
    // MARK: - Public Methods
    
    func clearAllTrackers() {
        do {
            try TrackerStore.shared.deleteAllTrackers()
        } catch {
            
            print("Не удалось очистить трекеры: \(error)")
        }
    }
    
    func addTracker(_ tracker: Tracker, toCategory categoryTitle: String) {
        guard let trackerCategoryCoreData = categoryStore.getCategoryBy(title: categoryTitle) else {
            print("Категория с названием \(categoryTitle) не найдена")
            return
        }
        do {
            try trackerStore.createTracker(with: tracker, in: trackerCategoryCoreData)
            print("Трекер \(tracker.title) добавлен в категорию \(categoryTitle)")
            updateTrackers()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } catch {
            print("Ошибка при создании трекера: \(error)")
        }
    }
    
    func removeTracker(_ tracker: Tracker, from categoryTitle: String) {
        var updatedCategories = categories
        if let index = updatedCategories.firstIndex(where: { $0.title == categoryTitle }) {
            let updatedTrackers = updatedCategories[index].trackers.filter { $0 != tracker }
            let updatedCategory = TrackerCategory(title: categoryTitle, trackers: updatedTrackers)
            updatedCategories[index] = updatedCategory
        }
        categories = updatedCategories
    }
    
    func getDateFromUIDatePicker() -> Date? {
        return selectedDate
    }
    
    func setTrackerIncomplete(for tracker: Tracker, on date: Date?) {
        guard let date = date ?? selectedDate else { return }
        removeRecord(for: tracker, on: date)
    }
    
    func setTrackerComplete(for tracker: Tracker, on date: Date?) {
        guard let date = date ?? selectedDate else { return }
        addRecord(for: tracker, on: date)
    }
    
    func updateCollectionViewWithNewTracker() {
        guard let selectedDate else { return }
        do {
            try trackerStore.fetchTrackers(for: selectedDate)
            updateUI()
            collectionView.reloadData()
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
    
    func didUpdateTrackers() {
           updateUI()
           collectionView.reloadData()
        print("Updated")
       }
    
    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        return completedTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "WhiteYP")
        view.addTapGestureToHideKeyboard()
        setupSearchBar()
        setupNavigationBar()
        setupEmptyState()
        setupCollectionView()
    }
    
    private func setupInitialState() {
        selectedDate = Date()
        updateUI()
    }
    
    private func setupSearchBar() {
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(newTrackerCreate))
        addButton.tintColor = UIColor(named: "BlackYP")
        navigationItem.leftBarButtonItem = addButton
        
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let datePick = UIDatePicker()
        datePick.preferredDatePickerStyle = .compact
        datePick.datePickerMode = .date
        datePick.backgroundColor = UIColor(named: "GrayDP")
        datePick.overrideUserInterfaceStyle = .light
        datePick.tintColor = .black
        datePick.layer.cornerRadius = 8
        datePick.clipsToBounds = true
        datePick.addTarget(self,
                           action: #selector(datePickerValueChanged(_:)),
                           for: .valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePick)
    }
    
    private func setupEmptyState() {
        view.addSubview(emptyStateView)
        
        let imageView = UIImageView(image: UIImage(named: "emptyTrackersIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "BlackYP")
        label.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(label)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            imageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
            label.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor)
        ])
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor(named: "WhiteYP")
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
    }
    
    private func updateUI() {
        let hasTrackers = trackerStore.numberOfSections() > 0
        emptyStateView.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers
    }
    
    private func addRecord(for tracker: Tracker, on date: Date) {
        var updatedRecords = completedTrackers
        let newRecord = TrackerRecord(trackerId: tracker.id, date: date)
        updatedRecords.append(newRecord)
        completedTrackers = updatedRecords
        print("Запись трекера \(tracker.title) выполнена")
    }
    
    private func removeRecord(for tracker: Tracker, on date: Date) {
        var updatedRecords = completedTrackers
        updatedRecords.removeAll {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
        completedTrackers = updatedRecords
    }
    
    private func getWeekday(from date: Date) -> WeekDay? {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        
        switch weekdayNumber {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return nil
        }
    }
    
    private func filterTrackers(for weekday: WeekDay,
                                from categories: [TrackerCategory]) -> [TrackerCategory] {
        var filteredCategories: [TrackerCategory] = []
        
        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.schedule.contains(weekday)
            }
            
            if !filteredTrackers.isEmpty {
                let filteredCategory = TrackerCategory(title: category.title,
                                                       trackers: filteredTrackers)
                filteredCategories.append(filteredCategory)
            }
        }
        collectionView.reloadData()
        return filteredCategories
    }
    
    private func updateTrackers() {
        guard let selectedDate = selectedDate else { return }
        
        do {
            try trackerStore.fetchTrackers(for: selectedDate)
            DispatchQueue.main.async { [weak self] in
                self?.updateUI()
                self?.collectionView.reloadData()
            }
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
    
    private func showCreateTrackersVC(with type: TrackerType) {
        let newTrackerVC = CreateTrackerViewController(type: type)
        newTrackerVC.onTrackerCreated = { [weak self] (newTracker: Tracker, category: String) in
            self?.addTracker(newTracker, toCategory: category)
            self?.dismiss(animated: true) {
                self?.updateTrackers()
            }
            self?.collectionView.reloadData()
        }
        newTrackerVC.modalPresentationStyle = .pageSheet
        present(newTrackerVC, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
            updateTrackers()
    }
    
    @objc private func newTrackerCreate() {
        trackerTypeVC.trackersVC = self
        present(trackerTypeVC, animated: true)
    }
}

// MARK: - UICollectionView Extensions

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell",
                                                      for: indexPath) as! TrackerCell
        if let tracker = trackerStore.tracker(at: indexPath) {
            cell.configure(with: tracker, on: selectedDate ?? Date())
            cell.trackersVC = self
        }
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "TrackerHeader",
            for: indexPath) as! TrackerHeader
        header.label.text = trackerStore.header(at: indexPath.section)
        return header
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = view.frame.width
        let paddingSpace = Constants.sectionInsets.left +
        Constants.sectionInsets.right +
        Constants.interItemSpacing * (Constants.itemsPerRow - 1)
        let availableWidth = screenWidth - paddingSpace
        let widthPerItem = availableWidth / Constants.itemsPerRow
        return CGSize(width: widthPerItem, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Constants.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}



