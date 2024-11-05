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
        //view.backgroundColor
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
    return view
    }()
    
    private lazy var colorView: UIView = {
        let color = UIView()
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
    
    func configure(view: UIColor) {
        colorView.backgroundColor = view
    }
    
    func setSelected(_ selected: Bool) {
        selectionView.layer.borderWidth = selected ? 3 : 0
    }
}

// MARK: - UIViewConfigurableProtocol

extension ColorCell: UIViewConfigurableProtocol {
    func setupUI() {
        contentView.addSubview(selectionView)
        contentView.addSubview(colorView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            selectionView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.77),
            selectionView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.77),
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            colorView.widthAnchor.constraint(equalTo: contentView.widthAnchor)
            ])
    }
}

