//
//  CartItemCell.swift
//  MVVMStateManagement
//
//  Created by JANESH SUTHAR on 13/06/25.
//

import Foundation
import UIKit
import Combine

class CartItemCell: UITableViewCell {
    private var cancellable: AnyCancellable?
    var item: CartItem? {
        didSet {
            bind()
        }
    }

    let nameLabel = UILabel()
    let qtyLabel = UILabel()
    let stepper = UIStepper()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        qtyLabel.translatesAutoresizingMaskIntoConstraints = false
        stepper.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(nameLabel)
        contentView.addSubview(qtyLabel)
        contentView.addSubview(stepper)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            stepper.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stepper.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            qtyLabel.trailingAnchor.constraint(equalTo: stepper.leadingAnchor, constant: -12),
            qtyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        stepper.setIncrementImage(UIImage(systemName: "plus")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
        stepper.setDecrementImage(UIImage(systemName: "minus")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
        stepper.tintColor = .systemBlue
        stepper.minimumValue = 1
        stepper.addTarget(self, action: #selector(stepperChanged(_:)), for: .valueChanged)
    }

    @objc private func stepperChanged(_ sender: UIStepper) {
        item?.quantity = Int(sender.value)
    }

    private func bind() {
        cancellable?.cancel()
        guard let item = item else { return }

        nameLabel.text = item.name
        stepper.value = Double(item.quantity)
        qtyLabel.text = "Qty: \(item.quantity)"

        cancellable = item.$quantity
            .receive(on: RunLoop.main)
            .sink { [weak self] newQty in
                self?.qtyLabel.text = "Qty: \(newQty)"
                self?.stepper.value = Double(newQty)
            }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
        item = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
