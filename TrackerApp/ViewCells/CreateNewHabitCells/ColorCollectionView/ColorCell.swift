//
//  ColorCell.swift
//  TrackerApp
//
//  Created by Maksim on 03.11.2024.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    
    private lazy var selectionView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
    return view
    }()
    
    private lazy var colorView: UIView = {
        let color = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        color.translatesAutoresizingMaskIntoConstraints = false
        color.layer.cornerRadius = 8
        return color
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with color: UIColor, setSelected: Bool) {
            colorView.backgroundColor = color
            let borderColor = color.withAlphaComponent(0.3)
            contentView.layer.borderWidth = setSelected ? 3 : 0
            contentView.layer.borderColor = setSelected ? borderColor.cgColor : nil
        }
}

// MARK: - UIViewConfigurableProtocol

extension ColorCell: UIViewConfigurableProtocol {
    func setupUI() {
        contentView.addSubview(selectionView)
        contentView.addSubview(colorView)
        contentView.layer.cornerRadius = 8
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            selectionView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            selectionView.widthAnchor.constraint(equalTo: widthAnchor),
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.77),
            colorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.77)
            ])
    }
}

