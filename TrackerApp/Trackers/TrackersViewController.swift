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
    let analyticsService = AnalyticsService()
    
    // MARK: - Private Properties
    
    private var trackerStore =  TrackerStore.shared
    private var categoryStore = TrackerCategoryStore.shared
    private var trackerRecordStore = TrackerRecordStore.shared
    private let trackerTypeVC = TrackerTypeViewController()
    private var selectedCategories: [TrackerCategory] = []
    private var selectedDate: Date?
    private var datePicker = UIDatePicker()
    private var nothingFoundStateView = UIView()
    private var tracker: [Tracker]?
    private let filteredTrackersVC = FilteredTrackersViewController()
    
    //MARK: - UIComponents
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barStyle = .default
        searchBar.delegate = self
        searchBar.placeholder = LocalizedStrings.Trackers.searchPlaceHolder
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LocalizedStrings.Trackers.filters, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor(named: "LauchScreenColor")
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        trackerStore.delegate = self
        setupView()
        setupInitialState()
        setupFilterButton()
        
        updateCollectionView(with: FilterStore.selectedFilter)
        
        let analyticsEvent = AnalyticsEvent(
            eventType: .open,
            screen: "Main",
            item: nil
        )
        analyticsService.sendEvent(analyticsEvent)
    }
    
    // MARK: - Public Methods
    
    func addTracker(_ tracker: Tracker, toCategory categoryTitle: String) {
        guard let trackerCategoryCoreData = categoryStore.getCategoryBy(title: categoryTitle) else {
            print("Категория с названием \(categoryTitle) не найдена")
            return
        }
        do {
            try trackerStore.createTracker(with: tracker, in: trackerCategoryCoreData)
            print("Трекер \(tracker.title) добавлен в категорию \(categoryTitle)")
            DispatchQueue.main.async {
                self.updateCollectionView(with: FilterStore.selectedFilter)
            }
        } catch {
            print("Ошибка при создании трекера: \(error)")
        }
    }
    
    func getDateFromUIDatePicker() -> Date? {
        guard let selectedDate = selectedDate else { return nil }
        return selectedDate
    }
    
    func setTrackerIncomplete(for tracker: Tracker, on date: Date?) {
        guard let date = date ?? selectedDate else { return }
        print("Incomplete вызван для трекера \(tracker.title) на дату \(date)")
        self.removeRecord(for: tracker, on: date)
        
        DispatchQueue.main.async {
            self.updateCollectionView(with: FilterStore.selectedFilter)
        }
    }
    
    func setTrackerComplete(for tracker: Tracker, on date: Date?) {
        guard let date = date ?? selectedDate else { return }
        print("setTrackerComplete вызван для трекера \(tracker.title) на дату \(date)")
        addRecord(for: tracker, on: date)
        updateCollectionView(with: FilterStore.selectedFilter)
    }
    
    func didUpdateTrackers() {
        updateUI()
        collectionView.reloadData()
        print("TrackerVC Updated")
    }
    
    func handleFilterSelection(_ filterType: FilterType) {
        updateCollectionView(with: filterType)
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "WhiteYP")
        view.addTapGestureToHideKeyboard()
        setupSearchBar()
        setupNavigationBar()
        setupEmptyState()
        setupNothingFoundStateView()
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
        
        navigationItem.title = LocalizedStrings.Trackers.title
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
        emptyStateView.addSubview(imageView)
        
        let label = UILabel()
        label.text = LocalizedStrings.Trackers.placeholderText
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
    
    private func setupNothingFoundStateView() {
        let nothingFoundStateView = UIView()
        nothingFoundStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nothingFoundStateView)
        
        let imageView = UIImageView(image: UIImage(named: "nothingFoundIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nothingFoundStateView.addSubview(imageView)
        
        let label = UILabel()
        label.text = LocalizedStrings.Trackers.nothingFound
        label.font = UIFont(name: "SFProText-Medium", size: 12)
        label.textColor = UIColor(named: "BlackYP")
        label.translatesAutoresizingMaskIntoConstraints = false
        nothingFoundStateView.addSubview(label)
        
        NSLayoutConstraint.activate([
            nothingFoundStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nothingFoundStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: nothingFoundStateView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: nothingFoundStateView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: nothingFoundStateView.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: nothingFoundStateView.bottomAnchor)
        ])
        
        self.nothingFoundStateView = nothingFoundStateView
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
        let isSearchActive = !(searchBar.text?.isEmpty ?? true)
        
        if isSearchActive {
        
            if tracker?.isEmpty ?? true {
                emptyStateView.isHidden = true
                nothingFoundStateView.isHidden = false
                collectionView.isHidden = true
            } else {
                emptyStateView.isHidden = true
                nothingFoundStateView.isHidden = true
                collectionView.isHidden = false
            }
        } else {
            nothingFoundStateView.isHidden = true
            
            if tracker?.isEmpty ?? true {
                emptyStateView.isHidden = false
                collectionView.isHidden = true
            } else {
                emptyStateView.isHidden = true
                collectionView.isHidden = false
            }
        }
    }
    
    private func removeTracker(_ tracker: Tracker) {
        guard let trackerEntity = trackerStore.fetchTrackerEntity(tracker.id), let category = trackerEntity.category else {
            print("Трекер с названием \(tracker.title) не найден в базе")
            return
        }
        trackerStore.removeTracker(with: tracker.id)
        print("Трекер \(tracker.title) удален из категории \(category)")
        self.updateCollectionView(with: FilterStore.selectedFilter)
    }
    
    
    private func removeRecord(for tracker: Tracker, on date: Date) {
        trackerRecordStore.removeTrackerRecord(with: tracker.id, on: date)
        completedTrackers.removeAll { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
        print("Запись трекера \(tracker.title) удалена")
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func addRecord(for tracker: Tracker, on date: Date) {
        guard let trackerEntity = trackerStore.fetchTrackerEntity(tracker.id) else {
            print("Запись трекера \(tracker.title) НЕ выполнена")
            return }
        trackerRecordStore.createTrackerRecord(with: trackerEntity, on: date)
        print("Запись трекера \(tracker.title) выполнена")
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
    
    private func updateCollectionView(with filter: FilterType) {
        switch filter {
        case .allTrackers:
            guard let selectedDate else { return }
            try? tracker = trackerStore.fetchTrackers(for: selectedDate)
        case .todayTrackers:
            selectedDate = Date()
            guard let selectedDate else { return }
            datePicker.date = selectedDate
            try? tracker = trackerStore.fetchTrackers(for: selectedDate)
        case .completedTrackers:
            guard let selectedDate else {return}
            tracker = trackerStore.fetchCompleteTrackers(by: selectedDate)
        case .uncompletedTrackers:
            guard let selectedDate else {return}
            tracker = trackerStore.fetchIncompleteTrackers(by: selectedDate)
        }
        updateUI()
        collectionView.reloadData()
    }
    
    private func setupFilterButton() {
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -26),
            filterButton.widthAnchor.constraint(equalToConstant: 150),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    private func presentDeleteAlert(for tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: "Уверены что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) {
            [weak self] _ in
            self?.removeTracker(tracker)
        }
        
        let cancelAction = UIAlertAction(
            title: "Отменить", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        switch FilterStore.selectedFilter {
        case .allTrackers:
            updateCollectionView(with: .allTrackers)
        case .todayTrackers:
            updateCollectionView(with: .allTrackers)
            filteredTrackersVC.setFilter(.allTrackers)
        case .completedTrackers:
            updateCollectionView(with: .completedTrackers)
        case .uncompletedTrackers:
            updateCollectionView(with: .uncompletedTrackers)
        }
    }
    
    @objc private func newTrackerCreate() {
        trackerTypeVC.trackersVC = self
        print("Create Tracker button tapped")
        let analyticsEvent = AnalyticsEvent(
            eventType: .click,
            screen: "Main",
            item: .add_track
        )
        analyticsService.sendEvent(analyticsEvent)
        
        present(trackerTypeVC, animated: true)
    }
    
    @objc private func filterButtonTapped() {
        filteredTrackersVC.delegate = self
        print("Filter button tapped")
        let analyticsEvent = AnalyticsEvent(
            eventType: .click,
            screen: "Main",
            item: .filter
        )
        analyticsService.sendEvent(analyticsEvent)
        
        present(filteredTrackersVC, animated: true)
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
        guard
            let selectedDate = selectedDate,
            let tracker = trackerStore.trackerObject(at: indexPath)
        else { return cell}
        cell.trackersVC = self
        cell.trackerRecordStore = self.trackerRecordStore
        cell.configure(with: tracker, on: selectedDate)
        
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let config = UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell,
                  let tracker = cell.getTracker() else { return UIMenu(title: "", children: [])}
            
            let pinTracker = UIAction(
                title: self.isTrackerPinned(tracker) ?
                "Открепить" : "Закрепить",
                identifier: nil
            ) { _ in
                self.toggleTrackerPin(tracker)
            }
            let editTracker = UIAction(title: "Редактировать", identifier: nil) { [weak self] _ in
                guard let self, let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell, let tracker = cell.getTracker() else { return }
                
                let analyticsEvent = AnalyticsEvent(
                    eventType: .click,
                    screen: "Main",
                    item: .edit
                )
                self.analyticsService.sendEvent(analyticsEvent)
                print("Edit Tracker button tapped")
                
                let editTrackerVC = CreateTrackerViewController(type: .habit, isRegularEvent: true, isEditingTracker: true, editableTracker: tracker)
                editTrackerVC.trackersVC = self
                editTrackerVC.trackerStore = self.trackerStore
                editTrackerVC.categoryStore = self.categoryStore
                
                self.present(editTrackerVC, animated: true)
                
            }
            let deleteTracker = UIAction(title: "Удалить", identifier: nil, attributes: .destructive) { [weak self] _ in
                guard let self, let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell, let tracker = cell.getTracker() else { return }
                
                let analyticsEvent = AnalyticsEvent(
                    eventType: .click,
                    screen: "Main",
                    item: .delete
                )
                self.analyticsService.sendEvent(analyticsEvent)
                print("Delete Tracker button tapped")
                presentDeleteAlert(for: tracker)
            }
            return UIMenu(title: "", children: [pinTracker, editTracker, deleteTracker])
        }
        return config
    }
    
    private func isTrackerPinned(_ tracker: Tracker) -> Bool {
        guard let isPinned = trackerStore.fetchTrackerEntity(tracker.id)?.isPinned else { return false}
        return isPinned
    }
    
    private func toggleTrackerPin(_ tracker: Tracker) {
        let currentState = isTrackerPinned(tracker)
        let updatedTracker = Tracker(id: tracker.id ,title: tracker.title, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule, isPinned: !currentState)
        trackerStore.updateTracker(for: updatedTracker)
        print(updatedTracker.isPinned)
        self.updateCollectionView(with: FilterStore.selectedFilter)
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: cell.getCellColorRectView().bounds, cornerRadius: 16)
        
        return UITargetedPreview(view: cell, parameters: parameters)
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) else {
            return nil
        }
        
        return UITargetedPreview(view: cell)
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tracker = trackerStore.searchTracker(with: searchText)
        updateUI()
        collectionView.reloadData()
    }
}

extension TrackersViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.bounds.height
        let offsetY = scrollView.contentOffset.y
        
        if contentHeight <= screenHeight {
            UIView.animate(withDuration: 0.3) {
                self.filterButton.alpha = 1
            }
            return
        }
        
        if offsetY > 0 {
            UIView.animate(withDuration: 0.3) {
                self.filterButton.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.filterButton.alpha = 1
            }
        }
    }
}






