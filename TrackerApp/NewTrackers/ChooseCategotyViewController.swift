//
//  ChooseCategoryViewController.swift
//  TrackerApp
//
//  Created by Maksim on 16.10.2024.
//

import UIKit

final class ChooseCategoryViewController: UIViewController {
    
    // MARK: - Dependencies
    
    weak var trackersVC: TrackersViewController?
    weak var delegate: CreateTrackerViewController?
    var viewModel: ChooseCategoryViewModel
    var onDone: ((TrackerCategory) -> Void)?
    private var trackerCategoryStore = TrackerCategoryStore.shared
    private var currentCategory: TrackerCategory?
    
    
    // MARK: - Private Properties
    
    private var selectedCategory: TrackerCategory? {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var screenTitle: UILabel = {
        let title = UILabel()
        title.text = LocalizedStrings.Categories.title
        title.textColor = UIColor(named: "BlackYP")
        title.font = .systemFont(ofSize: 16)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = UIColor(named: "BlackYP")
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var emptyStateImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "emptyTrackersIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedStrings.Categories.placeholderText
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "BlackYP")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addNewCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle(LocalizedStrings.Categories.addButton, for: .normal)
        button.backgroundColor = UIColor(named: "BlackYP")
        button.layer.cornerRadius = 16
        button.setTitleColor(UIColor(named: "WhiteYP"), for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    
    init(viewModel: ChooseCategoryViewModel, currentCategory: TrackerCategory? = nil) {
        self.viewModel = viewModel
        self.viewModel.trackersCategoryStore = TrackerCategoryStore.shared
        self.selectedCategory = currentCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
        bindViewModel()
        viewModel.loadCategories()
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        view.backgroundColor = UIColor(named: "WhiteYP")
        view.addTapGestureToHideKeyboard()
        setupUI()
        setupConstraints()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(categoriesDidChange),
            name: NSNotification.Name("CategoriesDidChange"),
            object: nil
        )
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] categories in
            guard let self = self else { return }
            let isCategoryListEmpty = categories.isEmpty
            self.updateUI(isCategoryListEmpty)
            self.tableView.reloadData()
        }
        
        viewModel.onCategorySelected = { [weak self] selectedCategory in
            guard let self,
                  let delegate = self.delegate,
                  let selectedCategory else { return }
            delegate.updateCategory(selectedCategory)
            self.dismiss(animated: true)
        }
    }
    
    private func presentDeleteAlert(_ category: TrackerCategory) {
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) {
            [weak self] _ in
            guard let self = self,
                  let categoryCoreData = self.trackerCategoryStore.getCategoryBy(title: category.title)
            else { return }
            self.trackerCategoryStore.deleteCategory(categoryCoreData)
        }
        
        let cancelAction = UIAlertAction(
            title: "Отменить", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func updateUI(_ isCategoryListEmpty: Bool) {
        emptyStateView.isHidden = !isCategoryListEmpty
        tableView.isHidden = isCategoryListEmpty
    }
    
    @objc private func categoriesDidChange() {
        viewModel.loadCategories()
          DispatchQueue.main.async { [weak self] in
              self?.tableView.reloadData()
          }
    }
    
    @objc private func addButtonTapped(_ sender: UIButton) {
        let createCategoryVC = CreateCategoryViewController(viewModel: CreateCategoryViewModel())
        createCategoryVC.delegate = viewModel
        createCategoryVC.viewModel.trackersCategoryStore = self.viewModel.trackersCategoryStore
        present(createCategoryVC, animated: true)
    }
}

// MARK: - UIViewConfigurableProtocol

extension ChooseCategoryViewController: UIViewConfigurableProtocol {
    func setupUI() {
        [screenTitle, tableView, addNewCategoryButton, emptyStateView].forEach { view.addSubview($0) }
        [emptyStateImage, emptyStateLabel].forEach { emptyStateView.addSubview($0) }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            screenTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
            screenTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addNewCategoryButton.topAnchor, constant: -20),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateImage.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImage.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImage.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImage.widthAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImage.bottomAnchor, constant: 8),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            addNewCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addNewCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addNewCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addNewCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ChooseCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.identifier,
            for: indexPath
        ) as! CategoryTableViewCell
        
        configureCell(cell, at: indexPath)
        return cell
    }
    
    private func configureCell(_ cell: CategoryTableViewCell, at indexPath: IndexPath) {
        let category = viewModel.categories[indexPath.row]
        
        cell.backgroundColor = UIColor(named: "Background")
        cell.configure(with: category, isSelected: category == selectedCategory)
     
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.masksToBounds = true
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else if indexPath.row == viewModel.categories.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.masksToBounds = true
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.masksToBounds = true
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = viewModel.categories[indexPath.row]
        selectedCategory = category
        tableView.reloadData()
        delegate?.updateCategory(category)
        onDone?(category)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? CategoryTableViewCell else { return }
        configureCell(cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = viewModel.categories[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(
                title: "Редактировать"
            ) { [weak self] _ in
                let createCategoryVC = CreateCategoryViewController(viewModel: CreateCategoryViewModel())
                createCategoryVC.delegate = self?.viewModel
                createCategoryVC.viewModel.trackersCategoryStore = self?.viewModel.trackersCategoryStore
                createCategoryVC.viewModel.categoryName = category.title
                createCategoryVC.mode = .edit
                createCategoryVC.editingCategory = category
                self?.present(createCategoryVC, animated: true)
            }
            
            let deleteAction = UIAction(
                title: "Удалить",
                attributes: .destructive
            ) { [weak self] _ in
                self?.presentDeleteAlert(category)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}


