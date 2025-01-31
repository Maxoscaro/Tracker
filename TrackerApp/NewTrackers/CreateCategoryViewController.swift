//
//  CreateCategoryViewController.swift
//  TrackerApp
//
//  Created by Maksim on 11.01.2025.
//

import UIKit

enum CategoryMode {
    case create
    case edit
}

final class CreateCategoryViewController: UIViewController {
    
    var mode: CategoryMode = .create
    weak var delegate: ChooseCategoryViewModel?
    var viewModel: CreateCategoryViewModel
    var editingCategory: TrackerCategory?
    
    init(viewModel: CreateCategoryViewModel, mode: CategoryMode = .create, editingCategory: TrackerCategory? = nil) {
           self.viewModel = viewModel
           self.mode = mode
           self.editingCategory = editingCategory
           super.init(nibName: nil, bundle: nil)
       }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    
    private lazy var screenTitle: UILabel = {
        let title = UILabel()
        title.text = LocalizedStrings.NewCategory.title
        title.textColor = UIColor(named: "BlackYP")
        title.font = .systemFont(ofSize: 16)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var categoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = LocalizedStrings.NewCategory.placeholder
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
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(LocalizedStrings.NewCategory.doneButton, for: .normal)
        button.backgroundColor = UIColor(named: "BlackYP")
        button.layer.cornerRadius = 16
        button.setTitleColor(UIColor(named: "WhiteYP"), for: .normal)
        button.addTarget(self, action: #selector(creationButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
        bindViewModel()
        viewModel.updateButtonState()
        
        if mode == .edit {
                   screenTitle.text = "Редактирование категории"
                   doneButton.setTitle("Сохранить", for: .normal)
                   categoryNameTextField.text = editingCategory?.title
                   viewModel.categoryName = editingCategory?.title ?? ""
               }
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        view.backgroundColor = UIColor(named: "WhiteYP")
        view.addTapGestureToHideKeyboard()
        setupUI()
        setupConstraints()
    }
    
    private func bindViewModel() {
        viewModel.onCategoryCreation = { [weak self] text in
            self?.categoryNameTextField.text = text
                }
        
        viewModel.onCreationButtonStateUpdate = { [weak self ] isEnabled in
            guard let self else { return }
            self.doneButton.isEnabled = isEnabled
            self.doneButton.alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    @objc private func textFieldDidChange() {
        viewModel.categoryName = categoryNameTextField.text ?? ""
        viewModel.updateButtonState()
    }
    
    @objc private func creationButtonTapped(_ sender: UIButton) {
        if mode == .edit {
              guard let oldTitle = editingCategory?.title else { return }
              viewModel.editCategory(oldTitle: oldTitle, newTitle: categoryNameTextField.text ?? "")
          } else {
              viewModel.createNewCategory()
          }
          delegate?.loadCategories()
          NotificationCenter.default.post(name: NSNotification.Name("CategoriesDidChange"), object: nil)
          dismiss(animated: true)
    }
}

extension CreateCategoryViewController: UIViewConfigurableProtocol {
    func setupUI() {
        [screenTitle, doneButton, categoryNameTextField].forEach { view.addSubview($0)}
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            screenTitle.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            screenTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            categoryNameTextField.topAnchor.constraint(
                equalTo: screenTitle.bottomAnchor, constant: 38),
            categoryNameTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16),
            
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}
