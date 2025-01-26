//
//  CategoryTableViewCell.swift
//  TrackerApp
//
//  Created by Maksim on 11.01.2025.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    static let identifier = "CategoryTableViewCell"
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionCheckmark: UIImageView = {
        let image = UIImageView(
            image: UIImage(systemName: "checkmark")!.withTintColor(UIColor.systemBlue))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        [titleLabel, selectionCheckmark].forEach { contentView.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            selectionCheckmark.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16),
            selectionCheckmark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionCheckmark.widthAnchor.constraint(equalToConstant: 20),
            selectionCheckmark.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with category: TrackerCategory, isSelected: Bool) {
        titleLabel.text = category.title
        selectionCheckmark.isHidden = !isSelected
    }
}
