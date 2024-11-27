//
//  EmojiCell.swift
//  TrackerApp
//
//  Created by Maksim on 01.11.2024.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private lazy var selectionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "LightGrayYP")
        view.alpha = 0
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
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
    
    func configure(emoji: String) {
        emojiLabel.text = emoji
    }
    
    func setSelected(_ selected: Bool) {
        selectionView.alpha = selected ? 1 : 0
    }
}

// MARK: - UIViewConfigurableProtocol

extension EmojiCell: UIViewConfigurableProtocol {
    func setupUI() {
        contentView.addSubview(selectionView)
        contentView.addSubview(emojiLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            selectionView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            selectionView.widthAnchor.constraint(equalTo: widthAnchor),
            
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            emojiLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor)
            ])
    }
    
    
}
